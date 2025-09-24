// Separate stateful widget for each spark item to isolate rebuilds
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/spark/widget/build_Reaction_Button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SparkItemWidget extends StatefulWidget {
  final String sparkId;
  final String? profileBase64;
  final String name;
  final String username;
  final Timestamp? timestamp;
  final String title;
  final String description;
  final String truncatedTitle;
  final String truncatedDescription;
  final bool shouldTruncateTitle;
  final bool shouldTruncate;
  final bool isTitleExpanded;
  final bool isExpanded;

  final int comments;

  final VoidCallback onTitleExpand;
  final VoidCallback onDescriptionExpand;

  final VoidCallback onComment;
  final DateFormat timestampFormat;

  final int likesCount;
  final int dislikesCount;
  final bool isLiked;
  final bool isDisliked;
  final Future<void> Function() onLike;
  final Future<void> Function() onDislike;

  const SparkItemWidget({
    super.key,
    required this.sparkId,
    required this.profileBase64,
    required this.name,
    required this.username,
    required this.timestamp,
    required this.title,
    required this.description,
    required this.truncatedTitle,
    required this.truncatedDescription,
    required this.shouldTruncateTitle,
    required this.shouldTruncate,
    required this.isTitleExpanded,
    required this.isExpanded,
    required this.comments,
    required this.onTitleExpand,
    required this.onDescriptionExpand,
    required this.onComment,
    required this.timestampFormat,
    required this.likesCount,
    required this.dislikesCount,
    required this.isLiked,
    required this.isDisliked,
    required this.onLike,
    required this.onDislike,
  });

  @override
  __SparkItemWidgetState createState() => __SparkItemWidgetState();
}

class __SparkItemWidgetState extends State<SparkItemWidget> {
  Widget _buildProfileImage(String? profileBase64) {
    if (profileBase64 != null && profileBase64.isNotEmpty) {
      try {
        return CircleAvatar(
          backgroundColor: Colors.transparent,
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info header
            Row(
              children: [
                _buildProfileImage(widget.profileBase64),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.username,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (widget.timestamp != null)
                  Text(
                    widget.timestampFormat.format(widget.timestamp!.toDate()),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                IconButton(
                  onPressed: () {
                    // todo
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Spark content
            if (widget.title.isNotEmpty && widget.title != "No Title")
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.shouldTruncateTitle || widget.isTitleExpanded)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (widget.shouldTruncateTitle &&
                            widget.isTitleExpanded)
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: widget.onTitleExpand,
                            child: Text(
                              "See less",
                              style: TextStyle(fontSize: 14, color: mainColor),
                            ),
                          ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.truncatedTitle,
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
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: widget.onTitleExpand,
                          child: Text(
                            "See more",
                            style: TextStyle(fontSize: 14, color: mainColor),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            // Description
            if (!widget.shouldTruncate || widget.isExpanded)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (widget.shouldTruncate && widget.isExpanded)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: widget.onDescriptionExpand,
                      child: Text(
                        "See less",
                        style: TextStyle(fontSize: 14, color: mainColor),
                      ),
                    ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.truncatedDescription,
                    style: const TextStyle(fontSize: 16),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: widget.onDescriptionExpand,
                    child: Text(
                      "See more",
                      style: TextStyle(fontSize: 14, color: mainColor),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            // Actions row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    buildReactionButton(
                      icon: Icons.thumb_up,
                      count: widget.likesCount,
                      isActive: widget.isLiked,
                      onTap: widget.onLike,
                      context: context,
                    ),
                    const SizedBox(width: 20),
                    buildReactionButton(
                      icon: Icons.thumb_down,
                      count: widget.dislikesCount,
                      isActive: widget.isDisliked,
                      onTap: widget.onDislike,
                      context: context,
                    ),
                  ],
                ),
                buildReactionButton(
                  icon: Icons.comment_rounded,
                  count: widget.comments,
                  onTap: () async {
                    widget.onComment();
                  },
                  context: context,
                  isActive: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
