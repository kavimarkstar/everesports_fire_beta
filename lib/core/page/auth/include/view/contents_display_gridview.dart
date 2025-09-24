import 'package:everesports/Theme/colors.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContentsDisplayGridviewUser extends StatefulWidget {
  final String userId;
  const ContentsDisplayGridviewUser({super.key, required this.userId});

  @override
  State<ContentsDisplayGridviewUser> createState() =>
      _ContentsDisplayGridviewUserState();
}

class _ContentsDisplayGridviewUserState
    extends State<ContentsDisplayGridviewUser>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Future<List<Map<String, dynamic>>>? _futurePosts;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _futurePosts = fetchPosts();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final query = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: widget.userId)
        .get();
    return query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_futurePosts == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futurePosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No posts found.'));
        }
        final posts = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final post = posts[index];
            final files = post['files'] as List<dynamic>?;
            final String? imageUrl =
                (files != null &&
                    files.isNotEmpty &&
                    files[0] != null &&
                    files[0].toString().isNotEmpty)
                ? files[0].toString()
                : null;
            final double start = (index * 0.05).clamp(0.0, 1.0);
            final double end = (start + 0.5).clamp(0.0, 1.0);
            final Animation<double> animation = CurvedAnimation(
              parent: _controller,
              curve: Interval(start, end, curve: Curves.easeOut),
            );
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Opacity(
                  opacity: animation.value,
                  child: Transform.scale(
                    scale: 0.9 + 0.1 * animation.value,
                    child: child,
                  ),
                );
              },
              child: GestureDetector(
                onTap: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PostDetailPage(post: post, imageUrl: imageUrl),
                    ),
                  );
                  if (updated == true && mounted) {
                    setState(() {
                      _futurePosts = fetchPosts();
                    });
                  }
                },
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl.startsWith('http')
                              ? imageUrl
                              : imageUrl, // No fileServerBaseUrl for Firebase
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image)),
                        )
                      : const Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PostDetailPage extends StatelessWidget {
  final Map<String, dynamic> post;
  final String? imageUrl;
  const PostDetailPage({super.key, required this.post, required this.imageUrl});

  Future<void> _deletePost(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(post['id'])
        .delete();
    if (context.mounted) Navigator.pop(context);
  }

  void _editPost(BuildContext context) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditPostPage(post: post)),
    );
    if (updated == true && context.mounted) {
      Navigator.pop(context, true); // Optionally refresh parent
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final List<Widget> editActions = [
      IconButton(
        icon: const Icon(Icons.edit),
        tooltip: 'Edit',
        onPressed: () => _editPost(context),
      ),
      IconButton(
        icon: const Icon(Icons.delete),
        tooltip: 'Delete',
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: isDark ? mainBlackColor : mainWhiteColor,
              title: const Text('Delete Post'),
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
          if (confirm == true) {
            await _deletePost(context);
          }
        },
      ),
    ];
    final editBar = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: editActions,
    );
    return Scaffold(
      appBar: isDesktop ? null : AppBar(actions: editActions),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isDesktop)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 8),
                    child: editBar,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(post['title'] ?? 'Post Detail'),
              ),
              imageUrl != null
                  ? Image.network(
                      imageUrl!.startsWith('http')
                          ? imageUrl!
                          : imageUrl!, // No fileServerBaseUrl for Firebase
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(Icons.broken_image, size: 80),
                          ),
                    )
                  : const Center(
                      child: Icon(Icons.image_not_supported, size: 80),
                    ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  post['description'] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditPostPage extends StatefulWidget {
  final Map<String, dynamic> post;
  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post['title'] ?? '');
    _descController = TextEditingController(
      text: widget.post['description'] ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post['id'])
        .update({
          'title': _titleController.text.trim(),
          'description': _descController.text.trim(),
        });
    setState(() => _isSaving = false);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 6,
            ),
            const SizedBox(height: 24),
            Spacer(),
            _isSaving
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: commonElevatedButtonbuild(context, 'Save', _save),
                  ),
          ],
        ),
      ),
    );
  }
}
