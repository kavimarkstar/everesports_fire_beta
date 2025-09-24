import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/auth/home/login_home.dart';
import 'package:everesports/core/auth/services/auth_service.dart';
import 'package:everesports/core/page/spark/comment_box.dart';
import 'package:everesports/core/page/spark/widget/all_widget.dart';
import 'package:everesports/core/page/spark/widget/build_Error_State.dart';
import 'package:everesports/core/page/spark/widget/build_Spark_Skeleton.dart';
import 'package:everesports/core/page/spark/widget/SparkItemWidget.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SparkPage extends StatefulWidget {
  const SparkPage({Key? key}) : super(key: key);

  @override
  _SparkPageState createState() => _SparkPageState();
}

class _SparkPageState extends State<SparkPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, Map<String, dynamic>> _userCache = {};
  final DateFormat _timestampFormat = DateFormat('MMM dd, yyyy • HH:mm');

  // Track which spark descriptions and titles are expanded
  final Set<String> _expandedSparkIds = {};
  final Set<String> _expandedTitleSparkIds = {};

  final Map<String, int> _localComments = {};

  // Track comments dialog state
  bool _isCommentsDialogOpen = false;
  String? _selectedSparkId;

  // Store the initial spark data to prevent unnecessary rebuilds
  List<QueryDocumentSnapshot>? _cachedSparks;

  // User session variables
  String? _userId;
  String? _docId;

  // Like/Dislike tracking
  final Map<String, bool> _likedSparks = {};
  final Map<String, bool> _dislikedSparks = {};
  final Map<String, int> _likeCounts = {};
  final Map<String, int> _dislikeCounts = {};

  @override
  void initState() {
    super.initState();
    _checkSessionAndFetch();
  }

  // Check user session and fetch user data
  Future<void> _checkSessionAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId');

    if (savedUserId == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginHomePage()),
      );
      return;
    }

    _userId = savedUserId;

    try {
      final docId = await AuthServiceFireBase.getDocIdByUserId(_userId!);
      if (docId == null) {
        await prefs.remove('userId');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginHomePage()),
        );
        return;
      }

      _docId = docId;
      await _connectAndFetchUser(_docId!);
      await _loadUserLikesDislikes();
    } catch (e) {
      await prefs.remove('userId');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginHomePage()),
      );
    }
  }

  // Connect and fetch user data
  Future<void> _connectAndFetchUser(String docId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(docId).get();
      if (userDoc.exists) {
        // User data loaded successfully
        setState(() {
          // Trigger rebuild with authenticated state
        });
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
    }
  }

  // Load user's likes and dislikes
  Future<void> _loadUserLikesDislikes() async {
    if (_userId == null) return;

    try {
      // Load likes
      final likesSnapshot = await _firestore
          .collection('spark_likes')
          .where('userId', isEqualTo: _userId)
          .get();

      for (var doc in likesSnapshot.docs) {
        final data = doc.data();
        final postId = data['postId'] as String?;
        if (postId != null) {
          _likedSparks[postId] = true;
        }
      }

      // Load dislikes
      final dislikesSnapshot = await _firestore
          .collection('spark_dislikes')
          .where('userId', isEqualTo: _userId)
          .get();

      for (var doc in dislikesSnapshot.docs) {
        final data = doc.data();
        final postId = data['postId'] as String?;
        if (postId != null) {
          _dislikedSparks[postId] = true;
        }
      }

      setState(() {});
    } catch (e) {
      debugPrint("Error loading likes/dislikes: $e");
    }
  }

  // Get like count for a spark
  Future<int> _getLikeCount(String sparkId) async {
    if (_likeCounts.containsKey(sparkId)) {
      return _likeCounts[sparkId]!;
    }

    try {
      final snapshot = await _firestore
          .collection('spark_likes')
          .where('postId', isEqualTo: sparkId)
          .get();

      final count = snapshot.docs.length;
      _likeCounts[sparkId] = count;
      return count;
    } catch (e) {
      debugPrint("Error getting like count: $e");
      return 0;
    }
  }

  // Get dislike count for a spark
  Future<int> _getDislikeCount(String sparkId) async {
    if (_dislikeCounts.containsKey(sparkId)) {
      return _dislikeCounts[sparkId]!;
    }

    try {
      final snapshot = await _firestore
          .collection('spark_dislikes')
          .where('postId', isEqualTo: sparkId)
          .get();

      final count = snapshot.docs.length;
      _dislikeCounts[sparkId] = count;
      return count;
    } catch (e) {
      debugPrint("Error getting dislike count: $e");
      return 0;
    }
  }

  // Handle like action
  Future<void> _handleLike(String sparkId, String postOwnerId) async {
    if (_userId == null) return;

    try {
      final isCurrentlyLiked = _likedSparks[sparkId] == true;
      final isCurrentlyDisliked = _dislikedSparks[sparkId] == true;

      // If currently disliked, remove dislike first
      if (isCurrentlyDisliked) {
        await _removeDislike(sparkId);
      }

      if (isCurrentlyLiked) {
        // Remove like
        await _removeLike(sparkId);
      } else {
        // Add like
        await _addLike(sparkId, postOwnerId);
      }
    } catch (e) {
      debugPrint("Error handling like: $e");
    }
  }

  // Handle dislike action
  Future<void> _handleDislike(String sparkId, String postOwnerId) async {
    if (_userId == null) return;

    try {
      final isCurrentlyLiked = _likedSparks[sparkId] == true;
      final isCurrentlyDisliked = _dislikedSparks[sparkId] == true;

      // If currently liked, remove like first
      if (isCurrentlyLiked) {
        await _removeLike(sparkId);
      }

      if (isCurrentlyDisliked) {
        // Remove dislike
        await _removeDislike(sparkId);
      } else {
        // Add dislike
        await _addDislike(sparkId, postOwnerId);
      }
    } catch (e) {
      debugPrint("Error handling dislike: $e");
    }
  }

  void _openComments(String sparkId) async {
    if (_userId == null) return;

    if (!isMobile(context) && !isTablet(context)) {
      setState(() {
        _selectedSparkId = sparkId;
      });
      return;
    }

    if (_isCommentsDialogOpen) return;
    _isCommentsDialogOpen = true;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Material(
              color: isDarkMode ? secondBlackColor : secondWhiteGrayColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  AppBar(
                    title: const Text('Comments'),
                    automaticallyImplyLeading: false,
                    backgroundColor: isDarkMode
                        ? secondBlackColor
                        : secondWhiteGrayColor,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: CommentBox(
                      postId: sparkId,
                      currentUserId: _userId!,
                      onCommentAdded: () {
                        setState(() {
                          _localComments[sparkId] =
                              (_localComments[sparkId] ?? 0) + 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    _isCommentsDialogOpen = false;
  }

  // Add like to Firestore
  Future<void> _addLike(String sparkId, String postOwnerId) async {
    try {
      await _firestore.collection('spark_likes').add({
        'userId': _userId,
        'postId': sparkId,
        'postOwnerId': postOwnerId,
        'createdAt': DateTime.now().toIso8601String(),
      });

      setState(() {
        _likedSparks[sparkId] = true;
        _likeCounts[sparkId] = (_likeCounts[sparkId] ?? 0) + 1;
      });
    } catch (e) {
      debugPrint("Error adding like: $e");
    }
  }

  // Remove like from Firestore
  Future<void> _removeLike(String sparkId) async {
    try {
      final snapshot = await _firestore
          .collection('spark_likes')
          .where('userId', isEqualTo: _userId)
          .where('postId', isEqualTo: sparkId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _likedSparks[sparkId] = false;
        _likeCounts[sparkId] = (_likeCounts[sparkId] ?? 1) - 1;
      });
    } catch (e) {
      debugPrint("Error removing like: $e");
    }
  }

  // Add dislike to Firestore
  Future<void> _addDislike(String sparkId, String postOwnerId) async {
    try {
      await _firestore.collection('spark_dislikes').add({
        'userId': _userId,
        'postId': sparkId,
        'postOwnerId': postOwnerId,
        'createdAt': DateTime.now().toIso8601String(),
      });

      setState(() {
        _dislikedSparks[sparkId] = true;
        _dislikeCounts[sparkId] = (_dislikeCounts[sparkId] ?? 0) + 1;
      });
    } catch (e) {
      debugPrint("Error adding dislike: $e");
    }
  }

  // Remove dislike from Firestore
  Future<void> _removeDislike(String sparkId) async {
    try {
      final snapshot = await _firestore
          .collection('spark_dislikes')
          .where('userId', isEqualTo: _userId)
          .where('postId', isEqualTo: sparkId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _dislikedSparks[sparkId] = false;
        _dislikeCounts[sparkId] = (_dislikeCounts[sparkId] ?? 1) - 1;
      });
    } catch (e) {
      debugPrint("Error removing dislike: $e");
    }
  }

  // Fetch user data from Firestore
  Future<Map<String, dynamic>?> _fetchUser(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }

    try {
      final querySnapshot = await _firestore
          .collection("users")
          .where("userId", isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        _userCache[userId] = userData;
        return userData;
      }
    } catch (e) {
      debugPrint("Error fetching user $userId: $e");
    }

    return null;
  }

  // Build individual spark item as a separate widget to isolate rebuilds
  Widget _buildSparkItem(QueryDocumentSnapshot sparkDoc) {
    final sparkData = sparkDoc.data() as Map<String, dynamic>;
    final title = sparkData["title"] ?? "No Title";
    final description = sparkData["description"] ?? "No Description";
    final userId = sparkData["user_id"] ?? "";
    final timestamp = sparkData["timestamp"] as Timestamp?;

    final comments = _localComments.containsKey(sparkDoc.id)
        ? _localComments[sparkDoc.id]!
        : (sparkData["comments"] as num?)?.toInt() ?? 0;

    final sparkId = sparkDoc.id;
    final isExpanded = _expandedSparkIds.contains(sparkId);
    final isTitleExpanded = _expandedTitleSparkIds.contains(sparkId);

    // Title truncation logic
    const int maxTitleLength = 30;
    final bool shouldTruncateTitle = title.length > maxTitleLength;
    final String truncatedTitle = shouldTruncateTitle
        ? title.substring(0, maxTitleLength) + '...'
        : title;

    // Description truncation logic
    const int maxLines = 3;
    final bool shouldTruncate =
        description.length > 120 ||
        '\n'.allMatches(description).length >= maxLines;
    final String truncatedDescription = description.length > 120
        ? description.substring(0, 120) + '...'
        : description;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUser(userId),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return buildSparkSkeleton();
        }

        final userData = userSnapshot.data;
        final username = userData?["username"] ?? "Unknown User";
        final profileBase64 = userData?["profileImageBase64"];
        final name = userData?["name"] ?? "";

        return FutureBuilder<List<int>>(
          future: Future.wait([
            _getLikeCount(sparkId),
            _getDislikeCount(sparkId),
          ]),
          builder: (context, countsSnapshot) {
            final likesCount = countsSnapshot.data?[0] ?? 0;
            final dislikesCount = countsSnapshot.data?[1] ?? 0;

            return SparkItemWidget(
              sparkId: sparkId,
              profileBase64: profileBase64,
              name: name,
              username: username,
              timestamp: timestamp,
              title: title,
              description: description,
              truncatedTitle: truncatedTitle,
              truncatedDescription: truncatedDescription,
              shouldTruncateTitle: shouldTruncateTitle,
              shouldTruncate: shouldTruncate,
              isTitleExpanded: isTitleExpanded,
              isExpanded: isExpanded,
              comments: comments,

              // Like/Dislike data
              likesCount: likesCount,
              dislikesCount: dislikesCount,
              isLiked: _likedSparks[sparkId] == true,
              isDisliked: _dislikedSparks[sparkId] == true,

              onTitleExpand: () {
                setState(() {
                  if (_expandedTitleSparkIds.contains(sparkId)) {
                    _expandedTitleSparkIds.remove(sparkId);
                  } else {
                    _expandedTitleSparkIds.add(sparkId);
                  }
                });
              },
              onDescriptionExpand: () {
                setState(() {
                  if (_expandedSparkIds.contains(sparkId)) {
                    _expandedSparkIds.remove(sparkId);
                  } else {
                    _expandedSparkIds.add(sparkId);
                  }
                });
              },
              onComment: () => _openComments(sparkId),
              onLike: () => _handleLike(sparkId, userId),
              onDislike: () => _handleDislike(sparkId, userId),
              timestampFormat: _timestampFormat,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isMobile(context) ? AppBar(title: const Text("Spark")) : null,
      body: Row(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection("spark")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return buildLoadingState();
                }

                if (snapshot.hasError) {
                  return buildErrorState(snapshot.error.toString());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return buildEmptyState();
                }

                final sparks = snapshot.data!.docs;

                // Cache the sparks to prevent unnecessary rebuilds
                if (_cachedSparks == null) {
                  _cachedSparks = sparks;
                }

                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: ListView.builder(
                    key: const PageStorageKey<String>(
                      'spark_list',
                    ), // Preserve scroll position
                    padding: const EdgeInsets.all(12),
                    itemCount: sparks.length,
                    itemBuilder: (context, index) {
                      final sparkDoc = sparks[index];
                      return _buildSparkItem(sparkDoc);
                    },
                  ),
                );
              },
            ),
          ),
          if (!isMobile(context))
            if (!isTablet(context))
              SizedBox(
                width: 420,
                child: _selectedSparkId != null && _userId != null
                    ? CommentBox(
                        postId: _selectedSparkId!,
                        currentUserId: _userId!,
                        onCommentAdded: () {
                          setState(() {
                            _localComments[_selectedSparkId!] =
                                (_localComments[_selectedSparkId!] ?? 0) + 1;
                          });
                        },
                      )
                    : const Center(
                        child: Text(
                          'Select a post to view comments',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
        ],
      ),
    );
  }
}
