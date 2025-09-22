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
import 'package:flutter/material.dart';
import 'package:everesports/core/page/esports/service/mongo_service.dart';

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
  bool isExpanded = false;
  bool isWeaponExpanded = false;
  late Future<List<Map<String, dynamic>>> _mapsFuture;

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

  @override
  void initState() {
    super.initState();
    _mapsFuture = MongoEsportsService.getMaps();
  }

  // Helper to extract ObjectId from string
  String extractObjectId(String objectIdString) {
    final regex = RegExp(r'ObjectId\("([a-fA-F0-9]+)"\)');
    final match = regex.firstMatch(objectIdString);
    return match != null ? match.group(1)! : objectIdString;
  }

  Map<String, dynamic>? findWeaponById(
    String objectIdString,
    List<Map<String, dynamic>> weapons,
  ) {
    final objectId = extractObjectId(objectIdString);
    try {
      return weapons.firstWhere((weapon) {
        final weaponId = weapon['_id'] is Map
            ? weapon['_id']['\$oid']
            : weapon['_id'].toString();
        return weaponId == objectId;
      }, orElse: () => <String, dynamic>{});
    } catch (e) {
      return null;
    }
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
    final description = widget.tournament.description;
    return Scaffold(
      appBar: AppBar(title: Text(widget.tournament.title)),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingalTournamentImage(item: widget.tournament),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                child: Text(
                  "Esports World Cup: Free Fire unveiled with 1 million prize pool",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Text(
                      (description.split(' ').isNotEmpty
                          ? description.split(' ').first
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
                                      description,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundImage: widget.imagePath != null
                          ? NetworkImage(widget.imagePath)
                          : null,
                      child: widget.imagePath == null
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
                    commonElevatedButtonbuild(
                      context,
                      widget.tournament.tournamentMode == "pending"
                          ? "Apply"
                          : "End",
                      () {
                        widget.tournament.tournamentMode == "pending"
                            ? commonNavigationbuild(
                                context,
                                ApplyPage(tournament: widget.tournament),
                              )
                            : null;
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
                  final imagePath = mapObj['imagePath'] != null
                      ? mapObj['imagePath'] as String
                      : '';
                  return buildSingleMapView(
                    context,
                    selectedMapName,
                    imagePath,
                  );
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
      ),
    );
  }
}

class SingalTournamentPopUp {
  static Future<void> showSingalTournamentPopUp(
    BuildContext context, {
    required String title,
    required String content,
    required Tournament item,
    required String imagePath,
    required List selectedWeapons,
    required String selectedMap,
  }) async {
    List<String> extractWeaponIds(List weapons) {
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

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        bool isExpanded = false;
        bool isWeaponExpanded = false;
        return Dialog(
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
            child: StatefulBuilder(
              builder: (context, setState) {
                final Future<List<Map<String, dynamic>>> mapsFuture =
                    MongoEsportsService.getMaps();
                final description = item.description;
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SingalTournamentImage(item: item),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        child: Text(
                          "Esports World Cup: Free Fire unveiled with 1 million prize pool",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            Text(
                              (description.split(' ').isNotEmpty
                                  ? description.split(' ').first
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
                                      Theme.of(context).brightness ==
                                          Brightness.dark
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.7,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AppBar(
                                            automaticallyImplyLeading: false,
                                            title: Text('Description'),
                                            backgroundColor:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? mainBlackColor
                                                : mainWhiteColor,
                                            actions: [
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: IconButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(),
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
                                              description,
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
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? mainWhiteColor
                                      : mainBlackColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 17,
                              backgroundImage: imagePath.isNotEmpty
                                  ? NetworkImage(imagePath)
                                  : null,
                              child: imagePath.isEmpty
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
                            const SizedBox(width: 10),
                            Text(
                              item.gameName.isNotEmpty ? item.gameName : '-',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? mainWhiteColor
                                    : mainBlackColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Spacer(),
                            commonElevatedButtonbuild(
                              context,
                              item.tournamentMode == "pending"
                                  ? "Apply"
                                  : "End",
                              () {
                                item.tournamentMode == "pending"
                                    ? commonNavigationbuild(
                                        context,
                                        ApplyPage(tournament: item),
                                      )
                                    : null;
                              },
                            ),
                          ],
                        ),
                      ),
                      buildPriceView(context, item),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: mapsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Text('Error loading map image');
                          }
                          final maps = snapshot.data ?? [];
                          final selectedMapName = selectedMap;
                          final mapObj = maps.firstWhere(
                            (m) => m['mapName'] == selectedMapName,
                            orElse: () => <String, dynamic>{},
                          );
                          final mapImagePath = mapObj['imagePath'] != null
                              ? mapObj['imagePath'] as String
                              : '';
                          return buildSingleMapView(
                            context,
                            selectedMapName,
                            mapImagePath,
                          );
                        },
                      ),
                      AnimatedCrossFade(
                        firstChild: buildSingleCard(
                          context,
                          "Details",
                          Icons.article,
                          () => setState(() => isExpanded = !isExpanded),
                          () => setState(() => isExpanded = !isExpanded),
                        ),
                        secondChild: buildListViewSingleDetail(
                          context,
                          item,
                          () => setState(() => isExpanded = !isExpanded),
                          () => setState(() => isExpanded = !isExpanded),
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
                          () => setState(
                            () => isWeaponExpanded = !isWeaponExpanded,
                          ),
                          () => setState(
                            () => isWeaponExpanded = !isWeaponExpanded,
                          ),
                        ),
                        secondChild: WeaponsGrisView(
                          weaponIds: <String>[
                            ...extractWeaponIds(selectedWeapons),
                          ],
                          onPressed: () => setState(
                            () => isWeaponExpanded = !isWeaponExpanded,
                          ),
                          onTap: () => setState(
                            () => isWeaponExpanded = !isWeaponExpanded,
                          ),
                        ),
                        crossFadeState: isWeaponExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                        firstCurve: Curves.easeInOut,
                        secondCurve: Curves.easeInOut,
                      ),
                      buildPrivacyPolicyView(
                        context,
                        "Privacy Policy",
                        Icons.privacy_tip,
                        () {},
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
