import 'package:everesports/core/page/esports/model/tournament.dart';
import 'package:everesports/core/page/esports/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LodingGridView extends StatefulWidget {
  const LodingGridView({super.key});

  @override
  State<LodingGridView> createState() => _LodingGridViewState();
}

class _LodingGridViewState extends State<LodingGridView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Tournament>>(
      future: Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print('Error in FutureBuilder:  [200m${snapshot.error} [0m');
          return Center(child: Text('Error:  [200m${snapshot.error} [0m'));
        }
        final items = snapshot.data ?? [];
        print('Loaded tournaments in widget: ' + items.toString());
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 100),
            child: const Center(child: Text('No tournaments found.')),
          );
        }
        int crossAxisCount = 1;
        double width = MediaQuery.of(context).size.width;
        if (width >= 1000) {
          crossAxisCount = 3;
        } else if (width >= 600) {
          crossAxisCount = 2;
        }
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: context.gridAspectRatio,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.getString('userId');
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Animate(
                              onPlay: (controller) =>
                                  controller.repeat(), // loop shimmer
                              effects: [ShimmerEffect(duration: 2000.ms)],
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: const Color.fromARGB(
                                    255,
                                    158,
                                    158,
                                    158,
                                  ),
                                ),
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            decoration: BoxDecoration(),
                            child: Animate(
                              onPlay: (controller) =>
                                  controller.repeat(), // loop shimmer
                              effects: [ShimmerEffect(duration: 2000.ms)],
                              child: Container(
                                width: 200,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(160),
                                  color: const Color.fromARGB(
                                    255,
                                    158,
                                    158,
                                    158,
                                  ),
                                ),
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.transparent,

                            child: Animate(
                              onPlay: (controller) =>
                                  controller.repeat(), // loop shimmer
                              effects: [ShimmerEffect(duration: 2000.ms)],
                              child: Container(
                                width: 300,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(160),
                                  color: const Color.fromARGB(
                                    255,
                                    158,
                                    158,
                                    158,
                                  ),
                                ),
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Animate(
                                  onPlay: (controller) =>
                                      controller.repeat(), // loop shimmer
                                  effects: [ShimmerEffect(duration: 2000.ms)],
                                  child: Container(
                                    width: 300,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: const Color.fromARGB(
                                        255,
                                        158,
                                        158,
                                        158,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Animate(
                                  onPlay: (controller) =>
                                      controller.repeat(), // loop shimmer
                                  effects: [ShimmerEffect(duration: 2000.ms)],
                                  child: Container(
                                    width: 150,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: const Color.fromARGB(
                                        255,
                                        158,
                                        158,
                                        158,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                ),
                                if (true) ...[
                                  const SizedBox(height: 2),
                                  Animate(
                                    onPlay: (controller) =>
                                        controller.repeat(), // loop shimmer
                                    effects: [ShimmerEffect(duration: 2000.ms)],
                                    child: Container(
                                      width: 100,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: const Color.fromARGB(
                                          255,
                                          158,
                                          158,
                                          158,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Animate(
                            onPlay: (controller) =>
                                controller.repeat(), // loop shimmer
                            effects: [ShimmerEffect(duration: 2000.ms)],
                            child: Container(
                              width: 10,
                              height: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: const Color.fromARGB(255, 158, 158, 158),
                              ),
                              alignment: Alignment.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
