import 'package:flutter/material.dart';

Widget buildReactionButton({
  required BuildContext context,
  required IconData icon,
  required int count,
  bool isActive = false,
  required Future<void> Function() onTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final Color iconColor = isActive
      ? Theme.of(context).colorScheme.primary
      : (isDark ? Colors.white : Colors.black87);
  final Color textColor = isActive
      ? Theme.of(context).colorScheme.primary
      : (isDark ? Colors.white70 : Colors.black54);

  return TextButton.icon(
    style: TextButton.styleFrom(
      backgroundColor: isActive
          ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
          : (isDark ? const Color(0xff262626) : const Color(0xffe0e0e0)),
      foregroundColor: iconColor,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    icon: Icon(icon, size: 20, color: iconColor),
    onPressed: () async {
      await onTap();
    },
    label: count > 0
        ? Text(
            _formatCount(count),
            style: TextStyle(fontSize: 15, color: textColor),
          )
        : const SizedBox.shrink(),
  );
}

String _formatCount(int count) {
  if (count < 1000) return count.toString();
  if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
  return '${(count / 1000000).toStringAsFixed(1)}M';
}
