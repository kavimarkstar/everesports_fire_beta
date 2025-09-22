import 'package:flutter/material.dart';

Widget profileCountColumbuild(
  BuildContext context,
  int FollowersCount,
  int FollowingCount,
  int LikesCount,
) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    decoration: BoxDecoration(
      color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildCountItem(context, FollowersCount, "Followers"),
        _buildDivider(context),
        _buildCountItem(context, FollowingCount, "Following"),
        _buildDivider(context),
        _buildCountItem(context, LikesCount, "Likes"),
      ],
    ),
  );
}

Widget desktopprofileCountRowbuild(
  BuildContext context,
  int FollowersCount,
  int FollowingCount,
  int LikesCount,
) {
  return Row(
    children: [
      SizedBox(width: 370),
      _deskTopbuildCountItem(context, FollowersCount, "Followers"),
      SizedBox(width: 20),
      _buildDivider(context),
      SizedBox(width: 20),
      _deskTopbuildCountItem(context, FollowingCount, "Following"),
      SizedBox(width: 20),
      _buildDivider(context),
      SizedBox(width: 20),
      _deskTopbuildCountItem(context, LikesCount, "Likes"),
    ],
  );
}

Widget tableprofileCountRowbuild(
  BuildContext context,
  int FollowersCount,
  int FollowingCount,
  int LikesCount,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      _buildCountItem(context, FollowersCount, "Followers"),

      _buildDivider(context),
      _buildCountItem(context, FollowingCount, "Following"),
      _buildDivider(context),

      _buildCountItem(context, LikesCount, "Likes"),
    ],
  );
}

Widget _buildCountItem(BuildContext context, int count, String label) {
  return Column(
    children: [
      countbuild(context, _formatCount(count)),
      const SizedBox(height: 4),
      textbuild(context, label),
    ],
  );
}

Widget _deskTopbuildCountItem(BuildContext context, int count, String label) {
  return Column(
    children: [
      countbuild(context, _formatCount(count)),
      const SizedBox(height: 4),
      textbuild(context, label),
    ],
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

Widget _buildDivider(BuildContext context) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    width: 1,
    height: 40,
    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
  );
}

Widget countbuild(BuildContext context, String text) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Text(
    text,
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? Colors.white : Colors.black87,
    ),
    textAlign: TextAlign.center,
  );
}

Widget textbuild(BuildContext context, String text) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Text(
    text,
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
    ),
    textAlign: TextAlign.center,
  );
}
