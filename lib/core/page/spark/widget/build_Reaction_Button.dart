import 'package:flutter/material.dart';

Widget buildReactionButton({
  required IconData icon,
  required int count,
  required VoidCallback? onPressed,
}) {
  return TextButton.icon(
    icon: Icon(icon, size: 20),
    label: Text(
      count > 0 ? _formatCount(count) : '',
      style: const TextStyle(fontSize: 12),
    ),
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: onPressed == null ? Colors.grey[400] : Colors.grey[600],
    ),
  );
}

String _formatCount(int count) {
  if (count < 1000) return count.toString();
  if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
  return '${(count / 1000000).toStringAsFixed(1)}M';
}
