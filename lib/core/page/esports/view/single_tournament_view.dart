import 'dart:convert';

import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/esports/model/tournament.dart';
import 'package:everesports/core/page/esports/view/apply.dart';
import 'package:everesports/core/page/esports/view/util/list_view_single_detail.dart';
import 'package:everesports/core/page/esports/view/util/price_view.dart';
import 'package:everesports/core/page/esports/view/util/privacy_policy_view.dart';
import 'package:everesports/core/page/esports/view/util/single_tournament_image.dart';
import 'package:everesports/core/page/esports/view/util/single_card.dart';
import 'package:everesports/core/page/esports/view/util/single_map_view.dart';
import 'package:everesports/core/page/esports/view/util/weapons_gris_view.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:everesports/widget/common_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:everesports/core/page/esports/service/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingalTournamentViewPage extends StatefulWidget {
  final String userId;
  final Tournament tournament;
  final String imagePath;
  const SingalTournamentViewPage({
    super.key,
    required this.userId,
    required this.tournament,
    required this.imagePath,
  });

  @override
  State<SingalTournamentViewPage> createState() =>
      _SingalTournamentViewPageState();
}

class _SingalTournamentViewPageState extends State<SingalTournamentViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.tournament.title)),
      body: _TournamentDetailsContent(
        tournament: widget.tournament,
        imagePath: widget.imagePath,
      ),
    );
  }
}

class SingalTournamentPopUp {
  static Future<void> showSingalTournamentPopUp(
    BuildContext context, {
    required String title,
    required Tournament item,
    required String imagePath,
    required List selectedWeapons,
    required String selectedMap,
  }) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: isDarkMode ? secondBlackColor : secondWhiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop(context)
                  ? MediaQuery.of(context).size.width * 0.5
                  : isTablet(context)
                  ? MediaQuery.of(context).size.width * 0.8
                  : MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: _TournamentDetailsContent(
              tournament: item,
              imagePath: imagePath,
            ),
          ),
        );
      },
    );
  }
}

class _TournamentDetailsContent extends StatefulWidget {
  final Tournament tournament;
  final String imagePath;

  const _TournamentDetailsContent({
    required this.tournament,
    required this.imagePath,
  });

  @override
  State<_TournamentDetailsContent> createState() =>
      _TournamentDetailsContentState();
}

class _TournamentDetailsContentState extends State<_TournamentDetailsContent> {
  bool isExpanded = false;
  bool isWeaponExpanded = false;
  bool isUserApplied = false;
  bool isCheckingApplication = true;
  late Future<List<Map<String, dynamic>>> _mapsFuture;

  @override
  void initState() {
    super.initState();
    _mapsFuture = FirebaseEsportsService.getMaps();
    _checkUserApplication();
  }

  Future<void> _checkUserApplication() async {
    try {
      // Get current user ID - you may need to adjust this based on your user management
      // For now, I'm assuming you have access to current user ID
      // You might need to get this from a user service or shared preferences
      final currentUserId = await _getCurrentUserId();

      if (currentUserId != null) {
        final isApplied =
            await FirebaseEsportsService.checkUserTournamentApplication(
              widget.tournament.tournamentId,
              currentUserId,
            );

        setState(() {
          isUserApplied = isApplied;
          isCheckingApplication = false;
        });
      } else {
        setState(() {
          isCheckingApplication = false;
        });
      }
    } catch (e) {
      print('Error checking user application: $e');
      setState(() {
        isCheckingApplication = false;
      });
    }
  }

  Future<String?> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('userId');
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  void toggleDetail() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void toggleweapon() {
    setState(() {
      isWeaponExpanded = !isWeaponExpanded;
    });
  }

