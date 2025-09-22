import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

Widget storiesLoding(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: 10,
    itemBuilder: (context, index) {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 70,
            height: 70,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(250),
              ),
              child: Center(
                child: Animate(
                  onPlay: (controller) => controller.repeat(), // loop shimmer
                  effects: [ShimmerEffect(duration: 1800.ms)],
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                    ),
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Animate(
                onPlay: (controller) => controller.repeat(), // loop shimmer
                effects: [ShimmerEffect(duration: 1800.ms)],
                child: Container(
                  width: 60,
                  height: 20,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  ),
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
