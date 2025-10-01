import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/core/auth/home/login_home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widget/gridview.dart';
import 'package:everesports/core/page/singal_posts/singal_posts.dart';

class CurantLoginUserPostsView extends StatefulWidget {
  const CurantLoginUserPostsView({super.key});

  @override
  State<CurantLoginUserPostsView> createState() =>
      _CurantLoginUserPostsViewState();
}

class _CurantLoginUserPostsViewState extends State<CurantLoginUserPostsView> {
  String? _userId;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _posts = [];
  bool _disposed = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _postsSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _disposed = true;
    _postsSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId');
    if (savedUserId == null || savedUserId.isEmpty) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginHomePage()),
      );
      return;
    }
    _userId = savedUserId;
    await _fetchUserPosts();
    _startPostsListener();
  }

  void _startPostsListener() {
    if (_userId == null) return;
    _postsSub?.cancel();
    _postsSub = FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .listen((snapshot) async {
          if (_disposed || !mounted) return;
          // Rebuild list from snapshot for simplicity
          await _fetchUserPosts();
        });
  }

  DateTime _toDateTime(dynamic ts) {
    if (ts == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (ts is Timestamp) return ts.toDate();
    if (ts is DateTime) return ts;
    if (ts is String)
      return DateTime.tryParse(ts) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  bool _looksLikeNetwork(String s) {
    final lower = s.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  Future<void> _fetchUserPosts() async {
    if (_disposed || _userId == null) return;
    if (mounted)
      setState(() {
        _loading = true;
        _error = null;
      });

    try {
      final snap = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: _userId)
          .get();

      if (snap.docs.isEmpty) {
        if (!_disposed && mounted)
          setState(() {
            _posts = [];
            _loading = false;
          });
        return;
      }

      final List<Map<String, dynamic>> posts = [];

      for (final doc in snap.docs) {
        final data = doc.data();
        final resolvedPostDocId = doc.id;

        // Resolve images
        List<String> resolvedImages = [];
        if (data['images'] is List) {
          final rawImages = List.from(data['images'] ?? []);
          for (final imgEntry in rawImages) {
            try {
              if (imgEntry is String) {
                resolvedImages.add(imgEntry);
              } else if (imgEntry is Map) {
                final fileRef =
                    imgEntry['files_id'] ??
                    imgEntry['filesId'] ??
                    imgEntry['file_id'];
                if (fileRef != null) {
                  final photosQuery = await FirebaseFirestore.instance
                      .collection('photos')
                      .where('files_id', isEqualTo: fileRef)
                      .limit(1)
                      .get();
                  if (photosQuery.docs.isNotEmpty) {
                    final photoData = photosQuery.docs.first.data();
                    final dataStr = photoData['data'] as String?;
                    if (dataStr != null && dataStr.isNotEmpty) {
                      resolvedImages.add(dataStr);
                      continue;
                    }
                  }
                }

                if (imgEntry['url'] != null)
                  resolvedImages.add(imgEntry['url'].toString());
              }
            } catch (e) {
              if (kDebugMode) print('Error resolving image entry: $e');
            }
          }
        }

        Map<String, dynamic>? photoBinary;
        if (resolvedImages.isEmpty && data['files_id'] != null) {
          try {
            final photosQuery = await FirebaseFirestore.instance
                .collection('photos')
                .where('files_id', isEqualTo: data['files_id'])
                .limit(1)
                .get();
            if (photosQuery.docs.isNotEmpty) {
              final photoDoc = photosQuery.docs.first.data();
              photoBinary = {
                'data': photoDoc['data'],
                'filetype': photoDoc['filetype'],
                'files_id': photoDoc['files_id'],
                'created_at': photoDoc['created_at'],
                'user_id': photoDoc['user_id'],
              };
            }
          } catch (e) {
            if (kDebugMode) print('Error fetching photo binary: $e');
          }
        }

        posts.add({
          'postId': resolvedPostDocId,
          'description': data['description']?.toString() ?? '',
          'images': resolvedImages,
          'files_id': data['files_id'],
          'filetype': data['filetype'],
          'uploadDate': data['uploadDate'],
          'userId': data['userId'],
          'photoBinary': photoBinary,
        });
      }

      // Sort posts client-side by uploadDate descending to avoid requiring
      // a composite Firestore index for where+orderBy combinations.
      posts.sort(
        (a, b) => _toDateTime(
          b['uploadDate'],
        ).compareTo(_toDateTime(a['uploadDate'])),
      );

      if (!_disposed && mounted)
        setState(() {
          _posts = posts;
          _loading = false;
        });
    } catch (e) {
      if (kDebugMode) print('Error fetching user posts: $e');
      if (!_disposed && mounted)
        setState(() {
          _loading = false;
          _error = 'Failed to load posts: $e';
        });
    }
  }

  Future<void> _showPrivacySheet(Map<String, dynamic> post) async {
    final docId = (post['postId']?.toString() ?? '').trim();
    if (docId.isEmpty) return;

    final docRef = FirebaseFirestore.instance.collection('posts').doc(docId);
    final snap = await docRef.get();
    if (!snap.exists) return;
    final current = snap.data();
    bool isPrivate =
        (current?['isPrivate'] == true) || (current?['isprivert'] == true);

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setState2) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Privacy',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(child: Text('Make this post private')),
                      Switch(
                        value: isPrivate,
                        onChanged: (v) async {
                          setState2(() => isPrivate = v);
                          try {
                            await docRef.update({
                              'isPrivate': v,
                              'isprivert': v,
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    v
                                        ? 'Post set to private'
                                        : 'Post set to public',
                                  ),
                                ),
                              );
                              // Refresh local list
                              await _fetchUserPosts();
                            }
                          } catch (e) {
                            if (kDebugMode)
                              print('Failed to set privacy via sheet: $e');
                            if (mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update privacy: $e'),
                                ),
                              );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUserPosts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return const Center(
        child: Text('No posts yet', style: TextStyle(color: Colors.grey)),
      );
    }

    return GridViewProfilePost(
      posts: _posts,
      onRefresh: _fetchUserPosts,
      onTap: (post) {
        if (kDebugMode) print('Tapped post: ${post['postId']}');
        // Navigate to single post page with same image resolution as bookmark
        String? imageUrl;
        String? imageData;
        final imgs = post['images'] as List<dynamic>? ?? [];
        if (imgs.isNotEmpty) {
          final first = imgs.first;
          if (first is String) {
            if (first.startsWith('http') || first.startsWith('https')) {
              imageUrl = first;
            } else if (first.startsWith('data:') || !_looksLikeNetwork(first)) {
              imageData = first;
            }
          } else if (first is Map && first['url'] != null) {
            final u = first['url'].toString();
            if (u.startsWith('http') || u.startsWith('https')) imageUrl = u;
          }
        }
        if (imageData == null &&
            post['photoBinary'] is Map &&
            post['photoBinary']['data'] is String) {
          imageData = post['photoBinary']['data'] as String;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SingalPostPage(
              post: post,
              imageUrl: imageUrl,
              imageData: imageData,
            ),
          ),
        );
      },
      onLongPress: (post) async {
        // Show privacy sheet on long press
        await _showPrivacySheet(post);
      },
      ownerActionBuilder: (post) {
        // only show if current user is the owner
        final postOwner = (post['userId'] ?? post['postOwnerId'])?.toString();
        if (_userId == null || postOwner == null || postOwner != _userId)
          return const SizedBox.shrink();
        final isPrivateNow =
            (post['isPrivate'] == true) || (post['isprivert'] == true);
        return GestureDetector(
          onTap: () => _showPrivacySheet(post),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPrivateNow ? Icons.lock : Icons.lock_open,
              size: 14,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
