import 'dart:convert';
import 'dart:typed_data';
import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/auth/users_profiles.dart';
import 'package:everesports/core/page/home/widget/ExpandableText.dart';
import 'package:everesports/core/page/home/widget/action_button_posts.dart';
import 'package:everesports/core/page/home/widget/image_slide_grid.dart';
import 'package:everesports/core/page/home/widget/posts_view_loading.dart';
import 'package:everesports/core/page/home/widget/user_avatar_posts.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostDisplayPage extends StatefulWidget {
  const PostDisplayPage({super.key});

  @override
  State<PostDisplayPage> createState() => _PostDisplayPageState();
}

class _PostDisplayPageState extends State<PostDisplayPage>
    with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Used to prevent refresh on desktop/tab resize
  Size? _lastSize;
  List<Map<String, dynamic>>? _cachedPosts;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchPosts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Only refresh on mobile/tablet orientation change, not on desktop resize
  @override
  void didChangeMetrics() {
    final context = this.context;
    if (!mounted) return;
    final newSize = MediaQuery.of(context).size;
    final isDesktop = !isMobile(context) && !isTablet(context);

    // On desktop, do not refresh on resize
    if (isDesktop) {
      _lastSize = newSize;
      return;
    }

    // On mobile/tablet, refresh only if orientation changes
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

  // Fetch posts with images and author info
  Future<List<Map<String, dynamic>>> fetchPostsWithImages() async {
    QuerySnapshot postsSnapshot = await _firestore
        .collection('posts')
        .orderBy('uploadDate')
        .get();

    // Prepare futures for all posts
    List<Future<Map<String, dynamic>>> postFutures = postsSnapshot.docs.map((
      doc,
    ) async {
      var postData = doc.data() as Map<String, dynamic>;
      List images = postData['images'] ?? [];

      // Fetch all images in parallel
      List<Future<String?>> imageFutures = images.map((image) async {
        String fileId = image['files_id'];

        QuerySnapshot photoSnapshot = await _firestore
            .collection('photos')
            .where('files_id', isEqualTo: fileId)
            .limit(1)
            .get();

        if (photoSnapshot.docs.isNotEmpty) {
          var photoData =
              photoSnapshot.docs.first.data() as Map<String, dynamic>;
          return photoData['data'] as String;
        }
        return null;
      }).toList();

      List<String?> imageDataList = await Future.wait(imageFutures);
      imageDataList.removeWhere((e) => e == null);

      // ✅ Fetch author info using userId
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
        "description": postData['description'] ?? '',
        "uploadDate": postData['uploadDate'] ?? '',
        "images": imageDataList,
        "author": authorData, // contains name, profileImageBase64, etc.
      };
    }).toList();

    // Wait for all posts to finish
    return await Future.wait(postFutures);
  }

  @override
  Widget build(BuildContext context) {
    // Use cached posts and loading state to prevent refresh on desktop/tab resize
    if (_loading) {
      return const Center(child: PostsViewLoading());
    }
    if (_error != null) {
      return Center(child: Text("Error: $_error"));
    }
    if (_cachedPosts == null || _cachedPosts!.isEmpty) {
      return const Center(child: Text("No posts found."));
    }

    var posts = _cachedPosts!;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: getResponsiveSpacing(context)),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: getResponsiveSpacing(context)),
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
    );
  }

  Widget buildPostCardFromData(postData) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final author = postData['author'] as Map<String, dynamic>? ?? {};
    // Fix: Properly handle List<String?> and filter out nulls
    final imagesList = postData['images'] as List<String?>? ?? [];
    final images = imagesList.whereType<String>().toList();

    return Padding(
      padding: getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              buildUserAvatar(
                context,
                base64Decode(author['profileImageBase64']),
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
                    SizedBox(height: getResponsiveSpacing(context) * 0.5),
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

          // Post description with expand/collapse
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

          // Images/Videos
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

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              postActionButton(
                context,
                "assets/icons/favorite.png",
                "0",
                () => "0",
              ),
              postActionButton(
                context,
                "assets/icons/comment.png",
                "0",
                () => "0",
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
