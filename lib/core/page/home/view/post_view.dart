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
import 'package:everesports/widget/common_navigation.dart';
import 'package:everesports/core/page/home/view/comment_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:everesports/core/page/home/service/like_service.dart';

class PostDisplayPage extends StatefulWidget {
  const PostDisplayPage({super.key});

  @override
  State<PostDisplayPage> createState() => _PostDisplayPageState();
}

class _PostDisplayPageState extends State<PostDisplayPage>
    with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Size? _lastSize;
  List<Map<String, dynamic>>? _cachedPosts;
  bool _loading = true;
  String? _error;
  String _activeFilter = 'All';
  String? _currentUserId;
  final Map<String, bool> _likedByMe = {};
  final Map<String, int> _likeCounts = {};
  final Map<String, int> _commentCounts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserId().then((_) => _fetchPosts());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

  Future<void> _fetchPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final posts = await fetchPostsWithImages();
      if (mounted) {
        setState(() {
          _cachedPosts = posts;
          _loading = false;
        });
        await _primeLikesState(posts);
        await _primeCommentCounts(posts);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
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

  Future<void> _refreshCommentCount(String postId) async {
    try {
      final count = await CommentService.getCommentCount(postId);
      if (!mounted) return;
      setState(() {
        _commentCounts[postId] = count;
      });
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> fetchPostsWithImages() async {
    QuerySnapshot postsSnapshot = await _firestore
        .collection('posts')
        .orderBy('uploadDate', descending: true)
        .get();

    List<Future<Map<String, dynamic>>> postFutures = postsSnapshot.docs.map((
      doc,
    ) async {
      var postData = doc.data() as Map<String, dynamic>;
      List images = postData['images'] ?? [];

      List<Future<String?>> imageFutures = images.map((image) async {
        String? fileId = image['files_id'];
        if (fileId == null) return null;
        QuerySnapshot photoSnapshot = await _firestore
            .collection('photos')
            .where('files_id', isEqualTo: fileId)
            .limit(1)
            .get();

        if (photoSnapshot.docs.isNotEmpty) {
          var photoData =
              photoSnapshot.docs.first.data() as Map<String, dynamic>;
          return photoData['data'] as String?;
        }
        return null;
      }).toList();

      List<String?> imageDataList = await Future.wait(imageFutures);
      imageDataList.removeWhere((e) => e == null);

      Map<String, dynamic> authorData = {};
      if (postData['userId'] != null) {
        QuerySnapshot userSnapshot = await _firestore
            .collection('users')
            .where('userId', isEqualTo: postData['userId'])
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          authorData = userSnapshot.docs.first.data() as Map<String, dynamic>;
        }
      }

      return {
        "id": doc.id,
        "description": postData['description'] ?? '',
        "uploadDate": postData['uploadDate'] ?? '',
        "images": imageDataList,
        "author": authorData,
        "postOwnerId": (postData['userId'] ?? authorData['userId'])?.toString(),
      };
    }).toList();

    return await Future.wait(postFutures);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Column(
                children: [lodingBuildbuild(context), PostsViewLoading()],
              );
            },
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
            filters: const ['All', 'My Posts', 'With Images', 'Without Images'],
            selected: _activeFilter,
            onChanged: (f) {
              setState(() {
                _activeFilter = f;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: getResponsiveSpacing(context)),
              itemCount: posts.length,
              itemBuilder: (context, index) {
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
                "assets/icons/bookmark.png",
                "",
                () => "",
              ),
            ],
          ),
        ],
      ),
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
