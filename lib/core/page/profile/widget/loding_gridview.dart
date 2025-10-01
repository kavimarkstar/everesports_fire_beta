import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

Widget buildLoadingGridView(BuildContext context) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const AlwaysScrollableScrollPhysics(),

    itemCount: isMobile(context) ? 9 : 8,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: isMobile(context) ? 3 : 4,
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      childAspectRatio: 0.75,
    ),
    itemBuilder: (context, index) {
      return Card(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.hardEdge,
        child: Center(
          child: Animate(
            onPlay: (controller) => controller.repeat(), // loop shimmer
            effects: [ShimmerEffect(duration: 2000.ms)],
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                color: const Color.fromARGB(255, 158, 158, 158),
              ),
              alignment: Alignment.center,
            ),
          ),
        ),
      );
    },
  );
}
