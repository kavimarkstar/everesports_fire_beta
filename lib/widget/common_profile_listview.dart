import 'dart:convert';
import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/auth/users_profiles.dart';
import 'package:everesports/database/config/config.dart';
import 'package:everesports/service/auth/follow_service.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:everesports/widget/common_line_elevated_button.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:flutter/material.dart';

class CommonProfileListview extends StatefulWidget {
  final String
  userId; // This should be the userId field (like "00000000"), not ObjectId
  final String username;
  final String? handle;
  final String? profileImageUrl;
  final String? followDate;
  final bool isFollowing;
  final String? currentUserId;
  final VoidCallback? onFollowStateChanged; // Callback to refresh parent data

  const CommonProfileListview({
    Key? key,
    required this.userId,
    required this.username,
    this.handle,
    this.profileImageUrl,
    this.followDate,
    this.isFollowing = false,
    this.currentUserId,
    this.onFollowStateChanged,
  }) : super(key: key);

  @override
  State<CommonProfileListview> createState() => _CommonProfileListviewState();
}

class _CommonProfileListviewState extends State<CommonProfileListview> {
  bool _isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.isFollowing;
  }

  Future<void> _toggleFollow() async {
    if (widget.currentUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFollowing) {
        await FollowService.unfollowUser(widget.currentUserId!, widget.userId);
        setState(() {
          _isFollowing = false;
        });
      } else {
        await FollowService.followUser(widget.currentUserId!, widget.userId);
        setState(() {
          _isFollowing = true;
        });
      }

      // Call the callback to refresh parent data
      if (widget.onFollowStateChanged != null) {
        widget.onFollowStateChanged!();
      }
    } catch (e) {
      print('Error toggling follow: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      ),
      onPressed: () {
        commonNavigationbuild(
          context,
          UsersProfilesPage(userId: widget.userId),
        );
        // Navigate to user profile
        // Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfilePage(userId: userId)));
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            _buildProfileAvatar(context, isDark),
            const SizedBox(width: 16),
            _buildUserInfo(),
            _buildFollowButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(250),
        gradient: LinearGradient(
          colors: isDark
              ? [stroyColor1, stroyColor2]
              : [stroyColor1, stroyColor2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(250),
            color: isDark ? mainBlackColor : mainWhiteColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: _buildProfileImageProvider(
                widget.profileImageUrl,
              ),
              backgroundColor: const Color.fromARGB(255, 83, 83, 83),
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider _buildProfileImageProvider(String? value) {
    if (value == null || value.isEmpty) {
      return const AssetImage("assets/icons/profile_users.jpeg");
    }
    // 1) Data URL (data:image/*;base64,....)
    if (value.startsWith('data:image')) {
      final commaIndex = value.indexOf(',');
      if (commaIndex != -1 && commaIndex < value.length - 1) {
        final base64Part = value.substring(commaIndex + 1);
        try {
          return MemoryImage(const Base64Decoder().convert(base64Part));
        } catch (_) {
          /* continue */
        }
      }
    }
    // 2) Absolute URL
    if (value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.contains('://')) {
      return NetworkImage(value);
    }
    // 3) Try base64 decode (allowing slashes and plus characters)
    try {
      final bytes = const Base64Decoder().convert(value);
      if (bytes.isNotEmpty) {
        return MemoryImage(bytes);
      }
    } catch (_) {
      /* not base64 */
    }
    // 4) Treat as relative path on file server
    return NetworkImage("$fileServerBaseUrl/$value");
  }

  Widget _buildUserInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              widget.username,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          if (widget.handle != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                widget.handle!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          if (widget.followDate != null && widget.followDate!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                widget.followDate!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context) {
    // Don't show follow button for current user
    if (widget.currentUserId == widget.userId) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'You',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: _isLoading
            ? commonLineElevatedButtonbuild(context, "...", () {})
            : _isFollowing
            ? commonLineElevatedButtonbuild(context, "Unfollow", () {
                _toggleFollow();
              })
            : commonElevatedButtonFollowPostsButtonbuild(context, "Follow", () {
                _toggleFollow();
              }),
      ),
    );
  }
}
