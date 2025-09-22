import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/home/service/like_service.dart';
import 'package:everesports/core/page/profile/page/follow_list_page.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:flutter/material.dart';
import 'package:everesports/service/auth/follow_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FollowCounts extends StatefulWidget {
  final String? userId;
  const FollowCounts({Key? key, this.userId}) : super(key: key);

  @override
  State<FollowCounts> createState() => _FollowCountsState();
}

class _FollowCountsState extends State<FollowCounts> {
  String? _userId;
  List<String> _followingUserIds = [];
  List<String> _followerUserIds = [];

  @override
  void initState() {
    super.initState();
    _initUserId();
  }

  Future<void> _initUserId() async {
    if (widget.userId != null) {
      setState(() {
        _userId = widget.userId;
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = prefs.getString('userId');
      });
    }
    if (_userId != null) {
      _fetchFollowLists(_userId!);
    }
  }

  Future<void> _fetchFollowLists(String userId) async {
    final following = await FollowService.getFollowingUserIds(userId);
    final followers = await FollowService.getFollowerUserIds(userId);
    setState(() {
      _followingUserIds = following;
      _followerUserIds = followers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Row(
        mainAxisAlignment: !isDesktop(context)
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 10),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: !isDesktop(context) ? 5 : 0,
              vertical: !isDesktop(context) ? 20 : 5,
            ),
            child: !isDesktop(context)
                ? _countColumn(
                    context,
                    isFollowing: true,
                    onTap: () {
                      if (_userId != null) {
                        commonNavigationbuild(
                          context,
                          FollowListPage(initialTab: 0),
                        );
                      }
                    },
                  )
                : _countRow(
                    context,
                    isFollowing: true,
                    onTap: () {
                      if (_userId != null) {
                        commonNavigationbuild(
                          context,
                          FollowListPage(initialTab: 0),
                        );
                      }
                    },
                  ),
          ),
          if (!isDesktop(context))
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: !isDesktop(context) ? 0 : 0,
                vertical: !isDesktop(context) ? 25 : 0,
              ),
              child: Container(
                height: 40,
                width: 1,
                color: isDark ? mainWhiteColor : mainBlackColor,
              ),
            ),
          if (isDesktop(context)) SizedBox(width: 10),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: !isDesktop(context) ? 5 : 15,
              vertical: !isDesktop(context) ? 20 : 5,
            ),
            child: !isDesktop(context)
                ? _countColumn(
                    context,
                    isFollowing: false,
                    onTap: () {
                      // Debug: Confirm Followers count tap is registered
                      print('Followers tapped');
                      if (_userId != null) {
                        commonNavigationbuild(
                          context,
                          FollowListPage(initialTab: 1),
                        );
                      }
                    },
                  )
                : _countRow(
                    context,
                    isFollowing: false,
                    onTap: () {
                      // Debug: Confirm Followers count tap is registered
                      print('Followers tapped');
                      if (_userId != null) {
                        commonNavigationbuild(
                          context,
                          FollowListPage(initialTab: 1),
                        );
                      }
                    },
                  ),
          ),
          if (!isDesktop(context))
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: !isDesktop(context) ? 0 : 0,
                vertical: !isDesktop(context) ? 25 : 0,
              ),
              child: Container(
                height: 40,
                width: 1,
                color: isDark ? mainWhiteColor : mainBlackColor,
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: !isDesktop(context) ? 5 : 15,
              vertical: !isDesktop(context) ? 20 : 5,
            ),
            child: !isDesktop(context)
                ? _likeColumn(
                    context,
                    onTap: () {
                      if (_userId != null) {
                        commonNavigationbuild(
                          context,
                          FollowListPage(initialTab: 2),
                        );
                      }
                    },
                  )
                : _likeRow(
                    context,
                    onTap: () {
                      if (_userId != null) {
                        commonNavigationbuild(
                          context,
                          FollowListPage(initialTab: 2),
                        );
                      }
                    },
                  ),
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }

  // Display following and follower user IDs below the counts
  Widget buildFollowIdLists() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_followingUserIds.isNotEmpty) ...[
          const Text('Following User IDs:'),
          ..._followingUserIds.map((id) => Text(id)),
        ],
        if (_followerUserIds.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Follower User IDs:'),
          ..._followerUserIds.map((id) => Text(id)),
        ],
      ],
    );
  }

  Widget _countColumn(
    BuildContext context, {
    required bool isFollowing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<int>(
      future: _userId == null
          ? Future.value(0)
          : isFollowing
          ? FollowService.followingCount(_userId!)
          : FollowService.followersCount(_userId!),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        final label = isFollowing ? "Following" : "Followers";
        final child = columViewbuild(
          context,
          _formatCount(count),
          label,
          isDark,
        );
        return onTap != null
            ? ElevatedButton(
                onPressed: onTap,
                style:
                    ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ).copyWith(
                      overlayColor: MaterialStateProperty.all(
                        Colors.transparent,
                      ),
                    ),
                child: child,
              )
            : child;
      },
    );
  }

  Widget _countRow(
    BuildContext context, {
    required bool isFollowing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<int>(
      future: _userId == null
          ? Future.value(0)
          : isFollowing
          ? FollowService.followingCount(_userId!)
          : FollowService.followersCount(_userId!),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        final label = isFollowing ? "Following" : "Followers";
        final child = rowViewbuild(context, _formatCount(count), label, isDark);
        return onTap != null
            ? ElevatedButton(
                onPressed: onTap,
                style:
                    ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ).copyWith(
                      overlayColor: MaterialStateProperty.all(
                        Colors.transparent,
                      ),
                    ),
                child: child,
              )
            : child;
      },
    );
  }

  Widget _likeColumn(BuildContext context, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<int>(
      future: _userId == null
          ? Future.value(0)
          : LikeService.getLikesReceivedCount(_userId!),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        final child = columViewbuild(
          context,
          _formatCount(count),
          "Likes",
          isDark,
        );
        return onTap != null
            ? ElevatedButton(
                onPressed: onTap,
                style:
                    ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ).copyWith(
                      overlayColor: MaterialStateProperty.all(
                        Colors.transparent,
                      ),
                    ),
                child: child,
              )
            : child;
      },
    );
  }

  Widget _likeRow(BuildContext context, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<int>(
      future: _userId == null
          ? Future.value(0)
          : LikeService.getLikesReceivedCount(_userId!),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        final child = rowViewbuild(
          context,
          _formatCount(count),
          "Likes",
          isDark,
        );
        return onTap != null
            ? ElevatedButton(
                onPressed: onTap,
                style:
                    ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ).copyWith(
                      overlayColor: MaterialStateProperty.all(
                        Colors.transparent,
                      ),
                    ),
                child: child,
              )
            : child;
      },
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000000) {
      return '${(count / 1000000000).toStringAsFixed(1)}B';
    } else if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  Widget columViewbuild(
    BuildContext context,
    String text,
    String text2,
    bool isDark,
  ) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: isDark ? mainWhiteColor : mainBlackColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          text2,
          style: TextStyle(color: isDark ? mainWhiteColor : mainBlackColor),
        ),
      ],
    );
  }

  Widget rowViewbuild(
    BuildContext context,
    String text,
    String text2,
    bool isDark,
  ) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            color: isDark ? mainWhiteColor : mainBlackColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 5),
        Text(
          text2,
          style: TextStyle(color: isDark ? mainWhiteColor : mainBlackColor),
        ),
      ],
    );
  }
}
