import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/esports/model/tournament.dart';
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
              final imagePath =
                  gameData != null &&
                      gameData['image_path'] != null &&
                      gameData['image_path'].toString().isNotEmpty
                  ? (gameData['image_path'].toString().startsWith('/')
                        ? '$fileServerBaseUrl${gameData['image_path']}'
                        : '$fileServerBaseUrl/${gameData['image_path']}')
                  : null;
              return GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString('userId');
                  if (userId != null) {
                    isMobile(context)
                        ? commonNavigationbuild(
                            context,
                            SingalTournamentViewPage(
                              imagePath: imagePath ?? '',
                              userId: userId,
                              tournament: item,
                            ),
                          )
                        : SingalTournamentPopUp.showSingalTournamentPopUp(
                            context,
                            title: item.title,
                            content: item.description,
                            item: item,
                            imagePath: imagePath ?? '',
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
                            child: item.imageThumb.isNotEmpty
                                ? Image.network(
                                    _buildImageUrl(item.imageThumb),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) => Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.red,
                                            size: 40,
                                          ),
                                        ),
                                  )
                                : Container(color: Colors.grey[300]),
                          ),
                        ),

                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(150),
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withOpacity(0.13)
                                    : Colors.black.withOpacity(0.08),
                                width: 1.3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black.withOpacity(0.18)
                                      : Colors.grey.withOpacity(0.10),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const SizedBox(width: 10),
                                  Image.asset(
                                    "assets/icons/cristol.png",
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
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
                                                            imagePath ?? '',
                                                        userId: userId,
                                                        tournament: item,
                                                      ),
                                                    )
                                                  : SingalTournamentPopUp.showSingalTournamentPopUp(
                                                      context,
                                                      title: item.title,
                                                      content: item.description,
                                                      item: item,
                                                      imagePath:
                                                          imagePath ?? '',
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
                            radius: 25,
                            backgroundImage: imagePath != null
                                ? NetworkImage(imagePath)
                                : null,
                            child: imagePath == null
                                ? Text(
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
                                if (item.createdAt != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Created: ${item.createdAt!.toLocal().toString().split(".")[0]}',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
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

  String _buildImageUrl(String imageThumb) {
    final thumb = imageThumb;
    if (fileServerBaseUrl.endsWith('/') && thumb.startsWith('/')) {
      return fileServerBaseUrl + thumb.substring(1);
    } else if (!fileServerBaseUrl.endsWith('/') && !thumb.startsWith('/')) {
      return '$fileServerBaseUrl/$thumb';
    } else {
      return '$fileServerBaseUrl$thumb';
    }
  }
}
