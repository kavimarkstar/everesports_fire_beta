import 'package:everesports/Theme/colors.dart';
import 'package:everesports/language/controller/all_language.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback? onLogoutSuccess;

  const LogoutButton({super.key, this.onLogoutSuccess});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Clear stored userId

    // Optional: call callback if provided
    if (onLogoutSuccess != null) {
      onLogoutSuccess!();
    }

    // Navigate to login or main page
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.logout_outlined, color: mainRedColor),
      title: Text(
        getLogout(context),
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark
              ? mainWhiteColor
              : mainBlackColor,
        ),
      ),
      onTap: () => _logout(context),
    );
  }
}
