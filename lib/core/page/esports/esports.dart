import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/esports/model/tournament.dart';
import 'package:everesports/core/page/esports/service/mongo_service.dart';
import 'package:everesports/core/page/esports/widget/gridview.dart';
import 'package:everesports/core/page/esports/widget/image_slider.dart';
import 'package:everesports/core/page/esports/widget/loding_gridview.dart';
import 'package:everesports/database/config/config.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:io' show Platform;
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class EsportsPage extends StatefulWidget {
  const EsportsPage({super.key});

  @override
  State<EsportsPage> createState() => _EsportsPageState();
}

class _EsportsPageState extends State<EsportsPage> {
  late Future<List<Tournament>> _tournamentsFuture;
  late Future<List<Map<String, dynamic>>> _bannersFuture;
  Map<String, Map<String, dynamic>> _gameNameToData = {};

  bool isLoading = false;

  List<String> buttons = [
    "All",
    "Sniper",
    "Dota 2",
    "League of Legends",
    "Valorant",
  ];
  String selectedFilter = "All";
  @override
  void initState() {
    super.initState();
    _tournamentsFuture = MongoEsportsService.getTournaments();
    _bannersFuture = MongoEsportsService.getBanners();
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    final db = await mongo.Db.create(configDatabase);
    await db.open();
    final coll = db.collection('game_name');
    final games = await coll.find().toList();
    await db.close();
    setState(() {
      _gameNameToData = {
        for (final g in games) (g['name'] ?? '').toString().toUpperCase(): g,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final isdark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Scaffold(
        appBar: isMobile(context)
            ? AppBar(title: const Text("Tournaments"))
            : null,
        body: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _bannersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return SizedBox(
                        height: 200,
                        child: Center(child: Text('Error loading banners')),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const AutoImageSlider();
                    }
                    // Map imagePath to full URL
                    String baseUrl = fileServerBaseUrl;
                    final imageUrls = snapshot.data!
                        .map(
                          (b) => b['imagePath'] != null
                              ? baseUrl + "/" + b['imagePath']
                              : null,
                        )
                        .whereType<String>()
                        .toList();
                    return AutoImageSlider(imageUrls: imageUrls);
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  child: const Text(
                    "Tournaments",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 35,
                  child: Builder(
                    builder: (context) {
                      // Only show scroll buttons on Windows, macOS, Linux (not web)
                      if (!kIsWeb &&
                          (Platform.isWindows ||
                              Platform.isMacOS ||
                              Platform.isLinux)) {
                        final ScrollController scrollController =
                            ScrollController();
                        return Row(
                          children: [
                            SizedBox(width: 24),
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                              ),
                              onPressed: () {
                                scrollController.animateTo(
                                  scrollController.offset - 120,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                            ),
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: buttons.length,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                itemBuilder: (context, index) {
                                  final isSelected =
                                      selectedFilter == buttons[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        backgroundColor: isSelected
                                            ? (isdark
                                                  ? mainWhiteColor
                                                  : mainBlackColor)
                                            : (isdark
                                                  ? secondBlackColor
                                                  : mainWhiteColor),
                                        foregroundColor: isSelected
                                            ? (isdark
                                                  ? mainBlackColor
                                                  : mainWhiteColor)
                                            : Colors.black,
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          isLoading = true;
                                          selectedFilter = buttons[index];
                                        });

                                        // Simulate a small delay for smooth loading transition
                                        await Future.delayed(
                                          const Duration(milliseconds: 300),
                                        );

                                        setState(() {
                                          isLoading = false;
                                        });
                                      },
                                      child: Text(
                                        buttons[index],
                                        style: TextStyle(
                                          color: isSelected
                                              ? (isdark
                                                    ? mainBlackColor
                                                    : mainWhiteColor)
                                              : (isdark
                                                    ? mainWhiteColor
                                                    : mainBlackColor),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                              ),
                              onPressed: () {
                                scrollController.animateTo(
                                  scrollController.offset + 120,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                            ),
                            SizedBox(width: 24),
                          ],
                        );
                      } else {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: buttons.length,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemBuilder: (context, index) {
                            final isSelected = selectedFilter == buttons[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: isSelected
                                      ? (isdark
                                            ? mainWhiteColor
                                            : mainBlackColor)
                                      : (isdark
                                            ? secondBlackColor
                                            : mainWhiteColor),
                                  foregroundColor: isSelected
                                      ? (isdark
                                            ? mainBlackColor
                                            : mainWhiteColor)
                                      : Colors.black,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                    selectedFilter = buttons[index];
                                  });

                                  // Simulate a small delay for smooth loading transition
                                  await Future.delayed(
                                    const Duration(milliseconds: 300),
                                  );

                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                child: Text(
                                  buttons[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? (isdark
                                              ? mainBlackColor
                                              : mainWhiteColor)
                                        : (isdark
                                              ? mainWhiteColor
                                              : mainBlackColor),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),

                FutureBuilder<List<Tournament>>(
                  future: _tournamentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: LodingGridView());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: \\${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return const LodingGridView();
                    }
                    List<Tournament> tournaments = snapshot.data!;
                    if (selectedFilter != "All") {
                      tournaments = tournaments
                          .where(
                            (t) =>
                                t.gameName.toUpperCase() ==
                                    selectedFilter.toUpperCase() ||
                                (t.subGameMode != null &&
                                    t.subGameMode.toUpperCase() ==
                                        selectedFilter.toUpperCase()),
                          )
                          .toList();
                    }
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      child: isLoading
                          ? LodingGridView()
                          : EsportsGridView(
                              key: ValueKey(
                                selectedFilter,
                              ), // Important for AnimatedSwitcher to detect change
                              tournamentsFuture: Future.value(tournaments),
                              gameNameToData: _gameNameToData,
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
