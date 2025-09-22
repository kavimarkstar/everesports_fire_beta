import 'dart:convert';
import 'package:everesports/core/page/spark/widget/all_widget.dart';
import 'package:everesports/core/page/spark/widget/build_Error_State.dart';
import 'package:everesports/core/page/spark/widget/build_Reaction_Button.dart';
import 'package:everesports/core/page/spark/widget/build_Spark_Skeleton.dart';
import 'package:everesports/core/page/spark/widget/share_Spark.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  // Track local reaction counts to avoid page refresh
  final Map<String, int> _localLikes = {};
  final Map<String, int> _localDislikes = {};
  final Map<String, int> _localComments = {};

  // Track which sparks the user has already reacted to in this session
  final Set<String> _likedSparks = {};
  final Set<String> _dislikedSparks = {};

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

  Widget _buildProfileImage(String? profileBase64) {
    if (profileBase64 != null && profileBase64.isNotEmpty) {
      try {
        return CircleAvatar(
          radius: 20,
          backgroundImage: MemoryImage(base64Decode(profileBase64)),
        );
      } catch (e) {
        debugPrint("Error decoding profile image: $e");
      }
    }
    return const CircleAvatar(
      radius: 20,
      backgroundColor: Colors.deepPurple,
      child: Icon(Icons.person, size: 20, color: Colors.white),
    );
  }

  // Handle reaction updates (locally and in Firestore, but don't refresh page)
  void _handleReaction(String docId, String type, int currentCount) {
    // Prevent multiple likes/dislikes in one session
    if (type == "likes" && _likedSparks.contains(docId)) return;
    if (type == "dislikes" && _dislikedSparks.contains(docId)) return;

    // Update local state immediately for instant UI feedback
    setState(() {
      if (type == "likes") {
        _localLikes[docId] = (currentCount + 1);
        _likedSparks.add(docId);
      } else if (type == "dislikes") {
        _localDislikes[docId] = (currentCount + 1);
        _dislikedSparks.add(docId);
      }
    });

    // Update Firestore in the background without triggering setState on completion
    _firestore
        .collection("spark")
        .doc(docId)
        .update({type: currentCount + 1})
        .catchError((error) {
          debugPrint("Error updating reaction: $error");
          // Revert local changes if Firestore update fails
          setState(() {
            if (type == "likes") {
              _localLikes.remove(docId);
              _likedSparks.remove(docId);
            } else if (type == "dislikes") {
              _localDislikes.remove(docId);
              _dislikedSparks.remove(docId);
            }
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isMobile(context)
          ? AppBar(title: const Text("Spark Social"))
          : null,
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

                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: sparks.length,
                    itemBuilder: (context, index) {
                      final sparkDoc = sparks[index];
                      final sparkData = sparkDoc.data() as Map<String, dynamic>;
                      final title = sparkData["title"] ?? "No Title";
                      final description =
                          sparkData["description"] ?? "No Description";
                      final userId = sparkData["user_id"] ?? "";
                      final timestamp = sparkData["timestamp"] as Timestamp?;

                      // Use local state for likes/dislikes/comments if available
                      final likes = _localLikes.containsKey(sparkDoc.id)
                          ? _localLikes[sparkDoc.id]!
                          : (sparkData["likes"] as num?)?.toInt() ?? 0;
                      final dislikes = _localDislikes.containsKey(sparkDoc.id)
                          ? _localDislikes[sparkDoc.id]!
                          : (sparkData["dislikes"] as num?)?.toInt() ?? 0;
                      final comments = _localComments.containsKey(sparkDoc.id)
                          ? _localComments[sparkDoc.id]!
                          : (sparkData["comments"] as num?)?.toInt() ?? 0;

                      // Use sparkDoc.id as unique identifier for expansion
                      final sparkId = sparkDoc.id;
                      final isExpanded = _expandedSparkIds.contains(sparkId);
                      final isTitleExpanded = _expandedTitleSparkIds.contains(
                        sparkId,
                      );

                      // Title truncation logic
                      const int maxTitleLength = 30;
                      final bool shouldTruncateTitle =
                          title.length > maxTitleLength;
                      final String truncatedTitle = shouldTruncateTitle
                          ? title.substring(0, maxTitleLength) + '...'
                          : title;

                      // Description truncation logic
                      const int maxLines = 3;
                      final bool shouldTruncate =
                          description.length > 120 ||
                          '\n'.allMatches(description).length >= maxLines;
                      final String truncatedDescription =
                          description.length > 120
                          ? description.substring(0, 120) + '...'
                          : description;

                      return FutureBuilder<Map<String, dynamic>?>(
                        future: _fetchUser(userId),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return buildSparkSkeleton();
                          }

                          final userData = userSnapshot.data;
                          final username =
                              userData?["username"] ?? "Unknown User";
                          final profileBase64 = userData?["profileImageBase64"];
                          final name = userData?["name"] ?? "";

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // User info header
                                  Row(
                                    children: [
                                      _buildProfileImage(profileBase64),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              username,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (timestamp != null)
                                        Text(
                                          _timestampFormat.format(
                                            timestamp.toDate(),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),

                                      IconButton(
                                        onPressed: () {
                                          //todo
                                        },
                                        icon: Icon(Icons.more_vert),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Spark content
                                  if (title.isNotEmpty && title != "No Title")
                                    Builder(
                                      builder: (context) {
                                        if (!shouldTruncateTitle ||
                                            isTitleExpanded) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              if (shouldTruncateTitle &&
                                                  isTitleExpanded)
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero,
                                                    minimumSize: Size(0, 0),
                                                    tapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _expandedTitleSparkIds
                                                          .remove(sparkId);
                                                    });
                                                  },
                                                  child: const Text(
                                                    "See less",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.deepPurple,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        } else {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                truncatedTitle,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: Size(0, 0),
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _expandedTitleSparkIds.add(
                                                      sparkId,
                                                    );
                                                  });
                                                },
                                                child: const Text(
                                                  "See more",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.deepPurple,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  if (title.isNotEmpty && title != "No Title")
                                    const SizedBox(height: 8),
                                  Builder(
                                    builder: (context) {
                                      if (!shouldTruncate || isExpanded) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              description,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            if (shouldTruncate && isExpanded)
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: Size(0, 0),
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _expandedSparkIds.remove(
                                                      sparkId,
                                                    );
                                                  });
                                                },
                                                child: const Text(
                                                  "See less",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.deepPurple,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              truncatedDescription,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                              maxLines: maxLines,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size(0, 0),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _expandedSparkIds.add(
                                                    sparkId,
                                                  );
                                                });
                                              },
                                              child: const Text(
                                                "See more",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.deepPurple,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Actions row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      buildReactionButton(
                                        icon: Icons.thumb_up_outlined,
                                        count: likes,
                                        onPressed:
                                            _likedSparks.contains(sparkDoc.id)
                                            ? null
                                            : () => _handleReaction(
                                                sparkDoc.id,
                                                "likes",
                                                likes,
                                              ),
                                      ),
                                      buildReactionButton(
                                        icon: Icons.thumb_down_outlined,
                                        count: dislikes,
                                        onPressed:
                                            _dislikedSparks.contains(
                                              sparkDoc.id,
                                            )
                                            ? null
                                            : () => _handleReaction(
                                                sparkDoc.id,
                                                "dislikes",
                                                dislikes,
                                              ),
                                      ),
                                      buildReactionButton(
                                        icon: Icons.comment_rounded,
                                        count: comments,
                                        onPressed: () {
                                          showComments(
                                            context,
                                            sparkDoc.id,
                                            username,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.share),
                                        onPressed: () {
                                          shareSpark(
                                            context as String,
                                            title,
                                            description,
                                            username,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
