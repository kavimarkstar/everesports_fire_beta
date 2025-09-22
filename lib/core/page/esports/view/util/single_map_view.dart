import 'package:everesports/Theme/colors.dart';
import 'package:everesports/database/config/config.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

Widget buildSingleMapView(
  BuildContext context,
  String title,
  String imagePath,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: isDark
          ? Colors.white.withOpacity(0.10)
          : Colors.black.withOpacity(0.07),
      child: Stack(
        children: [
          // Modern background image with a subtle overlay
          SizedBox(
            height: 170,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  "$fileServerBaseUrl$imagePath",
                  fit: BoxFit.cover,
                  color: isDark
                      ? Colors.black.withOpacity(0.25)
                      : Colors.white.withOpacity(0.08),
                  colorBlendMode: BlendMode.darken,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isDark
                            ? Colors.black.withOpacity(0.65)
                            : Colors.white.withOpacity(0.45),
                        Colors.transparent,
                        isDark
                            ? Colors.black.withOpacity(0.65)
                            : Colors.white.withOpacity(0.45),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Glassmorphism effect card at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.white.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(18),
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
                    child: Row(
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
                            Icons.location_on,
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
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
