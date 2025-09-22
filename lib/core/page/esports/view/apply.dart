import 'package:everesports/core/page/esports/model/tournament.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:everesports/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class ApplyPage extends StatefulWidget {
  final Tournament tournament;

  const ApplyPage({super.key, required this.tournament});

  @override
  State<ApplyPage> createState() => _ApplyPageState();
}

class _ApplyPageState extends State<ApplyPage> {
  final TextEditingController _userGameId1Controller = TextEditingController();
  final TextEditingController _userGameId2Controller = TextEditingController();
  final TextEditingController _userGameId3Controller = TextEditingController();
  final TextEditingController _userGameId4Controller = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _userGameId1Controller.dispose();
    _userGameId2Controller.dispose();
    _userGameId3Controller.dispose();
    _userGameId4Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Apply")),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (widget.tournament.teamMode == "SQUAD" ||
                        widget.tournament.teamMode == "DUO" ||
                        widget.tournament.teamMode == "SOLO")
                      TextfieldGameIdbuild(
                        context,
                        _userGameId1Controller,
                        "Name",
                        "Name",
                        onRequest: _showLoading,
                      ),
                    SizedBox(height: 10),
                    if (widget.tournament.teamMode == "SQUAD" ||
                        widget.tournament.teamMode == "DUO")
                      TextfieldGameIdbuild(
                        context,
                        _userGameId2Controller,
                        "Name",
                        "Name",
                        onRequest: _showLoading,
                      ),
                    SizedBox(height: 10),
                    if (widget.tournament.teamMode == "SQUAD")
                      TextfieldGameIdbuild(
                        context,
                        _userGameId3Controller,
                        "Name",
                        "Name",
                        onRequest: _showLoading,
                      ),
                    SizedBox(height: 10),
                    if (widget.tournament.teamMode == "SQUAD")
                      TextfieldGameIdbuild(
                        context,
                        _userGameId4Controller,
                        "Name",
                        "Name",
                        onRequest: _showLoading,
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showLoading() {
    setState(() {
      _isLoading = true;
    });
    // Simulate a delay for loading (e.g., network request)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
}

// ignore: non_constant_identifier_names
Widget TextfieldGameIdbuild(
  BuildContext context,
  TextEditingController controller,
  String hintText,
  String labelText, {
  VoidCallback? onRequest,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        commonTextfieldbuild(context, labelText, hintText, controller),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
            ),
            commonElevatedButtonbuild(context, "Request", onRequest ?? () {}),
          ],
        ),
      ],
    ),
  );
}
