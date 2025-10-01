import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:everesports/core/page/auth/include/view/contents_display_gridview.dart'
    show EditPostPage;

/// A single-post page that supports different contextual actions:
/// - If opened from the Bookmark list (post contains 'bookmarkDocId') -> allow unbookmark
/// - If opened from the Favorite list (post contains 'likeDocId') -> allow unfavorite
/// - If the current logged-in user owns the post -> allow edit & delete
class SingalPostPage extends StatefulWidget {
  final Map<String, dynamic> post;
  final String? imageUrl; // network URL if available
  final String? imageData; // base64 data if available

  const SingalPostPage({
    Key? key,
    required this.post,
    this.imageUrl,
    this.imageData,
  }) : super(key: key);

  @override
  State<SingalPostPage> createState() => _SingalPostPageState();
}

class _SingalPostPageState extends State<SingalPostPage> {
  String? _currentUserId;
  bool _working = false;

  Future<void> _togglePrivacy() async {
    final post = widget.post;
    final id = (post['id'] ?? post['postId']);
    if (id == null) return;
    setState(() => _working = true);
    try {
      final docRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(id.toString());
      final snap = await docRef.get();
      if (!snap.exists) return;
      final current = snap.data();
      final isPrivate = (current?['isPrivate'] == true);
      final newVal = !isPrivate;
      await docRef.update({'isPrivate': newVal, 'isprivert': newVal});
      if (!mounted) return;
      // update local map so UI reflects immediately
      try {
        widget.post['isPrivate'] = newVal;
        widget.post['isprivert'] = newVal;
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newVal ? 'Post set to private' : 'Post set to public'),
        ),
      );
      setState(() {});
    } catch (e) {
      if (kDebugMode) print('Error toggling privacy: $e');
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update privacy: $e')));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('userId');
      if (!mounted) return;
      setState(() {
        _currentUserId = uid;
      });
    } catch (_) {}
  }

  Future<void> _deletePost() async {
    final post = widget.post;
    final id = post['id'] ?? post['postId'];
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _working = true);
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(id.toString())
          .delete();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (kDebugMode) print('Error deleting post: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete post: $e')));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _unbookmark() async {
    final bookmarkDocId = widget.post['bookmarkDocId'] as String?;
    if (bookmarkDocId == null) return;
    setState(() => _working = true);
    try {
      await FirebaseFirestore.instance
          .collection('bookmark')
          .doc(bookmarkDocId)
          .delete();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (kDebugMode) print('Error removing bookmark: $e');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove bookmark: $e')),
        );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _unfavorite() async {
    final likeDocId = widget.post['likeDocId'] as String?;
    if (likeDocId == null) return;
    setState(() => _working = true);
    try {
      await FirebaseFirestore.instance
          .collection('likes')
          .doc(likeDocId)
          .delete();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (kDebugMode) print('Error removing favorite: $e');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove favorite: $e')),
        );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _editPost() async {
    final post = widget.post;
    // Ensure post has an id field and pass it to the editor
    final docId = (post['id'] ?? post['postId'])?.toString();
    if (docId == null) return;
    final postForEdit = Map<String, dynamic>.from(post);
    postForEdit['id'] = docId;
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditPostPage(post: postForEdit)),
    );
    if (updated == true && mounted) Navigator.pop(context, true);
  }

  Widget _buildImageWidget() {
    final post = widget.post;
    final imgs = post['images'] as List<dynamic>? ?? [];

    // If explicit imageData provided (base64)
    if (widget.imageData != null && widget.imageData!.isNotEmpty) {
      try {
        final bytes = base64Decode(widget.imageData!);
        return Image.memory(bytes, fit: BoxFit.contain);
      } catch (e) {
        if (kDebugMode) print('Error decoding imageData: $e');
      }
    }

    // If imageUrl provided and looks like http
    if (widget.imageUrl != null &&
        (widget.imageUrl!.startsWith('http') ||
            widget.imageUrl!.startsWith('https'))) {
      return Image.network(
        widget.imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (c, e, s) =>
            const Center(child: Icon(Icons.broken_image, size: 80)),
      );
    }

    // Try post images
    if (imgs.isNotEmpty) {
      final first = imgs.first;
      if (first is String) {
        final s = first.toString();
        if (s.startsWith('data:')) {
          try {
            final comma = s.indexOf(',');
            final base64Part = comma >= 0 ? s.substring(comma + 1) : s;
            final bytes = base64Decode(base64Part);
            return Image.memory(bytes, fit: BoxFit.contain);
          } catch (e) {
            if (kDebugMode) print('Error decoding data URL: $e');
          }
        }
        if (s.startsWith('http') || s.startsWith('https')) {
          return Image.network(
            s,
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) =>
                const Center(child: Icon(Icons.broken_image, size: 80)),
          );
        }
        // maybe raw base64
        try {
          final bytes = base64Decode(s);
          return Image.memory(bytes, fit: BoxFit.contain);
        } catch (_) {}
      } else if (first is Map && first['url'] != null) {
        final u = first['url'].toString();
        if (u.startsWith('http') || u.startsWith('https')) {
          return Image.network(
            u,
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) =>
                const Center(child: Icon(Icons.broken_image, size: 80)),
          );
        }
      }
    }

    // photoBinary fallback
    final photoBinary = post['photoBinary'] as Map<String, dynamic>?;
    if (photoBinary != null && photoBinary['data'] is String) {
      try {
        final bytes = base64Decode(photoBinary['data'] as String);
        return Image.memory(bytes, fit: BoxFit.contain);
      } catch (e) {
        if (kDebugMode) print('Error decoding photoBinary: $e');
      }
    }

    return const Center(child: Icon(Icons.image_not_supported, size: 80));
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasId = (post['id'] ?? post['postId']) != null;

    final bookmarkDocId = post['bookmarkDocId'] as String?;
    final likeDocId = post['likeDocId'] as String?;
    final postOwnerId = (post['userId'] ?? post['postOwnerId'])?.toString();
    final isOwner =
        _currentUserId != null &&
        postOwnerId != null &&
        _currentUserId == postOwnerId;

    List<Widget> actions = [];

    if (bookmarkDocId != null) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.bookmark_remove),
          tooltip: 'Remove bookmark',
          onPressed: _working ? null : _unbookmark,
        ),
      );
    } else if (likeDocId != null) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.favorite),
          tooltip: 'Remove favorite',
          onPressed: _working ? null : _unfavorite,
        ),
      );
    }

    if (isOwner && hasId) {
      // show privacy toggle for owner
      final isPrivateNow =
          (post['isPrivate'] == true) || (post['isprivert'] == true);
      actions.add(
        IconButton(
          icon: Icon(isPrivateNow ? Icons.lock : Icons.lock_open),
          tooltip: isPrivateNow ? 'Set public' : 'Set private',
          onPressed: _working ? null : _togglePrivacy,
        ),
      );
      actions.addAll([
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          onPressed: _working ? null : _editPost,
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Delete',
          onPressed: _working ? null : _deletePost,
        ),
      ]);
    } else if (hasId && actions.isEmpty) {
      // If the post has an id but none of the contextual actions apply, show delete only when hasId
      actions.add(
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _working ? null : _deletePost,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(post['title']?.toString() ?? 'Post'),
        actions: actions,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildImageWidget()),
          Container(
            color: isDark ? Colors.black.withOpacity(0.05) : Colors.white,
            padding: const EdgeInsets.all(16),
            child: Text(
              post['description']?.toString() ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
