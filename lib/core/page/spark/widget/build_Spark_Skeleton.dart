import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

Widget buildSparkSkeleton() {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 20,
                child: Animate(
                  onPlay: (controller) => controller.repeat(), // loop shimmer
                  effects: [ShimmerEffect(duration: 2000.ms)],
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      color: const Color.fromARGB(255, 158, 158, 158),
                    ),
                    alignment: Alignment.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100, height: 16, color: Colors.grey[300]),
                  const SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 12,
                    child: Animate(
                      onPlay: (controller) =>
                          controller.repeat(), // loop shimmer
                      effects: [ShimmerEffect(duration: 2000.ms)],
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color.fromARGB(255, 158, 158, 158),
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 20,
            child: Animate(
              onPlay: (controller) => controller.repeat(), // loop shimmer
              effects: [ShimmerEffect(duration: 2000.ms)],
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color.fromARGB(255, 158, 158, 158),
                ),
                alignment: Alignment.center,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 60,

            child: Animate(
              onPlay: (controller) => controller.repeat(), // loop shimmer
              effects: [ShimmerEffect(duration: 2000.ms)],
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color.fromARGB(255, 158, 158, 158),
                ),
                alignment: Alignment.center,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              3,
              (index) => Container(
                width: 40,
                height: 24,
                child: Animate(
                  onPlay: (controller) => controller.repeat(), // loop shimmer
                  effects: [ShimmerEffect(duration: 2000.ms)],
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color.fromARGB(255, 158, 158, 158),
                    ),
                    alignment: Alignment.center,
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

Widget buildLoadingState() {
  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: 5,
    itemBuilder: (context, index) => buildSparkSkeleton(),
  );
}
