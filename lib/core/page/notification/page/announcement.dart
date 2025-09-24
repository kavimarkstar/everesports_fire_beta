import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({Key? key}) : super(key: key);

  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;
  bool _markedAllOnOpen = false;

  Future<void> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (!mounted) return;
      setState(() {
        _currentUserId = userId;
      });
    } catch (e) {
      // ignore errors
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    // Scroll to the bottom (latest message) when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Announcements")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('announcements')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading announcements'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No announcements found.'));
          }

          final announcements = snapshot.data!.docs;

          // On first page load with data and a known user, mark all as viewed once
          if (!_markedAllOnOpen &&
              _currentUserId != null &&
              announcements.isNotEmpty) {
            _markAllCurrentAsViewedOnce(announcements, _currentUserId!);
            _markedAllOnOpen = true;
          }

          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              reverse: true, // Chat style: newest at the bottom
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final doc = announcements[index];
                final title = doc['title'] ?? '';
                final description = doc['description'] ?? '';
                final createdAt = doc['createdAt'];
                final imageBase64 = doc['image'] ?? '';

                DateTime? createdDate;
                String formattedDate = '';
                if (createdAt != null && createdAt is Timestamp) {
                  createdDate = createdAt.toDate();
                  formattedDate = DateFormat(
                    'dd MMM yyyy, hh:mm a',
                  ).format(createdDate);
                }

                Widget? imageWidget;
                if (imageBase64.isNotEmpty) {
                  try {
                    final bytes = base64Decode(imageBase64);
                    imageWidget = Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          bytes,
                          width: double.infinity,
                          height: !isDesktop(context)
                              ? MediaQuery.of(context).size.width * 0.5
                              : MediaQuery.of(context).size.width * 0.2,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } catch (e) {
                    imageWidget = null;
                  }
                }

                final announcementId = doc.id;
                return StreamBuilder<QuerySnapshot>(
                  stream: (_currentUserId == null)
                      ? const Stream.empty()
                      : FirebaseFirestore.instance
                            .collection('announcementView')
                            .where('announcementId', isEqualTo: announcementId)
                            .where('userId', isEqualTo: _currentUserId)
                            .limit(1)
                            .snapshots(),
                  builder: (context, viewSnapshot) {
                    final hasViewDoc =
                        viewSnapshot.hasData &&
                        viewSnapshot.data!.docs.isNotEmpty;
                    final isViewed = hasViewDoc
                        ? (viewSnapshot.data!.docs.first['viewed'] == true)
                        : false;

                    return Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () async {
                          if (_currentUserId == null) return;
                          final viewDocId =
                              '${announcementId}_${_currentUserId}';
                          await FirebaseFirestore.instance
                              .collection('announcementView')
                              .doc(viewDocId)
                              .set({
                                'announcementId': announcementId,
                                'userId': _currentUserId,
                                'viewed': true,
                                'viewedAt': FieldValue.serverTimestamp(),
                              }, SetOptions(merge: true));
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          child: SizedBox(
                            width: !isDesktop(context)
                                ? double.infinity
                                : MediaQuery.of(context).size.width * 0.4,
                            child: Column(
                              children: [
                                imageWidget ??
                                    Icon(
                                      Icons.campaign,
                                      color: Colors.blue,
                                      size: 40,
                                    ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    title,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                if (!isViewed)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 8.0,
                                                        ),
                                                    child: Chip(
                                                      label: Text('New'),
                                                      backgroundColor:
                                                          Colors.red[100],
                                                      labelStyle: TextStyle(
                                                        color: Colors.red[800],
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      visualDensity:
                                                          VisualDensity(
                                                            horizontal: -4,
                                                            vertical: -4,
                                                          ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              description,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 13,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  SizedBox(width: 12),
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    formattedDate,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _markAllCurrentAsViewedOnce(
    List<QueryDocumentSnapshot> annDocs,
    String userId,
  ) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final a in annDocs) {
        final annId = a.id;
        final docRef = FirebaseFirestore.instance
            .collection('announcementView')
            .doc('${annId}_${userId}');
        batch.set(docRef, {
          'announcementId': annId,
          'userId': userId,
          'viewed': true,
          'viewedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await batch.commit();
    } catch (_) {}
  }
}
