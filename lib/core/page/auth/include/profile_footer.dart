import 'package:everesports/core/page/auth/util/follow_like_count.dart';
import 'package:everesports/core/page/auth/util/profile_name.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';

Widget profileFooterbuild(
  BuildContext context,
  String name,
  String userName,
  String userId,
  //
  int followersCount,
  int followingCount,
  int likeCount,
) {
  return Column(
    children: [
      if (isMobile(context)) SizedBox(height: 150),
      if (isTablet(context)) SizedBox(height: 150),
      isMobile(context)
          ? profileNameColumnbuild(context, name, userName, userId)
          : isTablet(context)
          ? profileNameRowbuild(context, name, userName, userId)
          : profileNameDesktopRowbuild(context, name, userName, userId),
      isMobile(context)
          ? profileCountColumbuild(
              context,
              followersCount,
              followingCount,
              likeCount,
            )
          : isTablet(context)
          ? Column(
              children: [
                SizedBox(height: 10),
                tableprofileCountRowbuild(
                  context,
                  followersCount,
                  followingCount,
                  likeCount,
                ),
              ],
            )
          : Column(
              children: [
                SizedBox(height: 10),
                desktopprofileCountRowbuild(
                  context,
                  followersCount,
                  followingCount,
                  likeCount,
                ),
              ],
            ),
    ],
  );
}
