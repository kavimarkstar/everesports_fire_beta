import 'package:everesports/Theme/colors.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class CommentBox extends StatefulWidget {
  final String postId;
  final String currentUserId;
  final VoidCallback? onCommentAdded;

  CommentBox({
    Key? key,
    required this.postId,
    required this.currentUserId,
    this.onCommentAdded,
  }) : super(key: key);

  @override
  _CommentBoxState createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, Map<String, dynamic>> _userCache = {};

  Future<Map<String, dynamic>?> _fetchUser(String userId) async {
    if (_userCache.containsKey(userId)) return _userCache[userId];
    try {
      final snap = await _firestore
          .collection('users')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final data = snap.docs.first.data();
        _userCache[userId] = data;
        return data;
      }
    } catch (e) {
      debugPrint('Failed to fetch user $userId: $e');
    }
    return null;
  }

  Widget _buildProfileImage(String? profileBase64) {
    if (profileBase64 != null && profileBase64.isNotEmpty) {
      try {
        return CircleAvatar(
          backgroundColor: Colors.transparent,
          child: ClipOval(child: Image.memory(base64Decode(profileBase64))),
        );
      } catch (_) {}
    }
    return const CircleAvatar(child: Icon(Icons.person));
  }

  Future<void> _addComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      await _firestore.collection('spark_comments').add({
        'userId': widget.currentUserId,
        'postId': widget.postId,
        'content': text,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'parentId': null,
      });

      _controller.clear();
      widget.onCommentAdded?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add comment: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isMobile(context)
        ? commentBoxbuild(context)
        : Card(
            margin: const EdgeInsets.all(12),
            elevation: 2,
            child: commentBoxbuild(context),
          );
  }

  Widget commentBoxbuild(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (!isMobile(context))
            const Text(
              "Comments",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          if (!isMobile(context)) const Divider(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('spark_comments')
                  .where('postId', isEqualTo: widget.postId)
                  // Client-side sort to avoid requiring a composite index
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = List<QueryDocumentSnapshot>.from(
                  snapshot.data?.docs ?? [],
                );
                // Sort by createdAt descending; supports Timestamp or String ISO8601
                docs.sort((a, b) {
                  final ad = a.data() as Map<String, dynamic>;
                  final bd = b.data() as Map<String, dynamic>;
                  final av = ad['createdAt'];
                  final bv = bd['createdAt'];
                  DateTime adt;
                  DateTime bdt;
                  if (av is Timestamp) {
                    adt = av.toDate();
                  } else if (av is String) {
                    adt =
                        DateTime.tryParse(av) ??
                        DateTime.fromMillisecondsSinceEpoch(0);
                  } else {
                    adt = DateTime.fromMillisecondsSinceEpoch(0);
                  }
                  if (bv is Timestamp) {
                    bdt = bv.toDate();
                  } else if (bv is String) {
                    bdt =
                        DateTime.tryParse(bv) ??
                        DateTime.fromMillisecondsSinceEpoch(0);
                  } else {
                    bdt = DateTime.fromMillisecondsSinceEpoch(0);
                  }
                  return bdt.compareTo(adt);
                });
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No comments yet. Be the first to comment!",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  reverse: false,
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final content = data['content'] as String? ?? '';
                    final userId = data['userId'] as String? ?? '';
                    final createdRaw = data['createdAt'];
                    DateTime? created;
                    if (createdRaw is Timestamp) created = createdRaw.toDate();
                    if (createdRaw is String)
                      created = DateTime.tryParse(createdRaw);

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _fetchUser(userId),
                      builder: (context, userSnap) {
                        final user = userSnap.data;
                        final name = user?['name'] as String? ?? userId;
                        final avatar = user?['profileImageBase64'] as String?;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.transparent,
                          shadowColor: Colors.transparent,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: _buildProfileImage(avatar),
                              ),
                              Expanded(
                                child: ListTile(
                                  subtitle: Card(
                                    color: isDark
                                        ? Color(0xff292929)
                                        : Color(0xffebebeb),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: mainColor,
                                            ),
                                          ),
                                          Text(
                                            content,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                          if (created != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              child: Text(
                                                created.toLocal().toString(),
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? mainBlackColor : secondWhiteGrayColor,
              borderRadius: BorderRadius.circular(isMobile(context) ? 50 : 16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          isMobile(context) ? 50 : 16,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Add a comment...",

                      hintStyle: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: Theme.of(context).hintColor),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      fillColor: Colors.transparent,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Material(
                  color: mainColor,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _addComment,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(Icons.send, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
