import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WeaponsGrisView extends StatefulWidget {
  final List<String> weaponIds;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;
  final VoidCallback onPressed;
  final VoidCallback onTap;

  const WeaponsGrisView({
    Key? key,
    required this.weaponIds,
    this.crossAxisCount = 3,
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

  @override
  void initState() {
    super.initState();
    weaponsFuture = _fetchWeaponsFromFirebase();
  }

  Future<List<Map<String, dynamic>?>> _fetchWeaponsFromFirebase() async {
    List<Map<String, dynamic>?> weapons = [];
    final firestore = FirebaseFirestore.instance;

    for (String weaponId in widget.weaponIds) {
      try {
        String id = weaponId;
        // If the id is in ObjectId("...") format, extract the real id
        if (id.startsWith('ObjectId("') && id.endsWith('")')) {
          id = id.replaceAll('ObjectId("', '').replaceAll('")', '');
        }
        // Try to fetch the weapon document by id
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

  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    // For Firebase, imagePath should be a full URL or a storage path.
    // If you use Firebase Storage, you may need to generate a download URL.
    // For now, just return the path as is.
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: widget.onPressed,
                  icon: AnimatedRotation(
                    turns: 0.5,
                    duration: Duration(milliseconds: 300),
                    child: Icon(Icons.arrow_drop_up),
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
                  child: Text('Error loading weapons: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No weapons available'));
              }

              final weapons = snapshot.data!;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: weapons.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.crossAxisCount,
                  crossAxisSpacing: widget.spacing,
                  mainAxisSpacing: widget.spacing,
                  childAspectRatio: widget.childAspectRatio,
                ),
                itemBuilder: (context, int index) {
                  final weapon = weapons[index];

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    curve: Curves.easeInOut,
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (weapon?['imagePath'] != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  left: 5,
                                  right: 5,
                                ),
                                child: AnimatedContainer(
                                  duration: Duration(
                                    milliseconds: 500 + (index * 100),
                                  ),
                                  curve: Curves.elasticOut,
                                  child: Image.network(
                                    _getFullImageUrl(weapon?['imagePath']),
                                    height: 60,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: AnimatedDefaultTextStyle(
                                duration: Duration(
                                  milliseconds: 600 + (index * 100),
                                ),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                child: Text(
                                  weapon?['weaponName'] ?? 'Unknown Weapon',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: Duration(
                                milliseconds: 700 + (index * 100),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black54,
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
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
