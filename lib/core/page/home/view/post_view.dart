import 'dart:convert';
import 'dart:typed_data';
import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/auth/users_profiles.dart';
import 'package:everesports/core/page/home/service/comment_service.dart'
    show CommentService;
import 'package:everesports/core/page/home/widget/ExpandableText.dart';
import 'package:everesports/core/page/home/view/top_filter.dart';
import 'package:everesports/core/page/home/widget/action_button_posts.dart';
import 'package:everesports/core/page/home/widget/like_button.dart';
import 'package:everesports/core/page/home/widget/image_slide_grid.dart';
import 'package:everesports/core/page/home/widget/posts_view_loading.dart';
import 'package:everesports/core/page/home/widget/user_avatar_posts.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:everesports/core/page/home/view/comment_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:everesports/core/page/home/service/like_service.dart';
import 'package:everesports/service/auth/follow_service.dart';

class PostDisplayPage extends StatefulWidget {
  const PostDisplayPage({super.key});

  @override
  State<PostDisplayPage> createState() => _PostDisplayPageState();
}

class _PostDisplayPageState extends State<PostDisplayPage>
    with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  Size? _lastSize;
  List<Map<String, dynamic>>? _cachedPosts;
  bool _loading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true; // Indicates if more pages are available
  String? _error;
  String _activeFilter = 'All';
  String? _currentUserId;
  final Map<String, bool> _likedByMe = {};
  final Map<String, int> _likeCounts = {};
  final Map<String, int> _commentCounts = {};
  final Map<String, bool> _followingStatus = {};
  final Set<String> _followingIds = <String>{};
  String? _loadingFollowUserId;
  final Map<String, bool> _savedByMe = {}; // bookmark state per postId
  DocumentSnapshot? _lastPostDoc; // For Firestore pagination

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _loadUserId().then((_) => _fetchPosts(reset: true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final context = this.context;
    if (!mounted) return;
    final newSize = MediaQuery.of(context).size;
    final isDesktop = !isMobile(context) && !isTablet(context);

    if (isDesktop) {
      _lastSize = newSize;
      return;
    }

    if (_lastSize != null &&
        ((_lastSize!.width > _lastSize!.height &&
                newSize.width < newSize.height) ||
            (_lastSize!.width < _lastSize!.height &&
                newSize.width > newSize.height))) {
      _fetchPosts();
    }
    _lastSize = newSize;
  }

  Future<void> _fetchPosts({bool reset = false}) async {
    if (reset) {
      if (!mounted) return;
      setState(() {
        _loading = true;
        _error = null;
        _cachedPosts = <Map<String, dynamic>>[];
        _lastPostDoc = null;
        _hasMore = true;
      });
    }

    await _fetchNextPage();
  }

  Future<void> _fetchNextPage() async {
    if (!_hasMore || _isLoadingMore) return;

    if (!mounted) return;
    setState(() {
      _isLoadingMore = true;
      _error = null;
    });

    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('posts')
          .orderBy('uploadDate', descending: true)
          .limit(3);

      if (_lastPostDoc != null) {
        query = query.startAfterDocument(_lastPostDoc!);
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        if (!mounted) return;
        setState(() {
          _hasMore = false;
        });
      } else {
        _lastPostDoc = snapshot.docs.last;
        // Filter out posts that are marked private. Some posts may use
        // the legacy 'isprivert' boolean field; check both.
        final publicDocs = snapshot.docs.where((d) {
          final data = d.data();
          final isPrivate =
              (data['isPrivate'] == true) || (data['isprivert'] == true);
          return !isPrivate;
        }).toList();

        final newPosts = await _mapDocsToPosts(publicDocs);

        if (!mounted) return;
        setState(() {
          (_cachedPosts ??= <Map<String, dynamic>>[]).addAll(newPosts);
        });

        if (!mounted) return;
        await _primeLikesState(newPosts);
        if (!mounted) return;
        await _primeCommentCounts(newPosts);
        if (!mounted) return;
        await _primeSavedState(newPosts);
        if (!mounted) return;
        await _primeFollowingStatus(newPosts);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 300) {
      _fetchNextPage();
    }
  }

  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('userId');
      if (!mounted) return;
      setState(() {
        _currentUserId = uid;
      });
      if (uid != null) {
        await _loadFollowingIds(uid);
      }
    } catch (_) {}
  }

  Future<void> _loadFollowingIds(String uid) async {
    try {
      final ids = await FollowService.getFollowingUserIds(uid);
      if (!mounted) return;
      setState(() {
        _followingIds
          ..clear()
          ..addAll(ids.map((e) => e.toString()));
      });
    } catch (_) {}
  }

  Future<void> _primeLikesState(List<Map<String, dynamic>> posts) async {
    if (_currentUserId == null) return;
    try {
      final futures = posts.map((p) async {
        final postId = (p['id']?.toString() ?? '').trim();
        if (postId.isEmpty) return;
        final liked = await LikeService.hasUserLikedPost(
          _currentUserId!,
          postId,
        );
        final count = await LikeService.getLikeCount(postId);
        _likedByMe[postId] = liked;
        _likeCounts[postId] = count;
      }).toList();
      await Future.wait(futures);
      if (!mounted) return;
      setState(() {});
    } catch (_) {}
  }

  Future<void> _primeCommentCounts(List<Map<String, dynamic>> posts) async {
    try {
      final futures = posts.map((p) async {
        final postId = (p['id']?.toString() ?? '').trim();
        if (postId.isEmpty) return;
        final count = await CommentService.getCommentCount(postId);
        _commentCounts[postId] = count;
      }).toList();
      await Future.wait(futures);
      if (!mounted) return;
      setState(() {});
    } catch (_) {}
  }

  Future<void> _primeFollowingStatus(List<Map<String, dynamic>> posts) async {
    if (_currentUserId == null) return;
    try {
      final futures = posts.map((p) async {
        final postOwnerId = (p['postOwnerId']?.toString() ?? '').trim();
        if (postOwnerId.isEmpty || postOwnerId == _currentUserId) return;
        final isFollowing = await _checkIfFollowing(
          _currentUserId!,
          postOwnerId,
        );
        _followingStatus[postOwnerId] = isFollowing;
      }).toList();
      await Future.wait(futures);
      if (!mounted) return;
      setState(() {});
    } catch (_) {}
  }

  Future<bool> _checkIfFollowing(String followerId, String followingId) async {
    try {
      final snapshot = await _firestore
          .collection('following')
          .where('userId', isEqualTo: followerId)
          .where('followingId', isEqualTo: followingId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _toggleFollow(String postOwnerId) async {
    if (_currentUserId == null ||
        postOwnerId.isEmpty ||
        postOwnerId == _currentUserId)
      return;

    try {
      setState(() {
        _loadingFollowUserId = postOwnerId;
      });
      final isCurrentlyFollowing = _followingStatus[postOwnerId] ?? false;

      if (isCurrentlyFollowing) {
        // Unfollow
        final snapshot = await _firestore
            .collection('following')
            .where('userId', isEqualTo: _currentUserId)
            .where('followingId', isEqualTo: postOwnerId)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          await _firestore
              .collection('following')
              .doc(snapshot.docs.first.id)
              .delete();
        }
      } else {
        // Follow
        await _firestore.collection('following').add({
          'userId': _currentUserId,
          'followingId': postOwnerId,
          'followedAt': FieldValue.serverTimestamp(),
          'postview': false,
        });
      }

      if (!mounted) return;
      setState(() {
        _followingStatus[postOwnerId] = !isCurrentlyFollowing;
        if (_followingStatus[postOwnerId] == true) {
          _followingIds.add(postOwnerId);
        } else {
          _followingIds.remove(postOwnerId);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling follow: $e');
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingFollowUserId = null;
      });
    }
  }

  Future<void> _refreshCommentCount(String postId) async {
    try {
      final count = await CommentService.getCommentCount(postId);
      if (!mounted) return;
      setState(() {
        _commentCounts[postId] = count;
      });
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> _mapDocsToPosts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    List<Future<Map<String, dynamic>>> postFutures = docs.map((doc) async {
      final postData = doc.data();
      final images = (postData['images'] ?? []) as List;

      final imageFutures = images.map((image) async {
        final String? fileId = image['files_id'];
        if (fileId == null) return null;
        final photoSnapshot = await _firestore
            .collection('photos')
            .where('files_id', isEqualTo: fileId)
            .limit(1)
            .get();
        if (photoSnapshot.docs.isNotEmpty) {
          final photoData = photoSnapshot.docs.first.data();
          final dynamic data = photoData['data'];
          if (data is String) {
            return data;
          }
          // Log or handle cases where data is not a string
          return null;
        }
        return null;
      }).toList();

      final imageDataList = await Future.wait(imageFutures);
      imageDataList.removeWhere((e) => e == null);

      Map<String, dynamic> authorData = {};
      if (postData['userId'] != null) {
        final userSnapshot = await _firestore
            .collection('users')
            .where('userId', isEqualTo: postData['userId'])
            .limit(1)
            .get();
        if (userSnapshot.docs.isNotEmpty) {
          authorData = userSnapshot.docs.first.data();
        }
      }

      return {
        'id': doc.id,
        'description': postData['description'] ?? '',
        'uploadDate': postData['uploadDate'] ?? '',
        'images': imageDataList,
        'author': authorData,
        'postOwnerId': (postData['userId'] ?? authorData['userId'])?.toString(),
      };
    }).toList();

    return await Future.wait(postFutures);
  }

  Future<void> _primeSavedState(List<Map<String, dynamic>> posts) async {
    if (_currentUserId == null || posts.isEmpty) return;
    try {
      final List<String> postIds = posts
          .map((p) => (p['id']?.toString() ?? '').trim())
          .where((id) => id.isNotEmpty)
          .toList();
      if (postIds.isEmpty) return;

      // Initialize all posts as not saved first
      for (final postId in postIds) {
        _savedByMe[postId] = false;
      }

      // Use the 'bookmark' collection for saved/bookmarked posts to match
      // the toggle implementation which writes to 'bookmark'.
      final snapshot = await _firestore
          .collection('bookmark')
          .where('userId', isEqualTo: _currentUserId)
          .where('postId', whereIn: postIds)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final postId = (data['postId']?.toString() ?? '').trim();
        if (postId.isNotEmpty) {
          _savedByMe[postId] = true;
        }
      }
      if (mounted) setState(() {});
    } catch (e) {
      // If whereIn fails (e.g., too many items), fall back to individual queries
      try {
        final List<String> postIds = posts
            .map((p) => (p['id']?.toString() ?? '').trim())
            .where((id) => id.isNotEmpty)
            .toList();

        // Initialize all as not saved
        for (final postId in postIds) {
          _savedByMe[postId] = false;
        }

        // Check each post individually against the 'bookmark' collection
        final futures = postIds.map((postId) async {
          final snapshot = await _firestore
              .collection('bookmark')
              .where('userId', isEqualTo: _currentUserId)
              .where('postId', isEqualTo: postId)
              .limit(1)
              .get();
          if (snapshot.docs.isNotEmpty) {
            _savedByMe[postId] = true;
          }
        });

        await Future.wait(futures);
        if (mounted) setState(() {});
      } catch (e2) {
        // Final fallback - just log the error
        if (kDebugMode) {
          print('Error loading saved state: $e2');
        }
      }
    }
  }

  Future<void> _toggleSave(String postId) async {
    if (_currentUserId == null || postId.isEmpty) return;
    final currentlySaved = _savedByMe[postId] ?? false;
    try {
      if (currentlySaved) {
        final snapshot = await _firestore
            .collection('bookmark')
            .where('userId', isEqualTo: _currentUserId)
            .where('postId', isEqualTo: postId)
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          await _firestore
              .collection('bookmark')
              .doc(snapshot.docs.first.id)
              .delete();
        }
      } else {
        await _firestore.collection('bookmark').add({
          'userId': _currentUserId,
          'postId': postId,
          'savedAt': FieldValue.serverTimestamp(),
        });
      }
      if (!mounted) return;
      setState(() {
        _savedByMe[postId] = !currentlySaved;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 5),
              lodingBuildbuild(context),
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Center(child: PostsViewLoading());
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_error != null) {
      return Center(child: Text("Error: $_error"));
    }
    if (_cachedPosts == null || _cachedPosts!.isEmpty) {
      return const Center(child: Text("No posts found."));
    }

    var posts = _applyFilter(_cachedPosts!);

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          TopFilterView(
            filters: const [
              'All',
              'Following',
              'My Posts',
              'With Images',
              'Without Images',
            ],
            selected: _activeFilter,
            onChanged: (f) {
              setState(() {
                _activeFilter = f;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: getResponsiveSpacing(context)),
              itemCount: posts.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= posts.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: getResponsiveSpacing(context),
                  ),
                  child: isMobile(context)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: buildPostCardFromData(posts[index]),
                        )
                      : Card(
                          margin: EdgeInsets.symmetric(
                            vertical:
                                getResponsiveSpacing(context) *
                                (isTablet(context) ? 0.2 : 0.4),
                            horizontal: isMobile(context) ? 8 : 16,
                          ),
                          elevation: isMobile(context) ? 1 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              width: 0.5,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: buildPostCardFromData(posts[index]),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> input) {
    switch (_activeFilter) {
      case 'Following':
        if (_followingIds.isEmpty) return const [];
        return input
            .where(
              (p) => _followingIds.contains(
                (p['postOwnerId']?.toString() ?? '').trim(),
              ),
            )
            .toList();
      case 'My Posts':
        final myId = _currentUserId;
        if (myId == null) return input;
        return input.where((p) => (p['author']?['userId']) == myId).toList();
      case 'With Images':
        return input.where((p) {
          final images = (p['images'] as List?) ?? [];
          return images.isNotEmpty;
        }).toList();
      case 'Without Images':
        return input.where((p) {
          final images = (p['images'] as List?) ?? [];
          return images.isEmpty;
        }).toList();
      case 'All':
      default:
        return input;
    }
  }

  Widget buildPostCardFromData(Map<String, dynamic> postData) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final author = postData['author'] as Map<String, dynamic>? ?? {};
    final imagesList = postData['images'] as List<String?>? ?? [];
    final images = imagesList.whereType<String>().toList();

    return Padding(
      padding: getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              buildUserAvatar(
                context,
                author['profileImageBase64'] != null
                    ? base64Decode(author['profileImageBase64'])
                    : Uint8List(0),
                () {},
              ),
              SizedBox(width: getResponsiveSpacing(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (author['userId'] != null) {
                          await commonNavigationbuild(
                            context,
                            UsersProfilesPage(userId: author['userId']),
                          );
                        }
                      },
                      child: Text(
                        author['name'] ?? 'Unknown User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
                          color: isDarkMode ? mainWhiteColor : mainBlackColor,
                        ),
                      ),
                    ),
                    SizedBox(height: getResponsiveSpacing(context) * 0.4),
                    Text(
                      _formatDate(postData['uploadDate']),
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(
                          context,
                          mobile: 11,
                          tablet: 12,
                          desktop: 13,
                        ),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              _buildFollowButton(postData),
              IconButton(
                icon: const Icon(Icons.more_vert_outlined),
                onPressed: () {},
                iconSize: getResponsiveFontSize(
                  context,
                  mobile: 20,
                  tablet: 24,
                  desktop: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: getResponsiveSpacing(context)),
          if ((postData['description'] as String? ?? '').isNotEmpty) ...[
            ExpandableText(
              postData['description'] as String,
              key: ValueKey('desc_${postData.hashCode}'),
              style: TextStyle(
                fontSize: getResponsiveFontSize(
                  context,
                  mobile: 13,
                  tablet: 14,
                  desktop: 15,
                ),
                color: isDarkMode ? mainWhiteColor : mainBlackColor,
                height: 1.4,
              ),
              maxLines: 2,
            ),
            SizedBox(height: getResponsiveSpacing(context)),
          ],
          if (images.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              height: getResponsiveImageHeight(context),
              child: images.length == 1
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: MemoryImage(_base64ToUint8List(images.first)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return ImageSlideGrid(imageBase64List: images);
                      },
                    ),
            ),
            SizedBox(height: getResponsiveSpacing(context)),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              LikeButton(
                postId: (postData['id']?.toString() ?? '').trim(),
                postOwnerId: (postData['postOwnerId']?.toString() ?? '').trim(),
                currentUserId: _currentUserId,
                initiallyLiked:
                    _likedByMe[(postData['id']?.toString() ?? '').trim()] ??
                    false,
                initialCount:
                    _likeCounts[(postData['id']?.toString() ?? '').trim()] ?? 0,
                onLikeChanged: (v) {
                  final id = (postData['id']?.toString() ?? '').trim();
                  setState(() {
                    _likedByMe[id] = v;
                  });
                },
                onCountChanged: (c) {
                  final id = (postData['id']?.toString() ?? '').trim();
                  setState(() {
                    _likeCounts[id] = c;
                  });
                },
              ),
              postActionButton(
                context,
                "assets/icons/comment.png",
                (_commentCounts[(postData['id']?.toString() ?? '').trim()] ?? 0)
                    .toString(),
                () async {
                  final postId = (postData['id']?.toString() ?? '').trim();
                  if (postId.isEmpty) return;
                  if (isDesktop(context)) {
                    await showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                        insetPadding: const EdgeInsets.all(24),
                        child: SizedBox(
                          width: 600,
                          child: CommentBottomSheet(
                            postId: postId,
                            postTitle: 'Comments',
                            postOwnerId:
                                (postData['postOwnerId']?.toString() ?? ''),
                          ),
                        ),
                      ),
                    );
                    await _refreshCommentCount(postId);
                  } else {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => CommentBottomSheet(
                        postId: postId,
                        postTitle: 'Comments',
                        postOwnerId:
                            (postData['postOwnerId']?.toString() ?? ''),
                      ),
                    );
                    await _refreshCommentCount(postId);
                  }
                },
              ),
              postActionButton(
                context,
                "assets/icons/sharing.png",
                "0",
                () => "0",
              ),
              const Spacer(),
              postActionBookmarkButton(
                context,
                (_savedByMe[(postData['id']?.toString() ?? '').trim()] ?? false)
                    ? "assets/icons/bookmarked.png"
                    : "assets/icons/bookmark.png",
                "",
                () {
                  final postId = (postData['id']?.toString() ?? '').trim();
                  _toggleSave(postId);
                },
                // Pass the saved state so the button can render highlighted when bookmarked
                isLiked:
                    (_savedByMe[(postData['id']?.toString() ?? '').trim()] ??
                    false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton(Map<String, dynamic> postData) {
    final postOwnerId = (postData['postOwnerId']?.toString() ?? '').trim();

    // Don't show follow button for own posts
    if (postOwnerId == _currentUserId || postOwnerId.isEmpty) {
      return SizedBox.shrink();
    }

    final isFollowing = _followingStatus[postOwnerId] ?? false;

    return _loadingFollowUserId == postOwnerId
        ? SizedBox.shrink()
        : isFollowing
        ? SizedBox.shrink()
        : commonElevatedButtonFollowPostsButtonbuild(
            context,
            "Follow",
            () => _toggleFollow(postOwnerId),
          );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';

    try {
      if (date is Timestamp) {
        DateTime dateTime = date.toDate();
        Duration difference = DateTime.now().difference(dateTime);

        if (difference.inDays > 0) {
          return '${difference.inDays}d ago';
        } else if (difference.inHours > 0) {
          return '${difference.inHours}h ago';
        } else if (difference.inMinutes > 0) {
          return '${difference.inMinutes}m ago';
        } else {
          return 'Just now';
        }
      }
      return date.toString();
    } catch (e) {
      return '';
    }
  }

  Uint8List _base64ToUint8List(String base64String) {
    try {
      return Uint8List.fromList(base64.decode(base64String));
    } catch (e) {
      if (kDebugMode) {
        print('Error decoding base64: $e');
      }
      return Uint8List(0);
    }
  }
}
