import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/auth/home/login_home.dart';
import 'package:everesports/core/page/cristols/cristols_buy.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:everesports/database/config/config.dart';

class CristolButton extends StatefulWidget {
  const CristolButton({Key? key}) : super(key: key);

  // Static list to track all instances
  static final List<CristolButtonState> _instances = [];

  // Static method to refresh all instances
  static Future<void> refreshAllInstances() async {
    for (final instance in _instances) {
      if (instance.mounted) {
        await instance.refreshCristolAmount();
      }
    }
  }

  @override
  CristolButtonState createState() => CristolButtonState();
}

class CristolButtonState extends State<CristolButton> {
  int? cristolAmount;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Add this instance to the static list
    CristolButton._instances.add(this);
    _fetchCristolAmount();
  }

  @override
  void dispose() {
    // Remove this instance from the static list
    CristolButton._instances.remove(this);
    super.dispose();
  }

  // Public method to refresh cristol amount
  Future<void> refreshCristolAmount() async {
    await _fetchCristolAmount();
  }

  Future<void> _fetchCristolAmount() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginHomePage()),
      );
      return;
    }
    try {
      final db = await mongo.Db.create(configDatabase);
      await db.open();
      final collection = db.collection('users_cristols');
      final doc = await collection.findOne({'userId': userId});
      await db.close();
      setState(() {
        // Ensure cristol amount is an integer and handle decimal values
        final rawAmount = doc?['amountCristol'] ?? 0;
        cristolAmount = rawAmount is double
            ? rawAmount.round()
            : (rawAmount is int ? rawAmount : 0);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        cristolAmount = 0;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? secondBlackColor : Colors.grey[200],
        foregroundColor: isDark ? mainWhiteColor : mainBlackColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
      ),
      onPressed: () => commonNavigationbuild(context, const CristolsBuyPage()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/icons/cristol.png", height: 20),
          const SizedBox(width: 5),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    cristolAmount?.toString() ?? '-',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const Icon(Icons.add),
        ],
      ),
    );
  }
}
