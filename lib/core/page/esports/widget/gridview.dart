import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/esports/model/tournament.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/core/page/esports/util/responsive.dart';
import 'package:everesports/core/page/esports/view/single_tournament_view.dart';
import 'package:everesports/core/page/esports/widget/loding_gridview.dart';
import 'package:everesports/database/config/config.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EsportsGridView extends StatefulWidget {
  final Future<List<Tournament>> tournamentsFuture;
  final Map<String, Map<String, dynamic>> gameNameToData;
  const EsportsGridView({
    super.key,
    required this.tournamentsFuture,
    required this.gameNameToData,
  });

  @override
  State<EsportsGridView> createState() => _EsportsGridViewState();
}

class _EsportsGridViewState extends State<EsportsGridView> {
  ImageProvider _buildGameImageProvider(Map<String, dynamic>? gameData) {
    if (gameData == null) {
      return const AssetImage('assets/images/placeholder.png'); // Fallback
    }

    final imageBase64 = gameData['image_base64'] as String?;
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(imageBase64));
      } catch (e) {
        // Not a valid base64 string, fall through to check image_path
      }
    }

    final imagePath = gameData['image_path'] as String?;
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http')) {
        return NetworkImage(imagePath);
      }
      // Handle relative paths
      final baseUrl = fileServerBaseUrl.endsWith('/')
          ? fileServerBaseUrl
          : '$fileServerBaseUrl/';
      final finalPath = imagePath.startsWith('/')
          ? imagePath.substring(1)
          : imagePath;
      return NetworkImage('$baseUrl$finalPath');
    }

    // If no image is available
    return const AssetImage('assets/images/placeholder.png'); // Fallback
  }

  /// Converts a binary string (e.g., "01101...") into a Uint8List.
  Uint8List _binaryStringToBytes(String binary) {
    // Ensure the string length is a multiple of 8 for byte conversion.
    // Missing bits will be padded with '0', which might affect the last byte.
    final paddedBinary = binary.padRight((binary.length + 7) ~/ 8 * 8, '0');
    final bytes = <int>[];
    for (int i = 0; i < paddedBinary.length; i += 8) {
      final byteString = paddedBinary.substring(i, i + 8);
      try {
        bytes.add(int.parse(byteString, radix: 2));
      } catch (e) {
        // In case of a parsing error with a substring, add a placeholder byte.
        bytes.add(0);
      }
    }
    return Uint8List.fromList(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Tournament>>(
      future: widget.tournamentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LodingGridView());
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
            child: const LodingGridView(),
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
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: context.gridAspectRatio,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final gameData =
                  widget.gameNameToData[item.gameName.toUpperCase()];
              return GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString('userId');
                  if (userId != null) {
                    isMobile(context)
                        ? commonNavigationbuild(
                            context,
                            SingalTournamentViewPage(
                              imagePath: gameData?['image_base64'] ?? '',
                              userId: userId,
                              tournament: item,
                            ),
                          )
                        : SingalTournamentPopUp.showSingalTournamentPopUp(
                            context,
                            title: item.title,

                            item: item,
                            imagePath: gameData?['image_base64'] ?? '',
                            selectedWeapons: item.selectedWeapons,
                            selectedMap: item.selectedMap,
                          );
                  } else {
                    // Optionally handle not logged in
                  }
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
                            child: FutureBuilder<DocumentSnapshot>(
                              future: item.imageThumb.isNotEmpty
                                  ? FirebaseFirestore.instance
                                        .collection('thumbnail')
                                        .doc(item.imageThumb)
                                        .get()
                                  : null,
                              builder: (context, thumbSnapshot) {
                                if (thumbSnapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    !thumbSnapshot.hasData) {
                                  print(item.imageThumb);
                                  return Container(color: Colors.grey[300]);
                                }

                                final thumbData =
                                    thumbSnapshot.data!.data()
                                        as Map<String, dynamic>?;
                                final dynamic dataField = thumbData?['data'];

                                if (dataField is String &&
                                    dataField.isNotEmpty) {
                                  try {
                                    Uint8List bytes;
                                    // Heuristic: Check if the string consists only of 0s and 1s.
                                    if (RegExp(
                                      r'^[01]+$',
                                    ).hasMatch(dataField)) {
                                      // It's a binary string, parse it.
                                      bytes = _binaryStringToBytes(dataField);
                                    } else {
                                      // Assume it's Base64 and decode it.
                                      bytes = base64Decode(dataField);
                                    }
                                    return Image.memory(
                                      bytes,
                                      key: ValueKey(item.imageThumb),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.red,
                                                size: 40,
                                              ),
                                            );
                                          },
                                    );
                                  } catch (e) {
                                    // This will catch errors from both binary parsing and base64 decoding.
                                    // The widget will then fall through to the error icon below.
                                  }
                                }

                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(500),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.01),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: Row(
                                children: [
                                  const SizedBox(width: 10),
                                  Image.asset(
                                    "assets/icons/cristol.png",
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                    ),
                                    child: Text(
                                      item.rewardPrizeUSD,
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  ElevatedButton(
                                    onPressed: item.tournamentMode == "pending"
                                        ? () async {
                                            final prefs =
                                                await SharedPreferences.getInstance();
                                            final userId = prefs.getString(
                                              'userId',
                                            );
                                            if (userId != null) {
                                              isMobile(context)
                                                  ? commonNavigationbuild(
                                                      context,
                                                      SingalTournamentViewPage(
                                                        imagePath:
                                                            gameData?['image_path'] ??
                                                            '',
                                                        userId: userId,
                                                        tournament: item,
                                                      ),
                                                    )
                                                  : SingalTournamentPopUp.showSingalTournamentPopUp(
                                                      context,
                                                      title: item.title,

                                                      item: item,
                                                      imagePath:
                                                          gameData?['image_path'] ??
                                                          '',
                                                      selectedWeapons:
                                                          item.selectedWeapons,
                                                      selectedMap:
                                                          item.selectedMap,
                                                    );
                                            } else {
                                              // Optionally handle not logged in
                                            }
                                          }
                                        : () {},

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          item.tournamentMode == "pending"
                                          ? mainColor
                                          : mainRedColor2,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(
                                      item.tournamentMode == "pending"
                                          ? 'Apply'
                                          : 'End',
                                    ),
                                  ),
                                ],
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
                            backgroundColor: Colors.transparent,
                            radius: 20,
                            backgroundImage: _buildGameImageProvider(gameData),
                            child:
                                gameData?['image_base64'] == null &&
                                    gameData?['image_path'] == null
                                ? Text(
                                    // Show initial only if there is no image
                                    item.gameName.isNotEmpty
                                        ? item.gameName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title.isNotEmpty ? item.title : '-',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.gameName.isNotEmpty
                                      ? item.gameName
                                      : '-',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.more_vert_outlined),
                            padding: EdgeInsets.zero,
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
