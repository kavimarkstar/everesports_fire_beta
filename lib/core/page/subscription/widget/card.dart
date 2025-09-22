import 'package:everesports/Theme/colors.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:flutter/material.dart';

Widget premiumCardBuild(
  BuildContext context,
  Map<String, String> plan,
  VoidCallback? onSubscribePressed, {
  bool selected = false,
}) {
  final double expandedHeight = 180;
  final double collapsedHeight = 140;
  final bool isDrk = Theme.of(context).brightness == Brightness.dark;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    height: selected ? expandedHeight : collapsedHeight,
    transform: selected
        ? (Matrix4.identity()..scale(1.05))
        : Matrix4.identity(),
    transformAlignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: selected ? mainColor : Colors.grey.withOpacity(0.2),
        width: selected ? 2.5 : 1,
      ),
      boxShadow: selected
          ? [
              BoxShadow(
                color: mainColor.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
    ),
    child: Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Title
            Text(
              plan['title'] ?? '',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: selected
                    ? mainColor
                    : isDrk
                    ? mainWhiteColor
                    : mainBlackColor,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            if (plan['items'] != null && plan['items']!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (plan['items'] as String)
                      .split(', ')
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.check, size: 20, color: mainColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: selected
                                        ? mainColor
                                        : isDrk
                                        ? mainWhiteColor
                                        : mainBlackColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],

            Container(
              width: double.infinity,
              height: 75,
              decoration: BoxDecoration(
                color: selected
                    ? mainColor.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/icons/cristol.png", height: 35),
                    const SizedBox(width: 10),
                    Text(
                      _formatPrice(plan['price'] ?? ''),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: selected ? mainColor : Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ), // Price
            SizedBox(
              height: 75,
              width: double.infinity,
              child: commonElevatedButtonbuild(
                context,
                "Subscribe",
                onSubscribePressed,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper function to format price and remove decimal places
String _formatPrice(String price) {
  if (price.isEmpty) return '';

  // If price contains a decimal point, remove it and everything after
  if (price.contains('.')) {
    final parts = price.split('.');
    if (parts.isNotEmpty) {
      return parts[0];
    }
  }

  return price;
}
