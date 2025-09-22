import 'package:everesports/core/page/auth/include/navigatin_bar_profile.dart';
import 'package:everesports/core/page/auth/service/follow_service.dart';
import 'package:everesports/core/page/auth/service/like_service.dart';
import 'package:everesports/core/page/auth/service/user_profile_service.dart';
import 'package:everesports/core/page/auth/util/avatars_style.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:async';

class UsersProfilesPage extends StatefulWidget {
  final String userId;
  const UsersProfilesPage({super.key, required this.userId});

  @override
  State<UsersProfilesPage> createState() => _UsersProfilesPageState();
}

class _UsersProfilesPageState extends State<UsersProfilesPage> {
  @override
  void initState() {
    super.initState();
    developer.log(
      'UsersProfilesPage initState called for userId: ${widget.userId}',
    );
    developer.log('Starting to fetch user profile and follow lists...');

    // Add a small delay to ensure the UI renders first
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fetchUserProfile();
        _fetchFollowLists(widget.userId);
      }
    });
  }

  Map<String, dynamic>? _userProfile;
  bool _isLoading = true; // Start with loading true
  String? _error;
  List<String> _followingUserIds = [];
  List<String> _followerUserIds = [];
  int _likeCount = 0;
  bool _hasNetworkError = false;

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _hasNetworkError = false;
    });

    try {
      developer.log('Fetching user profile for userId: ${widget.userId}');

      // Add timeout to prevent hanging
      final userProfile =
          await UserProfileService.getUserProfileById(widget.userId).timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              developer.log('User profile fetch timed out after 15 seconds');
              throw TimeoutException(
                'Request timed out',
                const Duration(seconds: 15),
              );
            },
          );

      if (!mounted) return;

      if (userProfile != null) {
        developer.log(
          'User profile fetched successfully: ${userProfile.toMap()}',
        );
        setState(() {
          _userProfile = userProfile.toMap();
          _isLoading = false;
        });
      } else {
        developer.log('User profile is null for userId: ${widget.userId}');
        setState(() {
          _error = 'User profile not found';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      developer.log('Error fetching user profile: $e\n$stackTrace');
      if (!mounted) return;

      String errorMessage = 'Failed to load user profile';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Network is unreachable')) {
        errorMessage =
            'Network connection failed. Please check your internet connection and try again.';
        _hasNetworkError = true;
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please try again.';
        _hasNetworkError = true;
      } else if (e.toString().contains('MongoException')) {
        errorMessage = 'Database connection failed. Please try again later.';
        _hasNetworkError = true;
      }

      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFollowLists(String userId) async {
    try {
      developer.log('Fetching follow lists for userId: $userId');
      final following = await FollowServiceUser.getFollowingUserIds(userId);
      final followers = await FollowServiceUser.getFollowerUserIds(userId);
      final like = await LikeServiceUser.getLikesReceivedCount(userId);

      if (mounted) {
        setState(() {
          _followingUserIds = following;
          _followerUserIds = followers;
          _likeCount = like;
        });
        developer.log(
          'Follow lists updated: following=${following.length}, followers=${followers.length}, likes=$like',
        );
      }
    } catch (e, stackTrace) {
      developer.log('Error fetching follow lists: $e\n$stackTrace');
      // Handle follow list errors silently to avoid blocking the UI
      if (mounted) {
        setState(() {
          _followingUserIds = [];
          _followerUserIds = [];
          _likeCount = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // Responsive values
    double bannerHeight = width < 600
        ? 180
        : width < 900
        ? 260
        : 320;
    double avatarRadius = width < 600
        ? 150
        : width < 900
        ? 150
        : 150;
    double avatarImgHeight = avatarRadius * 2;
    double cardPadding = width < 600 ? 15 : 32;
    double maxCardWidth = width >= 900 ? double.infinity : 600;

    // Show immediate loading state while initializing
    if (_userProfile == null && _error == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Initializing user profile...'),
                const SizedBox(height: 8),
                const Text(
                  'Please wait...',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  'User ID: ${widget.userId}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Loading: $_isLoading, Error: $_error',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show loading state
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading user profile...'),
            ],
          ),
        ),
      );
    }

    // Show error state
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _hasNetworkError ? Icons.wifi_off : Icons.error_outline,
                  size: 64,
                  color: _hasNetworkError ? Colors.orange : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _fetchUserProfile,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                    if (_hasNetworkError)
                      ElevatedButton.icon(
                        onPressed: () {
                          // Show network settings or help
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please check your network connection and database configuration',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        },
                        icon: const Icon(Icons.help_outline),
                        label: const Text('Help'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show user profile
    if (_userProfile != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_userProfile!['username'] ?? 'User Profile'),
        ),
        body: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  // Format the user data for the avatar function
                  AvatarStandardbuild(
                    context,
                    {
                      'banner': _userProfile!['coverImageUrl'] ?? '',
                      'avatar': _userProfile!['profileImageUrl'] ?? '',
                      'username': _userProfile!['username'] ?? 'Unknown User',
                      'name': _userProfile!['name'] ?? 'Unknown User',
                      'userId': _userProfile!['userId'] ?? widget.userId,
                      'isPremium': _userProfile!['isPremium'] ?? false,
                      'isVerified': _userProfile!['isVerified'] ?? false,
                      'followersCount':
                          _userProfile!['followersCount'] ??
                          _followerUserIds.length,
                      'followingCount':
                          _userProfile!['followingCount'] ??
                          _followingUserIds.length,
                      'likeCount': _userProfile!['likeCount'] ?? _likeCount,
                    },
                    _followerUserIds.length,
                    _followingUserIds.length,
                    _likeCount,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: NavigatinBarUsersProfile(userId: widget.userId),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Fallback state (should not reach here normally)
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'User ID: ${widget.userId}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text('No user data available'),
              const SizedBox(height: 16),
              const Text('Please check your connection and try again'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchUserProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
