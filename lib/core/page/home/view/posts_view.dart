import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/auth/users_profiles.dart';
import 'package:everesports/core/page/home/model/post.dart';
import 'package:everesports/core/page/home/widget/ExpandableText.dart';
import 'package:everesports/core/page/home/widget/action_button_posts.dart';
import 'package:everesports/core/page/home/widget/posts_view_loading.dart';
import 'package:everesports/core/page/home/widget/user_avatar_posts.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:everesports/widget/common_snackbar.dart';
import 'package:flutter/services.dart';
import 'package:everesports/language/controller/all_language.dart';

class PostsView extends StatefulWidget {
  const PostsView({super.key});

  @override
  State<PostsView> createState() => _PostsViewState();
}

class _PostsViewState extends State<PostsView> {
  List<Post> posts = [];
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>>? postsData;

  // Like system state
  final Map<String, bool> _userLikedPosts = {};
  final Map<String, int> _postLikeCounts = {};
  final Map<String, int> _postCommentCounts = {};

  // Map to track share counts in state
  Map<String, int> _postShareCounts = {};

  // Bookmark system state
  final Map<String, bool> _userBookmarkedPosts = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final data = await fetchPostsWithImages();

      setState(() {
        postsData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
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
    if (isLoading) {
      return const Center(child: PostsViewLoading());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            ElevatedButton(onPressed: _loadPosts, child: Text('Retry')),
          ],
        ),
      );
    }

    if (postsData == null || postsData!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty state icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.feed_outlined,
                  size: 64,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Main message
              Text(
                getNoPostsYet(context),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? mainWhiteColor
                      : mainBlackColor,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                getBeFirstToShare(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadPosts,
                    icon: const Icon(Icons.refresh),
                    label: Text(getRefresh(context)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to upload page or show upload dialog
                      commonSnackBarbuild(
                        context,
                        getUploadComingSoon(context),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(getCreatePost(context)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Convert raw post data to Post objects for display
    List<Widget> postWidgets = postsData!.map((postData) {
      return Padding(
        padding: EdgeInsets.only(bottom: getResponsiveSpacing(context)),
        child: isMobile(context)
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _buildPostCardFromData(postData),
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
                child: _buildPostCardFromData(postData),
              ),
      );
    }).toList();

    // Responsive layout for all devices
    if (isMobile(context)) {
      return Column(children: postWidgets);
    } else {
      return Column(children: postWidgets);
    }
  }

  Widget _buildPostCardFromData(Map<String, dynamic> postData) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final author = postData['author'] as Map<String, dynamic>? ?? {};
    final images = postData['images'] as List<String>? ?? [];

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
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: MemoryImage(
                                _base64ToUint8List(images[index]),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
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
