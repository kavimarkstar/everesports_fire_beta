import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/core/page/esports/model/tournament.dart';
import 'package:everesports/core/page/esports/view/bottom_sheet.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplyPage extends StatefulWidget {
  final Tournament tournament;

  const ApplyPage({super.key, required this.tournament});

  @override
  State<ApplyPage> createState() => _ApplyPageState();
}

class _ApplyPageState extends State<ApplyPage> {
  // Each user slot stores the selected user data (null if not selected)
  List<Map<String, dynamic>?> _users = [];

  bool _isLoading = false;
  bool _isInitLoading = true;
  String? _currentUserId;

  int get teamSize {
    // Map teamMode to team size
    switch (widget.tournament.teamMode) {
      case "SOLO":
        return 1;
      case "DUO":
        return 2;
      case "SQUAD":
        return 4;
      default:
        // Try to parse as int, fallback to 1
        final n = int.tryParse(widget.tournament.teamMode);
        return n != null && n > 0 ? n : 1;
    }
  }

  @override
  void initState() {
    super.initState();
    _users = List<Map<String, dynamic>?>.filled(
      teamSize,
      null,
      growable: false,
    );
    _autoSelectCurrentUser();
  }

  Future<void> _autoSelectCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('userId');
      if (currentUserId != null && currentUserId.isNotEmpty) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('userId', isEqualTo: currentUserId)
            .limit(1)
            .get();
        if (userDoc.docs.isNotEmpty) {
          final userData = userDoc.docs.first.data();
          setState(() {
            _users[0] = userData;
            _currentUserId = currentUserId;
            _isInitLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      // ignore error, just don't prefill
    }
    setState(() {
      _isInitLoading = false;
    });
  }

  Future<void> _pickUser(int userIndex) async {
    final userId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return BottomSheetView();
      },
    );
    if (userId != null && userId.isNotEmpty) {
      // Check if this user is already selected in another slot
      final selectedUserIds = [
        for (int i = 0; i < _users.length; i++)
          if (_users[i] != null) _users[i]!['userId'],
      ];

      // Remove the userId of the current slot (if any) to allow re-selecting the same user in the same slot
      String? currentSlotUserId = _users[userIndex]?['userId'];
      final filteredSelectedUserIds = selectedUserIds
          .where((id) => id != currentSlotUserId)
          .toList();

      if (filteredSelectedUserIds.contains(userId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This user is already selected in another slot.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Fetch user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data();
        setState(() {
          _users[userIndex] = userData;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _submitRequest() async {
    setState(() {
      _isLoading = true;
    });

    // Collect userIds from selected users
    final List<String> userIds = [
      for (final user in _users)
        if (user != null && user['userId'] != null) user['userId'] as String,
    ];

    // Validate: at least one user must be selected
    if (userIds.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one team member.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('tournament_members').add({
        'userIds': userIds,
        'userId': _currentUserId,
        'tournamentId': widget.tournament.tournamentId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request submitted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Optionally clear selections after successful request
      setState(() {
        _users = List<Map<String, dynamic>?>.filled(
          teamSize,
          null,
          growable: false,
        );
      });
      // Optionally, re-select current user in slot 1 after submit
      _autoSelectCurrentUser();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit request: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildFormContent(BuildContext context) {
    if (_isInitLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < teamSize; i++) ...[
            UserProfileSelector(
              user: _users[i],
              onAdd: () => _pickUser(i),
              // Prevent current user from removing themselves in slot 0
              onRemove:
                  (i == 0 &&
                      _users[0] != null &&
                      _currentUserId != null &&
                      _users[0]!['userId'] == _currentUserId)
                  ? null
                  : () => setState(() => _users[i] = null),
              isCurrentUser:
                  (i == 0 &&
                  _users[0] != null &&
                  _currentUserId != null &&
                  _users[0]!['userId'] == _currentUserId),
            ),
            if (i != teamSize - 1) const SizedBox(height: 10),
          ],
          const SizedBox(height: 24),
          commonElevatedButtonbuild(
            context,
            "Request",
            _isLoading ? null : _submitRequest,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Always show the page, regardless of platform/width
    return isMobile(context)
        ? Scaffold(
            appBar: isMobile(context)
                ? AppBar(title: const Text("Apply"))
                : null,
            body: SafeArea(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildFormContent(context),
            ),
          )
        : _buildFormContent(context);
  }
}

class UserProfileSelector extends StatelessWidget {
  final Map<String, dynamic>? user;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final bool isCurrentUser;

  const UserProfileSelector({
    Key? key,
    required this.user,
    this.onAdd,
    this.onRemove,
    this.isCurrentUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      // Show add button if no user selected
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: onAdd ?? () {},
                icon: const Icon(Icons.add),
              ),
            ),
            const Expanded(
              child: Text("Add team member", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      );
    } else {
      // Show user profile info
      final String name = user!['name'] ?? '';
      final String userId = user!['userId'] ?? '';
      final String? profileBase64 = user!['profileImageBase64'];
      ImageProvider? imageProvider;
      if (profileBase64 != null && profileBase64.isNotEmpty) {
        try {
          imageProvider = MemoryImage(base64Decode(profileBase64));
        } catch (_) {}
      }
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent,
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(userId, style: const TextStyle(fontSize: 13)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCurrentUser)
                IconButton(
                  onPressed: onRemove ?? () {},
                  icon: const Icon(Icons.close),
                  tooltip: "Remove",
                ),
              if (isCurrentUser)
                Tooltip(
                  message: "You cannot remove yourself",
                  child: Icon(Icons.lock, color: Colors.grey),
                ),
            ],
          ),
        ),
      );
    }
  }
}
