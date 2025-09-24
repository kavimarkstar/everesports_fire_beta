import 'package:everesports/core/auth/home/login_home.dart';
import 'package:everesports/widget/common_profile_listview.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:everesports/service/auth/follow_list_page_service.dart';

class FollowListPage extends StatefulWidget {
  final int initialTab; // 0 for Following, 1 for Followers

  const FollowListPage({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _userId;
  List<Map<String, dynamic>> _followingList = [];
  List<Map<String, dynamic>> _followersList = [];
  bool _isLoading = true;
  bool _errorOccurred = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab > 1 ? 0 : widget.initialTab,
    );
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await FollowListPageService; // Ensure DB is initialized
      await _checkSessionAndFetch();
    } catch (e) {
      print('Initialization error: $e');
      setState(() {
        _errorOccurred = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkSessionAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId');

    if (savedUserId == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginHomePage()),
      );
      return;
    }

    setState(() {
      _userId = savedUserId;
    });

    await Future.wait([_fetchFollowingData(), _fetchFollowersData()]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFollowingData() async {
    if (_userId == null) return;

    try {
      final following = await FollowListPageService.getUserFollowing(_userId!);
      if (mounted) {
        setState(() {
          _followingList = following;
        });
      }
    } catch (e) {
      print('Error fetching following: $e');
      setState(() {
        _errorOccurred = true;
      });
    }
  }

  Future<void> _fetchFollowersData() async {
    if (_userId == null) return;

    try {
      final followers = await FollowListPageService.getUserFollowers(_userId!);
      if (mounted) {
        setState(() {
          _followersList = followers;
        });
      }
    } catch (e) {
      print('Error fetching followers: $e');
      setState(() {
        _errorOccurred = true;
      });
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Error loading data'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _errorOccurred = false;
                _isLoading = true;
              });
              _initializeData();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users, bool isFollowingTab) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return CommonProfileListview(
          userId: user['userId'],
          username: user['name'] ?? 'Unknown',
          handle:
              user['username'] != null && user['username'].toString().isNotEmpty
              ? '@${user['username']}'
              : '',
          profileImageUrl: user['profileImageUrl'],
          followDate: user['followedAt'],
          isFollowing: isFollowingTab,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Follows'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Following'),
            Tab(text: 'Followers'),
          ],
        ),
      ),
      body: _errorOccurred
          ? _buildErrorWidget()
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Following List
                _followingList.isEmpty
                    ? _buildEmptyState('You are not following anyone')
                    : _buildUserList(_followingList, true),
                // Followers List
                _followersList.isEmpty
                    ? _buildEmptyState('You have no followers')
                    : _buildUserList(_followersList, false),
              ],
            ),
    );
  }
}
