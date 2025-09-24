import 'package:everesports/Theme/colors.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:everesports/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:everesports/widget/common_drop_down.dart';

import 'package:everesports/language/controller/all_language.dart';
import 'user_games_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:everesports/core/page/addGame/service/user_games_service.dart';
import 'package:everesports/widget/common_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddGamePage extends StatefulWidget {
  const AddGamePage({super.key});

  @override
  State<AddGamePage> createState() => _AddGamePageState();
}

class _AddGamePageState extends State<AddGamePage> {
  List<Map<String, dynamic>> _games = [];
  Map<String, dynamic>? _selectedGame;
  final TextEditingController gameNameController = TextEditingController();
  final TextEditingController gameUIDController = TextEditingController();
  final TextEditingController confirmGameUIDController =
      TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  List<Map<String, dynamic>> _userGames = [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkSessionAndFetch();
  }

  Future<void> _checkSessionAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId');
    if (savedUserId == null) {
      if (!mounted) return;
      // Optionally show a snackbar or dialog here
      return;
    }
    setState(() {
      _userId = savedUserId;
    });
    await _fetchGames();
    await _fetchUserGames();
  }

  @override
  void dispose() {
    gameNameController.dispose();
    gameUIDController.dispose();
    confirmGameUIDController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  /// Fetch all games from Firestore 'game_name' collection
  Future<void> _fetchGames() async {
    final query = await FirebaseFirestore.instance
        .collection('game_name')
        .get();
    final games = query.docs.map((doc) {
      final data = doc.data();
      data['_id'] = doc.id;
      return data;
    }).toList();
    setState(() {
      _games = games;
    });
  }

  Future<void> _fetchUserGames() async {
    if (_userId == null) return;
    final userGames = await UserGamesService.fetchUserGames(_userId!);
    setState(() {
      _userGames = userGames;
    });
  }

  Future<void> _addUserGame() async {
    if (_selectedGame == null ||
        gameNameController.text.isEmpty ||
        gameUIDController.text.isEmpty ||
        confirmGameUIDController.text.isEmpty ||
        _birthdayController.text.isEmpty) {
      commonSnackBarbuild(context, getPleaseFillAllFields(context));
      return;
    }
    if (gameUIDController.text != confirmGameUIDController.text) {
      commonSnackBarbuild(context, getGameUIDMismatch(context));
      return;
    }
    if (_userId == null) return;

    // Check if this UID is already used for this game by any user
    final userGames = _userGames;
    final exists = userGames.any(
      (g) =>
          g['game_id'] == _selectedGame!['_id'] &&
          g['game_uid'] == gameUIDController.text,
    );
    if (exists) {
      commonSnackBarbuild(context, getGameUIDAlreadyUsed(context));
      return;
    }
    // Check how many entries user already has for this dropdown game
    final count = userGames
        .where(
          (g) =>
              g['user_id'] == _userId && g['game_id'] == _selectedGame!['_id'],
        )
        .length;
    if (count >= 2) {
      commonSnackBarbuild(context, getMaxTwoEntries(context));
      return;
    }
    await UserGamesService.addUserGame(_userId!, {
      'game_id': _selectedGame!['_id'],
      'game_name': gameNameController.text, // user input
      'dropdown_game_name': _selectedGame!['name'],
      'game_uid': gameUIDController.text,
      'joined_date': _birthdayController.text,
      'created_at': DateTime.now().toIso8601String(),
    });
    await _fetchUserGames();
    commonSnackBarbuild(context, getGameAddedSuccessfully(context));
    // Clear fields after success
    gameNameController.clear();
    gameUIDController.clear();
    confirmGameUIDController.clear();
    _birthdayController.clear();
  }

  Future<void> _selectDate(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: isDarkMode ? mainWhiteColor : mainBlackColor,
              onPrimary: isDarkMode ? mainBlackColor : mainWhiteColor,
              onSurface: isDarkMode ? mainWhiteColor : mainBlackColor,
              surface: isDarkMode ? mainBlackColor : mainWhiteColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: isDarkMode ? mainWhiteColor : mainBlackColor,
              ),
            ),
            dialogBackgroundColor: isDarkMode ? mainBlackColor : mainWhiteColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isMobile(context)
          ? AppBar(title: Text(getAddGames(context)))
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // Mobile/tablet: stack vertically
              return Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: GameDropdown(
                              games: _games,
                              selectedGame: _selectedGame,
                              onChanged: (val) =>
                                  setState(() => _selectedGame = val),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              commonTextfieldbuild(
                                context,
                                "Game Name",
                                "Game Name",
                                gameNameController,
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  commonTextfieldbuild(
                                    context,
                                    "Game UID",
                                    "Game UID",
                                    gameUIDController,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text("Enter Your UID"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              commonTextfieldbuild(
                                context,
                                "Confirm Game UID",
                                "Confirm Game UID",
                                confirmGameUIDController,
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: AbsorbPointer(
                                  child: commonTextfieldbuild(
                                    context,
                                    "Game Joined Date",
                                    "Game Joined Date",
                                    _birthdayController,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 70,
                                width: double.infinity,
                                child: commonElevatedButtonbuild(
                                  context,
                                  "Save",
                                  _addUserGame,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 70,
                                width: double.infinity,
                                child: commonElevatedButtonbuild(
                                  context,
                                  "View My Games",
                                  () async {
                                    await commonNavigationbuild(
                                      context,
                                      UserGamesListPage(
                                        userGames: _userGames,
                                        userId: _userId,
                                        onRefresh: _fetchUserGames,
                                      ),
                                    );

                                    await _fetchUserGames();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // Desktop/web: side by side
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: GameDropdown(
                              games: _games,
                              selectedGame: _selectedGame,
                              onChanged: (val) =>
                                  setState(() => _selectedGame = val),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              commonTextfieldbuild(
                                context,
                                "Game Name",
                                "Game Name",
                                gameNameController,
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  commonTextfieldbuild(
                                    context,
                                    "Game UID",
                                    "Game UID",
                                    gameUIDController,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text("Enter Your UID"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              commonTextfieldbuild(
                                context,
                                "Confirm Game UID",
                                "Confirm Game UID",
                                confirmGameUIDController,
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: AbsorbPointer(
                                  child: commonTextfieldbuild(
                                    context,
                                    "Game Joined Date",
                                    "Game Joined Date",
                                    _birthdayController,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 70,
                                width: double.infinity,
                                child: commonElevatedButtonbuild(
                                  context,
                                  "Save",
                                  _addUserGame,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(vertical: 24),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: UserGamesListPage(
                        userGames: _userGames,
                        userId: _userId,
                        onRefresh: _fetchUserGames,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
