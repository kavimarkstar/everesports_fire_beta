import 'package:everesports/responsive/responsive.dart';
import 'package:everesports/widget/common_textbutton.dart';
import 'package:everesports/widget/common_textbutton_text_only.dart';
import 'package:flutter/material.dart';
import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/home/model/comment.dart';
import 'package:everesports/core/page/home/service/comment_service.dart';
import 'package:everesports/service/auth/profile_service.dart';
import 'package:everesports/database/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:everesports/widget/common_snackbar.dart';
import 'package:everesports/widget/user_avatar.dart';
import 'package:everesports/language/controller/all_language.dart';

class CommentBottomSheet extends StatefulWidget {
  final String postId;
  final String postTitle;

  const CommentBottomSheet({
    Key? key,
    required this.postId,
    required this.postTitle,
  }) : super(key: key);

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Comment> comments = [];
  bool isLoading = true;
  String? error;
  String? _currentUserId;
  late ProfileService _profileService;
  final Map<String, Map<String, dynamic>> _userProfiles = {};
  String? _editingCommentId;
  final TextEditingController _editController = TextEditingController();
  String? _replyingToCommentId;
  final TextEditingController _replyController = TextEditingController();
  final Set<String> _expandedComments = {};
  final Set<String> _likedComments = {};
  final Map<String, int> _likeCounts = {};

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(
      connectionString: configDatabase,
      serverBaseUrl: fileServerBaseUrl,
    );
    _loadCurrentUser();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _editController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      setState(() {
        _currentUserId = userId;
      });
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _loadComments() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final fetchedComments = await CommentService.getCommentsForPost(
        widget.postId,
      );
      await _fetchUserProfiles(fetchedComments);

      // Fetch like state and counts for all comments
      if (_currentUserId != null) {
        for (final comment in fetchedComments) {
          final liked = await CommentService.isCommentLikedByUser(
            _currentUserId!,
            comment.id,
          );
          if (liked) {
            _likedComments.add(comment.id);
          } else {
            _likedComments.remove(comment.id);
          }
          final count = await CommentService.getCommentLikeCount(comment.id);
          _likeCounts[comment.id] = count;
        }
      }