  List<String> _extractWeaponIds(List weapons) {
    return weapons.map((e) {
      if (e is Map && e.containsKey('_id')) {
        final id = e['_id'].toString();
        return id.startsWith('ObjectId("')
            ? id.replaceAll('ObjectId("', '').replaceAll('")', '')
            : id;
      } else if (e is String) {
        return e;
      } else {
        return '';
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingalTournamentImage(item: widget.tournament),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text(
                widget.tournament.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Text(
                    (widget.tournament.description.split(' ').isNotEmpty
                        ? widget.tournament.description.split(' ').first
                        : ''),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? secondBlackColor
                            : secondWhiteColor,
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(0),
                          ),
                        ),
                        builder: (context) => SingleChildScrollView(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppBar(
                                  automaticallyImplyLeading:
                                      false, // Ensures no back arrow is displayed
                                  title: Text('Description'),
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? mainBlackColor
                                      : mainWhiteColor,
                                  // No leading widget, so no back arrow
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: IconButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        icon: Icon(Icons.close),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    widget.tournament.description,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      '...more',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? mainWhiteColor
                            : mainBlackColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 17,
                    backgroundImage: widget.imagePath.isNotEmpty
                        ? MemoryImage(
                            // decode base64 string to bytes
                            base64Decode(widget.imagePath),
                          )
                        : null,
                    child: widget.imagePath.isEmpty
                        ? Text(
                            widget.tournament.gameName.isNotEmpty
                                ? widget.tournament.gameName[0].toUpperCase()
                                : '?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.tournament.gameName.isNotEmpty
                        ? widget.tournament.gameName
                        : '-',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? mainWhiteColor
                          : mainBlackColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  isCheckingApplication
                      ? SizedBox(
                          width: 80,
                          height: 36,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : commonElevatedButtonbuild(
                          context,
                          widget.tournament.tournamentMode == "pending"
                              ? (isUserApplied ? "Applied" : "Apply")
                              : "End",
                          () async {
                            if (widget.tournament.tournamentMode == "pending") {
                              if (isUserApplied) {
                                // Show message that user has already applied

                                commonSnackBarbuildSuccess(
                                  context,
                                  "You have already applied to this tournament",
                                );
                                return;
                              }

                              if (isMobile(context)) {
                                final result = await commonNavigationbuild(
                                  context,
                                  ApplyPage(tournament: widget.tournament),
                                );
                                // Refresh application status after returning from apply page
                                if (result == true) {
                                  _checkUserApplication();
                                }
                              } else {
                                final result = await showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    backgroundColor: isDarkMode
                                        ? secondBlackColor
                                        : secondWhiteColor,
                                    child: SizedBox(
                                      width: 400,
                                      child: ApplyPage(
                                        tournament: widget.tournament,
                                      ),
                                    ),
                                  ),
                                );
                                // Refresh application status after dialog closes
                                if (result == true) {
                                  _checkUserApplication();
                                }
                              }
                            }
                          },
                        ),
                ],
              ),
            ),
            buildPriceView(context, widget.tournament),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _mapsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error loading map image');
                }
                final maps = snapshot.data ?? [];
                final selectedMapName = widget.tournament.selectedMap;
                final mapObj = maps.firstWhere(
                  (m) => m['mapName'] == selectedMapName,
                  orElse: () => <String, dynamic>{},
                );
                final imagePath = mapObj['image_base64'] != null
                    ? mapObj['image_base64'] as String
                    : '';
                return buildSingleMapView(context, selectedMapName, imagePath);
              },
            ),
            AnimatedCrossFade(
              firstChild: buildSingleCard(
                context,
                "Details",
                Icons.article,
                toggleDetail,
                toggleDetail,
              ),
              secondChild: buildListViewSingleDetail(
                context,
                widget.tournament,
                toggleDetail,
                toggleDetail,
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
            ),
            AnimatedCrossFade(
              firstChild: buildSingleCard(
                context,
                "Weapons",
                Icons.sports_esports,
                toggleweapon,
                toggleweapon,
              ),
              secondChild: WeaponsGrisView(
                weaponIds: <String>[
                  ..._extractWeaponIds(widget.tournament.selectedWeapons),
                ],
                onPressed: toggleweapon,
                onTap: toggleweapon,
              ),
              crossFadeState: isWeaponExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
            ),
            //TODO fill this
            buildPrivacyPolicyView(
              context,
              "Privacy Policy",
              Icons.privacy_tip,
              () {},
            ),
          ],
        ),
      ),
    );
  }
}
