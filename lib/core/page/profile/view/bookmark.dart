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

class BookmarkView extends StatefulWidget {
  const BookmarkView({Key? key}) : super(key: key);

  @override
  State<BookmarkView> createState() => _BookmarkViewState();
}

class _BookmarkViewState extends State<BookmarkView> {
  String? _userId;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _posts = [];
  bool _disposed = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _bookmarkSub;

  @override
  void initState() {
    super.initState();
    _checkSessionAndFetch();
  }

  @override
  void dispose() {
    _disposed = true;
    _bookmarkSub?.cancel();
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

      // Best-effort resolve Firestore user doc id but don't force logout if it fails
      try {
        final docId = await AuthServiceFireBase.getDocIdByUserId(_userId!);
        if (kDebugMode)
          print('Resolved user docId: $docId for userId: $_userId');
      } catch (_) {
        if (kDebugMode) print('Could not resolve docId for user $_userId');
      }

      await _fetchBookmarkedPostsAndDetails();
      // Start realtime listener so new bookmarks appear at the top immediately
      _startBookmarkListener();
    } catch (e) {
      if (!_disposed && mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to initialize: ${e.toString()}';
        });
      }
    }
  }

  void _startBookmarkListener() {
    if (_userId == null) return;
    // Cancel any existing subscription
    _bookmarkSub?.cancel();
    _bookmarkSub = FirebaseFirestore.instance
        .collection('bookmark')
        .where('userId', isEqualTo: _userId)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .listen((snapshot) async {
          if (_disposed || !mounted) return;

          for (final change in snapshot.docChanges) {
            final data = change.doc.data();
            if (data == null) continue;
            final postId = (data['postId']?.toString() ?? '').trim();
            final bookmarkDocId = change.doc.id;
            final savedAt = data['savedAt'];

            if (change.type == DocumentChangeType.added) {
              // Fetch the single post and insert at top if not present
              final fetched = await _fetchSinglePost(
                postId,
                bookmarkDocId,
                savedAt,
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
              // Remove any post with this bookmarkDocId or matching postId
              setState(() {
                _posts.removeWhere(
                  (p) =>
                      (p['bookmarkDocId']?.toString() ?? '') == bookmarkDocId ||
                      (p['postId']?.toString() ?? '') == postId,
                );
              });
            } else if (change.type == DocumentChangeType.modified) {
              // Update savedAt or other metadata and keep ordering
              setState(() {
                for (var i = 0; i < _posts.length; i++) {
                  if ((_posts[i]['bookmarkDocId']?.toString() ?? '') ==
                          bookmarkDocId ||
                      (_posts[i]['postId']?.toString() ?? '') == postId) {
                    _posts[i]['savedAt'] = savedAt;
                  }
                }
                // Re-sort by savedAt desc
                _posts.sort((a, b) {
                  final aSaved = a['savedAt'];
                  final bSaved = b['savedAt'];
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

  /// Fetch a single post by id (with fallback) and return the same map shape used in _fetchBookmarkedPostsAndDetails
  Future<Map<String, dynamic>?> _fetchSinglePost(
    String postId,
    String bookmarkDocId,
    dynamic savedAt,
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
        } else {
          if (kDebugMode) print('Post not found for id $postId (single fetch)');
        }
      }

      if (postData == null) return null;

      // Resolve images similar to the bulk fetch
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
        'savedAt': savedAt,
        'description': postData['description']?.toString() ?? 'No description',
        'images': resolvedImages,
        'files_id': postData['files_id'],
        'filetype': postData['filetype'],
        'uploadDate': postData['uploadDate'],
        'userId': postData['userId'],
        'photoBinary': photoBinary,
        'bookmarkDocId': bookmarkDocId,
      };
    } catch (e) {
      if (kDebugMode) print('Error in _fetchSinglePost: $e');
      return null;
    }
  }

  /// Fetch bookmarks and post details, including binary photo if no images.
  Future<void> _fetchBookmarkedPostsAndDetails() async {
    if (_disposed || _userId == null) return;

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      // 1. Get all bookmarked postIds for this user
      final bookmarkSnapshot = await FirebaseFirestore.instance
          .collection('bookmark')
          .where('userId', isEqualTo: _userId)
          .get();

      if (bookmarkSnapshot.docs.isEmpty) {
        if (kDebugMode) print('No bookmark documents found for user $_userId');
        if (!_disposed && mounted) {
          setState(() {
            _posts = [];
            _loading = false;
          });
        }
        return;
      }

      // Normalize and collect bookmarked entries
      final bookmarked = bookmarkSnapshot.docs
          .map((doc) {
            final data = doc.data();
            final rawPostId = data['postId']?.toString();
            return {
              // Trim to avoid accidental whitespace preventing doc lookup
              'postId': rawPostId != null ? rawPostId.trim() : null,
              'savedAt': data['savedAt'],
              'bookmarkDocId': doc.id,
            };
          })
          .where(
            (e) => e['postId'] != null && (e['postId'] as String).isNotEmpty,
          )
          .toList();

      // Sort bookmarks by savedAt descending
      bookmarked.sort((a, b) {
        final aSavedAt = a['savedAt'];
        final bSavedAt = b['savedAt'];

        if (aSavedAt == null && bSavedAt == null) return 0;
        if (aSavedAt == null) return 1;
        if (bSavedAt == null) return -1;

        DateTime aDate, bDate;

        if (aSavedAt is Timestamp) {
          aDate = aSavedAt.toDate();
        } else if (aSavedAt is DateTime) {
          aDate = aSavedAt;
        } else if (aSavedAt is String) {
          aDate = DateTime.tryParse(aSavedAt) ?? DateTime(0);
        } else {
          return 0;
        }

        if (bSavedAt is Timestamp) {
          bDate = bSavedAt.toDate();
        } else if (bSavedAt is DateTime) {
          bDate = bSavedAt;
        } else if (bSavedAt is String) {
          bDate = DateTime.tryParse(bSavedAt) ?? DateTime(0);
        } else {
          return 0;
        }

        return bDate.compareTo(aDate);
      });

      if (bookmarked.isEmpty) {
        if (!_disposed && mounted) {
          setState(() {
            _posts = [];
            _loading = false;
          });
        }
        return;
      }

      // 2. Fetch post details for each postId
      List<Map<String, dynamic>> posts = [];

      for (final bm in bookmarked) {
        final postId = (bm['postId']?.toString() ?? '').trim();
        if (postId.isEmpty) continue;

        try {
          // First try to fetch by document id
          final postSnap = await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .get();

          Map<String, dynamic>? postData;
          String resolvedPostDocId = postId;

          if (postSnap.exists && postSnap.data() != null) {
            postData = postSnap.data()!;
          } else {
            // Fallback: some posts store an internal 'postId' field instead of using the
            // Firestore document id. Try querying by that field.
            try {
              final alt = await FirebaseFirestore.instance
                  .collection('posts')
                  .where('postId', isEqualTo: postId)
                  .limit(1)
                  .get();
              if (alt.docs.isNotEmpty) {
                postData = alt.docs.first.data();
                resolvedPostDocId = alt.docs.first.id;
              } else {
                if (kDebugMode) print('Post not found for id $postId');
              }
            } catch (e) {
              if (kDebugMode) print('Error fallback querying post $postId: $e');
            }
          }

          if (postData != null) {
            // Handle images field more carefully
            // We'll resolve images into a list of strings where each entry is
            // either a network URL or a base64 data string fetched from
            // the 'photos' collection when posts reference files via files_id.
            List<String> resolvedImages = [];
            if (postData['images'] is List) {
              final rawImages = List.from(postData['images'] ?? []);
              for (final imgEntry in rawImages) {
                try {
                  if (imgEntry is String) {
                    // Could be a data URL or raw base64 or network URL
                    resolvedImages.add(imgEntry);
                  } else if (imgEntry is Map) {
                    // Common upload shape: { 'files_id': '...', 'filetype': 'jpg' }
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

                    // If the map contains a direct URL field
                    if (imgEntry['url'] != null) {
                      resolvedImages.add(imgEntry['url'].toString());
                    }
                  }
                } catch (e) {
                  if (kDebugMode) print('Error resolving image entry: $e');
                }
              }
            }

            Map<String, dynamic>? photoBinary;

            // If we didn't resolve any images above, try the older pattern where
            // a post stored a top-level 'files_id' pointing to photos collection
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
              'savedAt': bm['savedAt'],
              'description':
                  postData['description']?.toString() ?? 'No description',
              'images': resolvedImages,
              'files_id': postData['files_id'],
              'filetype': postData['filetype'],
              'uploadDate': postData['uploadDate'],
              'userId': postData['userId'],
              'photoBinary': photoBinary,
              'bookmarkDocId': bm['bookmarkDocId'],
            });
          }
        } catch (e) {
          if (kDebugMode) print('Error fetching post $postId: $e');
          // Continue with next post instead of failing entirely
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
      if (kDebugMode) print('Error in _fetchBookmarkedPostsAndDetails: $e');
      if (!_disposed && mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load bookmarks: ${e.toString()}';
        });
      }
    }
  }

  // Image rendering moved to `GridViewProfilePost ` widget.

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: buildLoadingGridView(context));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchBookmarkedPostsAndDetails,
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
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No bookmarks found', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              'Posts you bookmark will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridViewProfilePost(
      posts: _posts,
      onRefresh: _fetchBookmarkedPostsAndDetails,
      onTap: (post) {
        if (kDebugMode) print('Tapped post: ${post['postId']}');
        // Navigate to single post page (supports network and base64/photoBinary)
        String? imageUrl;
        String? imageData;
        final imgs = post['images'] as List<dynamic>? ?? [];
        if (imgs.isNotEmpty) {
          final first = imgs.first;
          if (first is String) {
            if (first.startsWith('http') || first.startsWith('https'))
              imageUrl = first;
            else if (first.startsWith('data:') || !_looksLikeNetwork(first))
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

  // Timestamp formatting moved to `GridViewProfilePost ` widget.
}
