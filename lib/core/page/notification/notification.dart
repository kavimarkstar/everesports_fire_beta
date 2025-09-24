import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/notification/page/announcement.dart';
import 'package:everesports/core/page/notification/page/activity.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int selectedIndex = -1;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (!mounted) return;
      setState(() {
        _currentUserId = userId;
      });
    } catch (_) {}
  }

  void selectIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget _buildContent() {
    if (selectedIndex == 0) {
      // Announcement
      return AnnouncementPage();
    } else if (selectedIndex == 1) {
      // Activity (New followers)
      return ActivityPage();
    } else if (selectedIndex == 2) {
      // Activity (Favorite)
      return Center(
        child: Text("Activity Content", style: TextStyle(fontSize: 24)),
      );
    } else {
      // Default notification list
      return ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notification #$index"),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !isTablet(context) && !isMobile(context)
          ? Row(
              children: [
                SizedBox(width: 400, child: contentbuild(context)),
                if (!isTablet(context)) Expanded(child: _buildContent()),
              ],
            )
          : contentbuild(context),
    );
  }

  Widget contentbuild(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        actions: [
          SizedBox(
            width: 400,
            height: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? Color(0xFF272727) : Color(0xFFf1f1f1),

                    hintText: 'Search notifications',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(200),
                      borderSide: BorderSide.none,
                    ),

                    isDense: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) {
            if (index == 0) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isDark ? mainWhiteColor : mainBlackColor,
                  child: Icon(Icons.campaign),
                  radius: 25,
                ),
                title: Text("Announcement"),
                subtitle: _LatestAnnouncementSubtitle(
                  currentUserId: _currentUserId,
                ),
                selected: selectedIndex == 0,
                onTap: !isDesktop(context)
                    ? () => commonNavigationbuild(context, AnnouncementPage())
                    : () => selectIndex(0),

                trailing: _AnnouncementUnreadBadge(
                  currentUserId: _currentUserId,
                ),
              );
            } else if (index == 1) {
              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.group), radius: 25),
                title: Text("New followers"),
                subtitle: Text("People who followed you"),
                selected: selectedIndex == 1,
                onTap: !isDesktop(context)
                    ? () => commonNavigationbuild(context, ActivityPage())
                    : () => selectIndex(1),
              );
            } else if (index == 2) {
              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.favorite), radius: 25),
                title: Text("Activity"),
                subtitle: Text("Your recent activity"),
                selected: selectedIndex == 2,
                onTap: !isDesktop(context)
                    ? () => commonNavigationbuild(context, ActivityPage())
                    : () => selectIndex(2),
              );
            } else {
              return ListTile(
                leading: CircleAvatar(radius: 25),
                title: Text("Kavimark"),
                subtitle: Text("trtrdt"),
                selected: selectedIndex == index,
                onTap: () => selectIndex(index),
              );
            }
          },
        ),
      ),
    );
  }
}

class _AnnouncementUnreadBadge extends StatelessWidget {
  final String? currentUserId;
  const _AnnouncementUnreadBadge({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return SizedBox.shrink();
    }

    final announcementsStream = FirebaseFirestore.instance
        .collection('announcements')
        .snapshots();

    final viewsStream = FirebaseFirestore.instance
        .collection('announcementView')
        .where('userId', isEqualTo: currentUserId)
        .where('viewed', isEqualTo: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: announcementsStream,
      builder: (context, annSnapshot) {
        if (!annSnapshot.hasData) return SizedBox.shrink();
        final annDocs = annSnapshot.data!.docs;
        if (annDocs.isEmpty) return SizedBox.shrink();

        return StreamBuilder<QuerySnapshot>(
          stream: viewsStream,
          builder: (context, viewSnapshot) {
            if (!viewSnapshot.hasData) return SizedBox.shrink();
            final viewedIds = viewSnapshot.data!.docs
                .map((d) => d['announcementId'] as String?)
                .whereType<String>()
                .toSet();

            final unreadCount = annDocs
                .where((a) => !viewedIds.contains(a.id))
                .length;

            if (unreadCount <= 0) return SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LatestAnnouncementSubtitle extends StatelessWidget {
  final String? currentUserId;
  const _LatestAnnouncementSubtitle({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Text(
        'Latest announcements',
        style: TextStyle(color: Colors.grey[600]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final announcementsStream = FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();

    final viewsStream = FirebaseFirestore.instance
        .collection('announcementView')
        .where('userId', isEqualTo: currentUserId)
        .where('viewed', isEqualTo: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: announcementsStream,
      builder: (context, annSnapshot) {
        if (!annSnapshot.hasData) {
          return Text(
            'Latest announcements',
            style: TextStyle(color: Colors.grey[600]),
          );
        }
        final annDocs = annSnapshot.data!.docs;
        if (annDocs.isEmpty) {
          return Text(
            'No announcements',
            style: TextStyle(color: Colors.grey[600]),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: viewsStream,
          builder: (context, viewSnapshot) {
            Set<String> viewedIds = {};
            if (viewSnapshot.hasData) {
              viewedIds = viewSnapshot.data!.docs
                  .map((d) => d['announcementId'] as String?)
                  .whereType<String>()
                  .toSet();
            }

            // Pick the first unviewed title if any, else the most recent title
            String latestTitle = '';
            for (final a in annDocs) {
              if (!viewedIds.contains(a.id)) {
                latestTitle = (a['title'] ?? '').toString();
                break;
              }
            }
            if (latestTitle.isEmpty) {
              latestTitle = (annDocs.first['title'] ?? '').toString();
            }

            if (latestTitle.isEmpty) {
              latestTitle = 'Latest announcements';
            }

            return Text(
              latestTitle,
              style: TextStyle(color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        );
      },
    );
  }
}
