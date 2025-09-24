import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/home/view/post_view.dart';
import 'package:everesports/core/page/search/widget/search_textfield.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:everesports/widget/common_profile_listview.dart';
import 'package:everesports/core/page/home/service/users_service.dart';
import 'package:everesports/core/page/auth/model/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:everesports/language/controller/all_language.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _usersWithStatus = [];
  List<Map<String, dynamic>> _filteredUsersWithStatus = [];
  bool _isLoadingUsers = true;
  bool _hasError = false;
  String _errorMessage = '';
  String? _currentUserId;

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      setState(() {
        _currentUserId = userId;
      });
      if (userId != null) {
        _loadUsers();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user ID: $e');
      }
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _filterUsers();
    });
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredUsersWithStatus = _usersWithStatus;
      });
    } else {
      setState(() {
        _filteredUsersWithStatus = _usersWithStatus.where((userData) {
          final user = userData['user'] as UserProfile;
          final username = user.username?.toLowerCase() ?? '';
          final name = user.name?.toLowerCase() ?? '';
          return username.contains(query) || name.contains(query);
        }).toList();
      });
    }
  }

  Future<void> _loadUsers() async {
    if (_currentUserId == null) return;

    try {
      setState(() {
        _isLoadingUsers = true;
        _hasError = false;
        _errorMessage = '';
      });

      final usersWithStatus = await UsersService.getUsersWithFollowingStatus(
        currentUserId: _currentUserId!,
        limit: 50,
      );

      // Load current user's following statistics
      await UsersService.getFollowingCount(_currentUserId!);
      await UsersService.getFollowersCount(_currentUserId!);

      setState(() {
        _usersWithStatus = usersWithStatus;
        _filteredUsersWithStatus = usersWithStatus;

        _isLoadingUsers = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users: $e');
      }
      setState(() {
        _isLoadingUsers = false;
        _hasError = true;
        _errorMessage = 'Failed to load users. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool smallScreen = isMobile(context);
    final double _ = isDesktop(context)
        ? MediaQuery.of(context).size.width * 0.5
        : MediaQuery.of(context).size.width * 0.95;

    // Debug information
    if (kDebugMode) {
      print(
        'HomePage build - Mobile: ${isMobile(context)}, Tablet: ${isTablet(context)}, Desktop: ${isDesktop(context)}',
      );
      print(
        'Screen size: ${MediaQuery.of(context).size.width} x ${MediaQuery.of(context).size.height}',
      );
    }

    return Scaffold(
      appBar: smallScreen
          ? AppBar(
              title: Text(
                getEveresports(context),
                style: TextStyle(
                  color: isDarkMode ? mainWhiteColor : mainBlackColor,
                  fontFamily: 'LemonJelly',
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Left content area (Post list)
                  Expanded(
                    flex: 2,
                    child: isMobile(context)
                        ? ScrollConfiguration(
                            behavior: ScrollConfiguration.of(
                              context,
                            ).copyWith(scrollbars: false),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  PostDisplayPage(), // This should return a Column of cards for mobile
                                ],
                              ),
                            ),
                          )
                        : ScrollConfiguration(
                            behavior: ScrollConfiguration.of(
                              context,
                            ).copyWith(scrollbars: false),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    // Posts view with proper scrolling
                                    PostDisplayPage(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),

                  /// Right sidebar (desktop only)
                  if (isDesktop(context))
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          // Search bar for users
                          CommonSearchTextfield(
                            controller: _searchController,
                            showSuggestions: false,
                            suggestions: [],
                            showClear: false,
                            isSearching: false,
                            onSearchResults: (results) {},
                            onSearch: () {},
                          ),
                          Expanded(
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(
                                context,
                              ).copyWith(scrollbars: false),
                              child: _buildUsersSidebar(),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersSidebar() {
    if (_isLoadingUsers) {
      return _buildLoadingSkeleton();
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadUsers, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_usersWithStatus.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No users found', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadUsers, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_filteredUsersWithStatus.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No users found for "${_searchController.text}"',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: _filteredUsersWithStatus.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final userData = _filteredUsersWithStatus[index];
          final user = userData['user'] as UserProfile;
          final isFollowing = userData['isFollowing'] as bool;
          final followedAt = userData['followedAt'] as String?;
          final isCurrentUser = userData['isCurrentUser'] as bool;

          return CommonProfileListview(
            userId:
                user.userId ??
                '', // Use userId field (like "00000000"), not ObjectId
            username: isCurrentUser
                ? '${user.username ?? user.name ?? 'Unknown User'} (You)'
                : user.username ?? user.name ?? 'Unknown User',
            handle: user.name != null && user.name != user.username
                ? user.name
                : null,
            profileImageUrl: user.profileImageUrl,
            followDate: isFollowing && followedAt != null
                ? _formatFollowDate(followedAt)
                : _formatUserJoinDate(user.createdAt),
            isFollowing: isFollowing,
            currentUserId: _currentUserId,
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      itemCount: 10,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              // Profile avatar skeleton
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              const SizedBox(width: 16),
              // User info skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              // Follow button skeleton
              Container(
                width: 80,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatUserJoinDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'Joined $years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Joined $months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return 'Joined ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return 'Joined today';
    }
  }

  String _formatFollowDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'Followed $years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Followed $months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return 'Followed ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return 'Followed today';
    }
  }

  Size getDisplaySizeForFiles(List<String> files, BuildContext context) {
    double maxWidth =
        MediaQuery.of(context).size.width * 0.95; // 95% of screen width
    double aspect;

    // Detect aspect ratio by file name or metadata if you have it
    if (files.isNotEmpty && files[0].contains('portrait')) {
      aspect = 9 / 16;
    } else if (files.isNotEmpty && files[0].contains('square')) {
      aspect = 1;
    } else {
      aspect = 16 / 9;
    }

    double width = maxWidth;
    double height = width / aspect;

    // Optionally, limit max height for very tall images
    double maxHeight = MediaQuery.of(context).size.height * 0.6;
    if (height > maxHeight) {
      height = maxHeight;
      width = height * aspect;
    }

    return Size(width, height);
  }
}
