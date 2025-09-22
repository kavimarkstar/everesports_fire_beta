import 'package:everesports/core/auth/home/login_home.dart';
import 'package:everesports/core/auth/services/auth_service.dart';
import 'package:everesports/core/page/profile/service/profile_service.dart'
    hide AuthServiceFireBase;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SparkUploadPage extends StatefulWidget {
  const SparkUploadPage({Key? key}) : super(key: key);

  @override
  _SparkUploadPageState createState() => _SparkUploadPageState();
}

class _SparkUploadPageState extends State<SparkUploadPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String? _userId;
  bool _isLoading = false;
  late ProfileServiceFireBase profileServicefirebase;

  @override
  void initState() {
    super.initState();
    profileServicefirebase = ProfileServiceFireBase();
    _checkSessionAndFetch();
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
    } catch (e) {
      await prefs.remove('userId');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginHomePage()),
      );
    }
  }

  Future<void> _uploadSpark() async {
    final String title = _titleController.text.trim();
    final String description = _descController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter title and description")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestore.collection("spark").add({
        "title": title,
        "description": description,
        "user_id": _userId,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Spark uploaded successfully ✅")),
      );

      _titleController.clear();
      _descController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Spark")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadSpark,
                    child: const Text("Upload"),
                  ),
          ],
        ),
      ),
    );
  }
}
