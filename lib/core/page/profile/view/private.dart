import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/core/auth/home/login_home.dart';
import 'package:everesports/core/page/profile/widget/gridview.dart';
import 'package:everesports/core/page/singal_posts/singal_posts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivateView extends StatefulWidget {
  const PrivateView({super.key});

  @override
  State<PrivateView> createState() => _PrivateViewState();
}

class _PrivateViewState extends State<PrivateView> {
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
      await _fetchPrivatePosts();
      _startPostsListener();
    } catch (e) {
      if (!_disposed && mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to initialize: $e';
        });
      }
    }
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
          // Rebuild list from snapshot to reflect privacy changes in realtime
          await _fetchPrivatePosts();
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

  Future<void> _fetchPrivatePosts() async {
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
        try {
          final data = doc.data();

          // Only include posts marked private by either field
          final bool isPrivate =
              (data['isPrivate'] == true) || (data['isprivert'] == true);
          if (!isPrivate) continue;

          // Resolve images similarly to other views
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
            'postId': doc.id,
            'description': data['description']?.toString() ?? '',
            'images': resolvedImages,
            'files_id': data['files_id'],
            'filetype': data['filetype'],
            'uploadDate': data['uploadDate'],
            'userId': data['userId'],
            'photoBinary': photoBinary,
            'isPrivate': true,
            'isprivert': true,
          });
        } catch (e) {
          if (kDebugMode) print('Error processing private post doc: $e');
        }
      }

      // sort by uploadDate desc
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
      if (kDebugMode) print('Error fetching private posts: $e');
      if (!_disposed && mounted)
        setState(() {
          _loading = false;
          _error = 'Failed to load private posts: $e';
        });
    }
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
              onPressed: _fetchPrivatePosts,
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
            Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No private posts', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              'Your private posts will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridViewProfilePost(
      posts: _posts,
      onRefresh: _fetchPrivatePosts,
      onTap: (post) {
        // Determine imageUrl/imageData like other views
        String? imageUrl;
        String? imageData;
        final imgs = post['images'] as List<dynamic>? ?? [];
        if (imgs.isNotEmpty) {
          final first = imgs.first;
          if (first is String) {
            if (first.startsWith('http') || first.startsWith('https'))
              imageUrl = first;
            else if (first.startsWith('data:') ||
                !first.toString().toLowerCase().startsWith('http'))
              imageData = first;
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
