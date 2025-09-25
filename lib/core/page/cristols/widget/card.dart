import 'package:everesports/core/auth/home/login_home.dart';
import 'package:everesports/core/auth/services/auth_service.dart';
import 'package:everesports/core/page/profile/service/profile_service.dart'
    hide AuthServiceFireBase;
import 'package:everesports/widget/common_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CristolsCard extends StatefulWidget {
  const CristolsCard({super.key});

  @override
  State<CristolsCard> createState() => _CristolsCardState();
}

class _CristolsCardState extends State<CristolsCard> {
  late ProfileServiceFireBase profileServicefirebase;
  final _usernameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    profileServicefirebase = ProfileServiceFireBase();
    _checkSessionAndFetch();
  }

  String? _userId;
  String? _docId;
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

    _userId = savedUserId;

    try {
      final docId = await AuthServiceFireBase.getDocIdByUserId(_userId!);
      if (docId == null) {
        await prefs.remove('userId');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginHomePage()),
        );
        return;
      }

      _docId = docId;
      await _connectAndFetchUser(_docId!);
    } catch (e) {
      await prefs.remove('userId');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginHomePage()),
      );
    }
  }

  Future<void> _connectAndFetchUser(String docId) async {
    try {
      final user = await profileServicefirebase.fetchUserById(docId);
      if (user == null) {
        if (!mounted) return;

        return;
      }

      setState(() {
        _usernameController.text = user['username'] ?? '';
      });
    } catch (e) {
      _showError("Failed to fetch user: $e");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    commonSnackBarbuild(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final isdark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: 420,
        child: Card(
          child: Stack(
            children: [
              if (isdark) Image.asset('assets/images/white.png'),
              if (!isdark) Image.asset('assets/images/black.png'),

              Positioned(
                left: 30,
                right: 0,
                bottom: 30,
                child: Text(
                  _usernameController.text.toString(),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
