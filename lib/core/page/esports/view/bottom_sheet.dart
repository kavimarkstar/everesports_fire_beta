import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';

class BottomSheetView extends StatefulWidget {
  BottomSheetView({Key? key}) : super(key: key);

  @override
  _BottomSheetViewState createState() => _BottomSheetViewState();
}

class _BottomSheetViewState extends State<BottomSheetView> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _selectedUserId;
  // For debouncing user input
  int _lastSearchTimestamp = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    final query = _searchController.text;
    // Debounce: only search if user stops typing for 350ms
    final int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    _lastSearchTimestamp = currentTimestamp;
    Future.delayed(const Duration(milliseconds: 350), () {
      if (_lastSearchTimestamp == currentTimestamp) {
        _searchUsers(query);
      }
    });
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      _isLoading = true;
      _searchResults = [];
      // Do not clear _selectedUserId here, so user can select and add
    });

    if (query.trim().isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Search by userId or username (case-insensitive)
      final usersRef = FirebaseFirestore.instance.collection('users');
      final userIdQuery = usersRef.where('userId', isEqualTo: query.trim());
      final usernameQuery = usersRef
          .where('username', isGreaterThanOrEqualTo: query.trim())
          .where('username', isLessThanOrEqualTo: query.trim() + '\uf8ff');

      final userIdSnap = await userIdQuery.get();
      final usernameSnap = await usernameQuery.get();

      // Use a map to deduplicate users by document ID
      final Map<String, Map<String, dynamic>> results = {};

      for (var doc in userIdSnap.docs) {
        results[doc.id] = doc.data();
      }
      for (var doc in usernameSnap.docs) {
        results[doc.id] = doc.data();
      }

      setState(() {
        _searchResults = results.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final String name = user['name'] ?? '';
    final String userId = user['userId'] ?? '';
    final String? profileBase64 = user['profileImageBase64'];
    ImageProvider? imageProvider;
    if (profileBase64 != null && profileBase64.isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(profileBase64));
      } catch (_) {}
    }

    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: imageProvider,
        child: imageProvider == null
            ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text(name),
      subtitle: Text(userId),
      selected: _selectedUserId == userId,
      onTap: () {
        setState(() {
          _selectedUserId = userId;
        });
        // Immediately return the selected userId to the previous page (apply.dart)
        Navigator.pop(context, userId);
      },
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? secondBlackColor : secondWhiteColor,
        border: Border.all(
          color: isDarkMode ? secondBlackColor : secondWhiteColor,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Team Member',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by User ID or Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchUsers(_searchController.text),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              )
            else if (_searchResults.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return _buildUserTile(_searchResults[index]);
                  },
                ),
              )
            else if (_searchController.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No users found.'),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                // The "Add" button is no longer needed, as selection is immediate
                // Expanded(
                //   child: ElevatedButton(
                //     onPressed: _selectedUserId != null
                //         ? () {
                //             Navigator.pop(context, _selectedUserId);
                //           }
                //         : null,
                //     child: const Text('Add'),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
