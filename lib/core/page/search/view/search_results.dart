import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/esports/model/tournament.dart';
import 'package:everesports/core/page/search/widget/gridview.dart';
import 'package:everesports/widget/common_profile_listview.dart';
import 'package:flutter/material.dart';

class SearchResultsView extends StatefulWidget {
  final Map<String, dynamic>? searchResults;

  const SearchResultsView({super.key, this.searchResults});

  @override
  State<SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView>
    with TickerProviderStateMixin {
  final List<String> tabs = ['Tournaments', 'Users'];
  int selectedTab = 0;
  late AnimationController _tabController;
  late AnimationController _contentController;
  late Animation<double> _contentAnimation;
  Map<String, Map<String, dynamic>> _gameNameToData = {};

  @override
  void initState() {
    super.initState();
    _tabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _contentAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentController.forward();
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    // Fetch game_name collection from Firestore
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('game_name')
          .get();
      setState(() {
        _gameNameToData = {
          for (final doc in snapshot.docs)
            (doc.data()['name'] ?? '').toString().toUpperCase(): doc.data(),
        };
      });
    } catch (e) {
      setState(() {
        _gameNameToData = {};
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() => selectedTab = index);
    _contentController.reset();
    _contentController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Handle dynamic lists properly
    final tournamentsRaw =
        widget.searchResults?['tournaments'] as List<dynamic>? ?? [];
    final usersRaw = widget.searchResults?['users'] as List<dynamic>? ?? [];

    // Convert dynamic lists to proper types
    final tournaments = tournamentsRaw
        .map((item) {
          if (item is Tournament) return item;
          if (item is Map<String, dynamic>) return Tournament.fromMap(item);
          return null;
        })
        .whereType<Tournament>()
        .toList();

    final users = usersRaw.whereType<Map<String, dynamic>>().toList();

    // If no tournaments found, try to fetch all tournaments
    final tournamentsToDisplay = tournaments.isEmpty
        ? _fetchAllTournaments()
        : Future.value(tournaments);

    // If no users found, try to fetch all users
    final usersToDisplay = users.isEmpty
        ? _fetchAllUsers()
        : Future.value(users);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Animated Tab Bar
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final isSelected = selectedTab == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTabChanged(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? mainColor : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? mainColor
                            : (isDarkMode
                                  ? mainWhiteColor.withOpacity(0.6)
                                  : mainBlackColor.withOpacity(0.6)),
                        fontSize: 16,
                      ),
                      child: Text(tabs[index], textAlign: TextAlign.center),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Animated Results Content
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: selectedTab == 0
              ? _buildTournamentsTab(tournamentsToDisplay, isDarkMode)
              : _buildUsersTab(usersToDisplay, isDarkMode),
        ),
      ],
    );
  }

  Future<List<Tournament>> _fetchAllTournaments() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Tournament')
          .get();
      return snapshot.docs
          .map((doc) => Tournament.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching all tournaments: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAllUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }

  Widget _buildTournamentsTab(
    Future<List<Tournament>> tournamentsFuture,
    bool isDarkMode,
  ) {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: EsportsGridViewSearch(
              tournamentsFuture: tournamentsFuture,
              gameNameToData: _gameNameToData,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersTab(
    Future<List<Map<String, dynamic>>> usersFuture,
    bool isDarkMode,
  ) {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return _buildEmptyState(
                    'Error loading users',
                    Icons.error,
                    isDarkMode,
                  );
                } else if (snapshot.data?.isEmpty ?? true) {
                  return _buildEmptyState(
                    'No users found',
                    Icons.person,
                    isDarkMode,
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final user = snapshot.data![index];
                      final username =
                          user['username'] ?? user['name'] ?? 'Unknown User';
                      final userId = user['userId'] ?? 'N/A';
                      final profileImageUrl = user['profileImageUrl'];

                      return AnimatedBuilder(
                        animation: _contentAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              30 *
                                  (1 - _contentAnimation.value) *
                                  (index + 1) *
                                  0.1,
                            ),
                            child: Opacity(
                              opacity: _contentAnimation.value,
                              child: CommonProfileListview(
                                userId: userId,
                                username: username,
                                profileImageUrl: profileImageUrl,
                                isFollowing: false,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon, bool isDarkMode) {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _contentAnimation.value),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 48, color: mainColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? mainWhiteColor.withOpacity(0.7)
                          : mainBlackColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different search term',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? mainWhiteColor.withOpacity(0.5)
                          : mainBlackColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
