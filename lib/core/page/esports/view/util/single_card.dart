import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';

Widget buildSingleCard(
  BuildContext context,
  String title,
  IconData icon,
  VoidCallback onPressed,
  VoidCallback onTap,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    child: GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        color: isDark
            ? Colors.white.withOpacity(0.10)
            : Colors.black.withOpacity(0.07),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.13)
                  : Colors.black.withOpacity(0.08),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.18)
                    : Colors.grey.withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.10)
                            : Colors.black.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        icon,
                        color: isDark ? mainWhiteColor : mainBlackColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? mainWhiteColor : mainBlackColor,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                // Fix: Use Icons.arrow_drop_down_rounded for better compatibility
                IconButton(
                  onPressed: onPressed,
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: isDark ? mainWhiteColor : mainBlackColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget buildPrivacyPolicyCard(
  BuildContext context,
  String title,
  IconData icon,
  VoidCallback onPressed,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: isDark
          ? Colors.red.withOpacity(0.20)
          : Colors.red.withOpacity(0.20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.red : Colors.red,
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.red.withOpacity(0.18)
                  : Colors.grey.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.red.withOpacity(0.50)
                          : Colors.red.withOpacity(0.50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      icon,
                      color: isDark ? mainWhiteColor : mainBlackColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? mainWhiteColor : mainBlackColor,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              // Fix: Use Icons.arrow_drop_down_rounded for better compatibility
              IconButton(
                onPressed: onPressed,
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: isDark ? mainWhiteColor : mainBlackColor,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