      setState(() {
        comments = fetchedComments;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load comments: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUserProfiles(List<Comment> comments) async {
    final uniqueUserIds = comments.map((comment) => comment.userId).toSet();

    for (final userId in uniqueUserIds) {
      if (userId.isNotEmpty && !_userProfiles.containsKey(userId)) {
        try {
          final userProfile = await _profileService.fetchUserById(userId);
          if (userProfile != null) {
            _userProfiles[userId] = userProfile;
          }
        } catch (e) {
          print('Error fetching user profile for $userId: $e');
        }
      }
    }
  }

  Future<void> _addComment() async {
    if (_currentUserId == null) {
      commonSnackBarbuild(context, getPleaseLoginToComment(context));
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) {
      return;
    }

    try {
      final newComment = await CommentService.addComment(
        _currentUserId!,
        widget.postId,
        content,
      );

      if (newComment != null) {
        // Fetch user profile for the new comment
        final userProfile = await _profileService.fetchUserById(
          _currentUserId!,
        );
        if (userProfile != null) {
          _userProfiles[_currentUserId!] = userProfile;
        }

        setState(() {
          comments.add(newComment);
        });

        _commentController.clear();

        // Scroll to bottom to show new comment
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      commonSnackBarbuildError(
        context,
        getErrorAddingComment(context, e.toString()),
      );
    }
  }

  String _getUserName(String userId) {
    final userProfile = _userProfiles[userId];
    if (userProfile != null) {
      return userProfile['username'] ?? userProfile['name'] ?? 'User $userId';
    }
    return 'Unknown User';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}${getDaysAgo(context)}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${getHoursAgo(context)}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${getMinutesAgo(context)}';
    } else {
      return getJustNow(context);
    }
  }

  Widget _buildCommentWithReplies(
    Comment comment,
    List<Comment> allComments,
    int indent,
  ) {
    final replies = allComments.where((c) => c.parentId == comment.id).toList();
    final isOwnComment = comment.userId == _currentUserId;
    final isReplying = _replyingToCommentId == comment.id;

    return Padding(
      padding: EdgeInsets.only(left: 16.0 * indent, top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSingleComment(comment, isOwnComment, isReplying),
          if (isReplying) _buildReplyInput(comment),
          if (replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 4, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_expandedComments.contains(comment.id)) {
                          _expandedComments.remove(comment.id);
                        } else {
                          _expandedComments.add(comment.id);
                        }
                      });
                    },
                    child: Text(
                      _expandedComments.contains(comment.id)
                          ? getHideReplies(context)
                          : getShowReplies(context, replies.length),
                    ),
                  ),
                  if (_expandedComments.contains(comment.id))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: replies
                          .map(
                            (reply) => _buildSingleComment(
                              reply,
                              reply.userId == _currentUserId,
                              false,
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleComment(
    Comment comment,
    bool isOwnComment,
    bool isReplying,
  ) {
    Widget commentContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          UserAvatar(
            profileImageUrl: _userProfiles[comment.userId]?['profileImageUrl'],
            radius: 18,
          ),
          const SizedBox(width: 12),
          // Comment content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getUserName(comment.userId),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(comment.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),

                      // Like button and count
                    ],
                  ),
                  const SizedBox(height: 4),
                  (_editingCommentId == comment.id)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _editController,
                              autofocus: true,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: getEditYourComment(context),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: mainColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: commonTextButtonbuild(
                                    context,
                                    getSave(context),
                                    () async {
                                      final newContent = _editController.text
                                          .trim();
                                      if (newContent.isNotEmpty) {
                                        final success =
                                            await CommentService.updateComment(
                                              comment.id,
                                              newContent,
                                            );
                                        if (success) {
                                          setState(() {
                                            comments[comments.indexOf(
                                              comment,
                                            )] = Comment(
                                              id: comment.id,
                                              userId: comment.userId,
                                              postId: comment.postId,
                                              content: newContent,
                                              createdAt: comment.createdAt,
                                              updatedAt: DateTime.now(),
                                              parentId: comment.parentId,
                                            );
                                            _editingCommentId = null;
                                          });
                                        }
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: commonTextButtonbuild(
                                    context,
                                    getCancel(context),
                                    () {
                                      setState(() {
                                        _editingCommentId = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Text(
                          comment.content,
                          style: const TextStyle(fontSize: 14),
                        ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: CommonTextButtonTextOnlybuild(
                      context,
                      getReply(context),
                      () {
                        setState(() {
                          if (comment.parentId != null) {
                            _replyingToCommentId = comment.parentId;
                            final mention = '@${_getUserName(comment.userId)} ';
                            _replyController.text = mention;
                            _replyController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(
                                    offset: _replyController.text.length,
                                  ),
                                );
                          } else {
                            _replyingToCommentId = comment.id;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (_currentUserId == null) return;
                    final isLiked = _likedComments.contains(comment.id);
                    setState(() {
                      if (isLiked) {
                        _likedComments.remove(comment.id);
                        _likeCounts[comment.id] =
                            (_likeCounts[comment.id] ?? 1) - 1;
                      } else {
                        _likedComments.add(comment.id);
                        _likeCounts[comment.id] =
                            (_likeCounts[comment.id] ?? 0) + 1;
                      }
                    });
                    if (isLiked) {
                      await CommentService.unlikeComment(
                        _currentUserId!,
                        comment.id,
                      );
                    } else {
                      await CommentService.likeComment(
                        _currentUserId!,
                        comment.id,
                      );
                    }
                  },
                  child: Icon(
                    _likedComments.contains(comment.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _likedComments.contains(comment.id)
                        ? Colors.red
                        : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  (_likeCounts[comment.id] ?? 0).toString(),
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Enable long-press for all comments
    return GestureDetector(
      onLongPressStart: (details) async {
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromRect(
            details.globalPosition & const Size(40, 40), // position of the tap
            Offset.zero & overlay.size, // size of the overlay
          ),
          items: isOwnComment
              ? [
                  PopupMenuItem(value: 'edit', child: Text(getEdit(context))),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(getDelete(context)),
                  ),
                ]
              : [
                  PopupMenuItem(
                    value: 'report',
                    child: Text(getReport(context)),
                  ),
                ],
        );
        if (selected == 'edit') {
          setState(() {
            _editingCommentId = comment.id;
            _editController.text = comment.content;
          });
        } else if (selected == 'delete') {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(getDeleteComment(context)),
              content: Text(getDeleteCommentConfirm(context)),
              actions: [
                commonTextButtonbuild(
                  context,
                  getCancel(context),
                  () => Navigator.of(context).pop(false),
                ),
                commonTextButtonbuild(
                  context,
                  getDelete(context),
                  () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            final success = await CommentService.deleteComment(
              comment.id,
              _currentUserId!,
            );
            if (success) {
              setState(() {
                comments.remove(comment);
              });
            }
          }
        } else if (selected == 'report') {
          commonSnackBarbuildSuccess(context, getReportedComment(context));
        }
      },
      child: commentContent,
    );
  }

  Widget _buildReplyInput(Comment parentComment) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mention = '@${_getUserName(parentComment.userId)} ';
    if (_replyController.text.isEmpty ||
        !_replyController.text.startsWith(mention)) {
      _replyController.text = mention;
      _replyController.selection = TextSelection.fromPosition(
        TextPosition(offset: _replyController.text.length),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 32.0, top: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              autofocus: true,
              onSubmitted: (value) async {
                if (value.trim().isNotEmpty) {
                  String content = value.trim();
                  if (!content.startsWith(mention)) {
                    content = mention + content;
                  }
                  final newReply = await CommentService.addComment(
                    _currentUserId!,
                    widget.postId,
                    content,
                    parentComment.id,
                  );
                  if (newReply != null) {
                    setState(() {
                      comments.add(newReply);
                      _replyingToCommentId = null;
                      _replyController.clear();
                    });
                  }
                }
              },
              decoration: InputDecoration(
                hintText: 'Write a reply...',
                hintStyle: TextStyle(color: mainColor),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: mainColor, width: 2),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () async {
              final value = _replyController.text;
              if (value.trim().isNotEmpty) {
                String content = value.trim();
                if (!content.startsWith(mention)) {
                  content = mention + content;
                }
                final newReply = await CommentService.addComment(
                  _currentUserId!,
                  widget.postId,
                  content,
                  parentComment.id,
                );
                if (newReply != null) {
                  setState(() {
                    comments.add(newReply);
                    _replyingToCommentId = null;
                    _replyController.clear();
                  });
                }
              }
            },
            icon: Icon(
              Icons.send,
              color: isDarkMode ? mainWhiteColor : mainBlackColor,
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDarkMode
                  ? mainBlackColor
                  : secondWhiteGrayColor,
              foregroundColor: isDarkMode ? secondBlackColor : secondWhiteColor,
            ),
          ),
          SizedBox(width: 5),
          commonTextButtonbuild(context, getCancel(context), () {
            setState(() {
              _replyingToCommentId = null;
              _replyController.clear();
            });
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final topLevelComments = comments.where((c) => c.parentId == null).toList();
    return Container(
      height: isMobile(context)
          ? MediaQuery.of(context).size.height * 0.90
          : MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 10),
          // Header
          Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      getComments(context),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? mainWhiteColor
                            : mainBlackColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Comments list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadComments,
                          child: Text(getRetry(context)),
                        ),
                      ],
                    ),
                  )
                : comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          getNoCommentsYet(context),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          getBeFirstToComment(context),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: topLevelComments
                        .map(
                          (comment) =>
                              _buildCommentWithReplies(comment, comments, 0),
                        )
                        .toList(),
                  ),
          ),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: isDarkMode ? secondBlackColor : secondWhiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              border: Border(
                top: BorderSide(
                  color: isDarkMode ? Colors.grey : Colors.grey,
                  width: 0.25,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: getWriteAComment(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,

                      hintStyle: TextStyle(color: Colors.grey),

                      labelStyle: TextStyle(color: mainColor),

                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: mainColor, width: 1),
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _addComment(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addComment,
                  icon: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      Icons.send,
                      color: isDarkMode ? mainWhiteColor : mainBlackColor,
                    ),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? mainBlackColor
                        : secondWhiteGrayColor,
                    foregroundColor: isDarkMode
                        ? secondBlackColor
                        : secondWhiteColor,
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
