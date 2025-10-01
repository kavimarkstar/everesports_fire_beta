import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Add for date formatting

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String? _userId; // current login userId (from SharedPreferences)

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId');
    if (mounted) {
      setState(() {
        _userId = savedUserId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(body: Center(child: Text("Please log in")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Activity")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("likes")
            .where("postOwnerId", isEqualTo: _userId) // ✅ use saved userId
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No activity yet"));
          }

          final likes = snapshot.data!.docs;

          // Batch fetch all users for likes to reduce network requests
          final userIds = likes.map((doc) => doc['userId']).toSet().toList();
          userIds
              .map(
                (id) => FirebaseFirestore.instance.collection('users').doc(id),
              )
              .toList();

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .where('id', whereIn: userIds)
                .get(),
            builder: (context, userSnapshots) {
              if (userSnapshots.hasError) {
                return const Center(child: Text("Failed to load users"));
              }

              if (!userSnapshots.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final userMap = Map<String, Map<String, dynamic>>();
              for (var snapshot in userSnapshots.data!.docs) {
                if (snapshot.exists) {
                  userMap[snapshot.id] =
                      snapshot.data() as Map<String, dynamic>;
                }
              }

              return ListView.builder(
                itemCount: likes.length,
                itemBuilder: (context, index) {
                  final likeData = likes[index].data() as Map<String, dynamic>;
                  final userId = likeData["userId"];
                  final createdAt = likeData["createdAt"]?.toDate();
                  final likeViewed = likeData["likeViewed"] ?? false;

                  final userData = userMap[userId];
                  final username = userData?["username"] ?? "Unknown";
                  final profileUrl =
                      userData?["profileImage"] ??
                      "https://via.placeholder.com/150";

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(profileUrl),
                    ),
                    title: Text("$username liked your post"),
                    subtitle: Text(
                      createdAt != null
                          ? DateFormat('MMM d, yyyy HH:mm').format(createdAt)
                          : "Unknown time",
                    ),
                    trailing: Icon(
                      likeViewed ? Icons.favorite : Icons.favorite_border,
                      color: likeViewed ? Colors.red : Colors.grey,
                    ),
                    onTap: () async {
                      if (!likeViewed) {
                        await likes[index].reference.update({
                          "likeViewed": true,
                        });
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
