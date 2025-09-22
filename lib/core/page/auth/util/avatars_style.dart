import 'package:everesports/core/page/auth/include/profile_footer.dart';
import 'package:everesports/database/config/config.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget AvatarStandardbuild(
  BuildContext context,
  user,
  int followersCount,
  int followingCount,
  int likeCount,
) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final size = MediaQuery.of(context).size;
  final width = size.width;
  // Responsive values
  double bannerHeight = width < 600
      ? 180
      : width < 900
      ? 260
      : 320;
  double avatarRadius = width < 600
      ? 150
      : width < 900
      ? 150
      : 150;
  double avatarImgHeight = avatarRadius * 2;
  double cardPadding = width < 600 ? 15 : 32;
  double maxCardWidth = width >= 900 ? double.infinity : 600;

  return Container(
    height: isMobile(context)
        ? 550
        : isTablet(context)
        ? 650
        : 550,
    padding: EdgeInsets.all(cardPadding),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Banner with avatar overlapping bottom
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  user["banner"].toString().isEmpty
                      ? Image.asset(
                          "assets/images/Standard.png",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: bannerHeight,
                        )
                      : Image.network(
                          "$fileServerBaseUrl/${user["banner"]}",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: bannerHeight,
                        ),
                  Container(
                    width: double.infinity,
                    height: bannerHeight,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            Positioned(
              top: isMobile(context)
                  ? 30
                  : isTablet(context)
                  ? 110
                  : 170,

              left: isDesktop(context) ? 40 : null,
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      "assets/images/Standard.png",
                      width: 300,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: isMobile(context)
                  ? 144
                  : isTablet(context)
                  ? 224
                  : 284,
              left: isDesktop(context) ? 140 : null,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      "$fileServerBaseUrl/${user["avatar"]}",
                      height: avatarImgHeight,
                      width: avatarImgHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.person, size: avatarRadius),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        profileFooterbuild(
          context,
          user["name"],
          user["username"],
          user["userId"],
          followersCount,
          followingCount,
          likeCount,
        ),
      ],
    ),
  );
}

Widget AvatarPremiumbuild(
  BuildContext context,
  user,
  int followersCount,
  int followingCount,
  int likeCount,
) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final size = MediaQuery.of(context).size;
  final width = size.width;
  // Responsive values
  double bannerHeight = width < 600
      ? 180
      : width < 900
      ? 260
      : 320;
  double avatarRadius = width < 600
      ? 150
      : width < 900
      ? 150
      : 150;
  double avatarImgHeight = avatarRadius * 2;
  double cardPadding = width < 600 ? 15 : 32;
  double maxCardWidth = width >= 900 ? double.infinity : 600;
  return Container(
    height: isMobile(context)
        ? 600
        : isTablet(context)
        ? 650
        : 550,
    padding: EdgeInsets.all(cardPadding),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Banner with avatar overlapping bottom
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    "$fileServerBaseUrl/${user["banner"]}",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: bannerHeight,
                  ),
                  Container(
                    width: double.infinity,
                    height: bannerHeight,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            Positioned(
              top: isMobile(context)
                  ? 30
                  : isTablet(context)
                  ? 110
                  : 170,

              left: isDesktop(context) ? 40 : null,
              child: Stack(
                children: [
                  Center(
                    child: Image.asset("assets/images/Premium.png", width: 300),
                  ),
                ],
              ),
            ),
            Positioned(
              top: isMobile(context)
                  ? 120
                  : isTablet(context)
                  ? 200
                  : 260,
              left: isDesktop(context) ? 130 : null,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      "$fileServerBaseUrl/${user["avatar"]}",
                      height: avatarImgHeight,
                      width: avatarImgHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.person, size: avatarRadius),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        profileFooterbuild(
          context,
          user["name"],
          user["username"],
          user["userId"],
          followersCount,
          followingCount,
          likeCount,
        ),
      ],
    ),
  );
}

Widget AvatarUltimatebuild(
  BuildContext context,
  user,
  int followersCount,
  int followingCount,
  int likeCount,
) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final size = MediaQuery.of(context).size;
  final width = size.width;
  // Responsive values
  double bannerHeight = width < 600
      ? 180
      : width < 900
      ? 260
      : 320;
  double avatarRadius = width < 600
      ? 150
      : width < 900
      ? 150
      : 150;
  double avatarImgHeight = avatarRadius * 2;
  double cardPadding = width < 600 ? 15 : 32;
  double maxCardWidth = width >= 900 ? double.infinity : 600;
  return Container(
    height: isMobile(context)
        ? 600
        : isTablet(context)
        ? 650
        : 550,
    padding: EdgeInsets.all(cardPadding),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Banner with avatar overlapping bottom
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    "$fileServerBaseUrl/${user["banner"]}",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: bannerHeight,
                  ),
                  Container(
                    width: double.infinity,
                    height: bannerHeight,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            Positioned(
              top: isMobile(context)
                  ? 30
                  : isTablet(context)
                  ? 110
                  : 170,

              left: isDesktop(context) ? 40 : null,
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      "assets/images/Ultimate.png",
                      width: 300,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: isMobile(context)
                  ? 120
                  : isTablet(context)
                  ? 200
                  : 260,
              left: isDesktop(context) ? 130 : null,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      "$fileServerBaseUrl/${user["avatar"]}",
                      height: avatarImgHeight,
                      width: avatarImgHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.person, size: avatarRadius),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        profileFooterbuild(
          context,
          user["name"],
          user["username"],
          user["userId"],
          followersCount,
          followingCount,
          likeCount,
        ),
      ],
    ),
  );
}
