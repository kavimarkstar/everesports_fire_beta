import 'package:flutter/material.dart';

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
              const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100, height: 16, color: Colors.grey[300]),
                  const SizedBox(height: 4),
                  Container(width: 60, height: 12, color: Colors.grey[300]),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 20,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              4,
              (index) =>
                  Container(width: 40, height: 24, color: Colors.grey[300]),
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
