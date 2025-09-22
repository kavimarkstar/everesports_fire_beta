import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LodingHome extends StatefulWidget {
  const LodingHome({super.key});

  @override
  State<LodingHome> createState() => _LodingHomeState();
}

class _LodingHomeState extends State<LodingHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Animate(
          onPlay: (controller) => controller.repeat(), // loop shimmer
          effects: [ShimmerEffect(duration: 2000.ms)],
          child: Container(
            width: 300,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color.fromARGB(255, 158, 158, 158),
            ),
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
