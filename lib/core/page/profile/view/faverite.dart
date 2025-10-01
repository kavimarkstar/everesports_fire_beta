import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/core/auth/home/login_home.dart';
import 'package:everesports/core/auth/services/auth_service.dart';
import 'package:everesports/core/page/profile/widget/loding_gridview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/gridview.dart';
import 'package:everesports/core/page/singal_posts/singal_posts.dart';

class FaveriteView extends StatefulWidget {
  const FaveriteView({super.key});

  @override
  State<FaveriteView> createState() => _FaveriteViewState();
}

class _FaveriteViewState extends State<FaveriteView> {
  String? _userId;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _posts = [];
  bool _disposed = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _likeSub;

  @override
  void initState() {
    super.initState();
    _checkSessionAndFetch();
  }

  @override
  void dispose() {
    _disposed = true;
    _likeSub?.cancel();
    super.dispose();
  }

  Future<void> _checkSessionAndFetch() async {
    try {
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

      // Try to resolve firestore doc id (best-effort)
      try {
        final docId = await AuthServiceFireBase.getDocIdByUserId(_userId!);
        if (kDebugMode)
          print('Resolved user docId: $docId for userId: $_userId');
      } catch (_) {
        if (kDebugMode) print('Could not resolve docId for user $_userId');
      }

      await _fetchLikedPostsAndDetails();
      _startLikeListener();
    } catch (e) {
      if (!_disposed && mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to initialize: ${e.toString()}';
        });
      }
    }
  }

  void _startLikeListener() {
    if (_userId == null) return;
    _likeSub?.cancel();
    _likeSub = FirebaseFirestore.instance
        .collection('likes')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) async {
          if (_disposed || !mounted) return;

          for (final change in snapshot.docChanges) {
            final data = change.doc.data();
            if (data == null) continue;
            final postId = (data['postId']?.toString() ?? '').trim();
            final likeDocId = change.doc.id;
            final createdAt = data['createdAt'];

            if (change.type == DocumentChangeType.added) {
              final fetched = await _fetchSinglePostForLike(
                postId,
                likeDocId,
                createdAt,
              );
              if (fetched != null) {
                if (!_posts.any(
                  (p) =>
                      (p['postId']?.toString() ?? '') ==
                      (fetched['postId'] ?? ''),
                )) {
                  setState(() {
                    _posts.insert(0, fetched);
                  });
                }
              }
            } else if (change.type == DocumentChangeType.removed) {
              setState(() {
                _posts.removeWhere(
                  (p) =>
                      (p['likeDocId']?.toString() ?? '') == likeDocId ||
                      (p['postId']?.toString() ?? '') == postId,
                );
              });
            } else if (change.type == DocumentChangeType.modified) {
              setState(() {
                for (var i = 0; i < _posts.length; i++) {
                  if ((_posts[i]['likeDocId']?.toString() ?? '') == likeDocId ||
                      (_posts[i]['postId']?.toString() ?? '') == postId) {
                    _posts[i]['createdAt'] = createdAt;
                  }
                }
                _posts.sort((a, b) {
                  final aSaved = a['createdAt'];
                  final bSaved = b['createdAt'];
                  DateTime aDate = _toDateTime(aSaved);
                  DateTime bDate = _toDateTime(bSaved);
                  return bDate.compareTo(aDate);
                });
              });
            }
          }
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

  Future<Map<String, dynamic>?> _fetchSinglePostForLike(
    String postId,
    String likeDocId,
    dynamic createdAt,
  ) async {
    if (postId.isEmpty) return null;
    try {
      final postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();
      Map<String, dynamic>? postData;
      String resolvedPostDocId = postId;
      if (postSnap.exists && postSnap.data() != null) {
        postData = postSnap.data()!;
      } else {
        final alt = await FirebaseFirestore.instance
            .collection('posts')
            .where('postId', isEqualTo: postId)
            .limit(1)
            .get();
        if (alt.docs.isNotEmpty) {
          postData = alt.docs.first.data();
          resolvedPostDocId = alt.docs.first.id;
        }
      }

      if (postData == null) return null;

      List<String> resolvedImages = [];
      if (postData['images'] is List) {
        final rawImages = List.from(postData['images'] ?? []);
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
            if (kDebugMode) print('Error resolving single image: $e');
          }
        }
      }

      Map<String, dynamic>? photoBinary;
      if (resolvedImages.isEmpty && postData['files_id'] != null) {
        try {
          final photosQuery = await FirebaseFirestore.instance
              .collection('photos')
              .where('files_id', isEqualTo: postData['files_id'])
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
          if (kDebugMode) print('Error fetching photo binary (single): $e');
        }
      }

      return {
        'postId': resolvedPostDocId,
        'createdAt': createdAt,
        'description': postData['description']?.toString() ?? 'No description',
        'images': resolvedImages,
        'files_id': postData['files_id'],
        'filetype': postData['filetype'],
        'uploadDate': postData['uploadDate'],
        'userId': postData['userId'],
        'photoBinary': photoBinary,
        'likeDocId': likeDocId,
      };
    } catch (e) {
      if (kDebugMode) print('Error in _fetchSinglePostForLike: $e');
      return null;
    }
  }

  Future<void> _fetchLikedPostsAndDetails() async {
    if (_disposed || _userId == null) return;

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final likeSnapshot = await FirebaseFirestore.instance
          .collection('likes')
          .where('userId', isEqualTo: _userId)
          .get();

      if (likeSnapshot.docs.isEmpty) {
        if (kDebugMode) print('No like documents found for user $_userId');
        if (!_disposed && mounted) {
          setState(() {
            _posts = [];
            _loading = false;
          });
        }
        return;
      }

      final likes = likeSnapshot.docs
          .map((doc) {
            final data = doc.data();
            final rawPostId = data['postId']?.toString();
            return {
              'postId': rawPostId != null ? rawPostId.trim() : null,
              'createdAt': data['createdAt'],
              'likeDocId': doc.id,
            };
          })
          .where(
            (e) => e['postId'] != null && (e['postId'] as String).isNotEmpty,
          )
          .toList();

      likes.sort((a, b) {
        final aSavedAt = a['createdAt'];
        final bSavedAt = b['createdAt'];
        if (aSavedAt == null && bSavedAt == null) return 0;
        if (aSavedAt == null) return 1;
        if (bSavedAt == null) return -1;
        DateTime aDate = _toDateTime(aSavedAt);
        DateTime bDate = _toDateTime(bSavedAt);
        return bDate.compareTo(aDate);
      });

      if (likes.isEmpty) {
        if (!_disposed && mounted) {
          setState(() {
            _posts = [];
            _loading = false;
          });
        }
        return;
      }

      List<Map<String, dynamic>> posts = [];
      for (final like in likes) {
        final postId = (like['postId']?.toString() ?? '').trim();
        if (postId.isEmpty) continue;
        try {
          final postSnap = await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .get();
          Map<String, dynamic>? postData;
          String resolvedPostDocId = postId;
          if (postSnap.exists && postSnap.data() != null) {
            postData = postSnap.data()!;
          } else {
            try {
              final alt = await FirebaseFirestore.instance
                  .collection('posts')
                  .where('postId', isEqualTo: postId)
                  .limit(1)
                  .get();
              if (alt.docs.isNotEmpty) {
                postData = alt.docs.first.data();
                resolvedPostDocId = alt.docs.first.id;
              }
            } catch (e) {
              if (kDebugMode) print('Error fallback querying post $postId: $e');
            }
          }

          if (postData != null) {
            List<String> resolvedImages = [];
            if (postData['images'] is List) {
              final rawImages = List.from(postData['images'] ?? []);
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
            if (resolvedImages.isEmpty && postData['files_id'] != null) {
              try {
                final photosQuery = await FirebaseFirestore.instance
                    .collection('photos')
                    .where('files_id', isEqualTo: postData['files_id'])
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
              'createdAt': like['createdAt'],
              'description':
                  postData['description']?.toString() ?? 'No description',
              'images': resolvedImages,
              'files_id': postData['files_id'],
              'filetype': postData['filetype'],
              'uploadDate': postData['uploadDate'],
              'userId': postData['userId'],
              'photoBinary': photoBinary,
              'likeDocId': like['likeDocId'],
            });
          }
        } catch (e) {
          if (kDebugMode) print('Error fetching post $postId: $e');
          continue;
        }
      }

      if (!_disposed && mounted) {
        setState(() {
          _posts = posts;
          _loading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error in _fetchLikedPostsAndDetails: $e');
      if (!_disposed && mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load likes: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Center(child: buildLoadingGridView(context));

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchLikedPostsAndDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No likes found', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              'Posts you like will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridViewProfilePost(
      posts: _posts,
      onRefresh: _fetchLikedPostsAndDetails,
      onTap: (post) {
        if (kDebugMode) print('Tapped post: ${post['postId']}');
        // Navigate to single post page with the same image resolution used in BookmarkView
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
    );
  }
}
