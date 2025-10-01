import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class WeaponsGrisView extends StatefulWidget {
  final List<String> weaponIds;

  final double childAspectRatio;
  final double spacing;
  final VoidCallback onPressed;
  final VoidCallback onTap;

  const WeaponsGrisView({
    Key? key,
    required this.weaponIds,
    this.childAspectRatio = 0.65,
    this.spacing = 12,
    required this.onPressed,
    required this.onTap,
  }) : super(key: key);

  @override
  State<WeaponsGrisView> createState() => _WeaponsGrisViewState();
}

class _WeaponsGrisViewState extends State<WeaponsGrisView> {
  late Future<List<Map<String, dynamic>?>> weaponsFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    weaponsFuture = _fetchWeaponsFromFirebase();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>?>> _fetchWeaponsFromFirebase() async {
    List<Map<String, dynamic>?> weapons = [];
    final firestore = FirebaseFirestore.instance;

    for (String weaponId in widget.weaponIds) {
      try {
        String id = weaponId;
        if (id.startsWith('ObjectId("') && id.endsWith('")')) {
          id = id.replaceAll('ObjectId("', '').replaceAll('")', '');
        }
        final doc = await firestore.collection('weapon').doc(id).get();
        if (doc.exists) {
          weapons.add(doc.data());
        } else {
          weapons.add(null);
        }
      } catch (e) {
        print('Error fetching weapon $weaponId: $e');
        weapons.add(null);
      }
    }
    return weapons;
  }

  ImageProvider? _getImageProvider(String? base64) {
    if (base64 == null || base64.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(base64));
    } catch (e) {
      return null;
    }
  }

  void _scrollGrid(double offset) {
    final double newOffset = _scrollController.offset + offset;
    _scrollController.animateTo(
      newOffset.clamp(
        0.0,
        _scrollController.position.hasContentDimensions
            ? _scrollController.position.maxScrollExtent
            : double.infinity,
      ),
      duration: const Duration(milliseconds: 350),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    [
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.macOS,
    ].contains(Theme.of(context).platform);

    return Column(
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Weapons",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: widget.onPressed,
                  icon: AnimatedRotation(
                    turns: 0.5,
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      Icons.arrow_drop_up,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: FutureBuilder<List<Map<String, dynamic>?>>(
            future: weaponsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading weapons: ${snapshot.error}',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No weapons available',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              final weapons = snapshot.data!;

              // Use a horizontal scrollable grid
              Widget grid = SizedBox(
                height: 160 * 4, // enough for 1 row of cards

                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: GridView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: weapons.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: widget.spacing,
                      mainAxisSpacing: widget.spacing,
                      childAspectRatio: widget.childAspectRatio,
                    ),
                    itemBuilder: (context, int index) {
                      final weapon = weapons[index];

                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 400 + (index * 50)),
                          opacity: 1.0,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: isDark
                                ? Colors.white.withOpacity(0.10)
                                : Colors.black.withOpacity(0.07),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 8,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (weapon?['imageBase64'] != null &&
                                      (weapon?['imageBase64'] as String)
                                          .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 0,
                                        left: 5,
                                        right: 5,
                                      ),
                                      child: AnimatedContainer(
                                        duration: Duration(
                                          milliseconds: 500 + (index * 100),
                                        ),
                                        curve: Curves.elasticOut,
                                        child: Image(
                                          image:
                                              _getImageProvider(
                                                weapon?['imageBase64'],
                                              ) ??
                                              const AssetImage(
                                                'assets/images/placeholder.png',
                                              ),
                                          height: 60,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 0,
                                        left: 5,
                                        right: 5,
                                      ),
                                      child: Image.asset(
                                        'assets/images/placeholder.png',
                                        height: 60,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: AnimatedDefaultTextStyle(
                                      duration: Duration(
                                        milliseconds: 600 + (index * 100),
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        letterSpacing: 0.1,
                                      ),
                                      child: Text(
                                        weapon?['weaponName'] ??
                                            'Unknown Weapon',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  AnimatedDefaultTextStyle(
                                    duration: Duration(
                                      milliseconds: 700 + (index * 100),
                                    ),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    child: Text(
                                      weapon?['category'] ?? 'Unknown Category',
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );

              // Add scroll buttons for all platforms
              return Stack(
                alignment: Alignment.center,
                children: [
                  grid,
                  Positioned(
                    left: 0,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        height: 160 * 4,
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: isDark ? Colors.white : Colors.black54,
                          ),
                          onPressed: () {
                            _scrollGrid(-320); // scroll left
                          },
                          tooltip: "Scroll left",
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        height: 160 * 4,
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: isDark ? Colors.white : Colors.black54,
                          ),
                          onPressed: () {
                            _scrollGrid(320); // scroll right
                          },
                          tooltip: "Scroll right",
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
