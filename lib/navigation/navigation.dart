import 'dart:convert';
import 'dart:typed_data';
import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/auth/home/login_home.dart';
import 'package:everesports/core/auth/logout/logout.dart';
import 'package:everesports/core/auth/services/auth_service.dart';
import 'package:everesports/core/page/addGame/add_game.dart';
import 'package:everesports/core/page/cristols/widget/cristol_button.dart';
import 'package:everesports/core/page/esports/esports.dart';
import 'package:everesports/core/page/home/home.dart';
import 'package:everesports/core/page/notification/notification.dart';
import 'package:everesports/core/page/profile/profile_page.dart';
import 'package:everesports/core/page/profile/service/profile_service.dart'
    hide AuthServiceFireBase;
import 'package:everesports/core/page/setting/view/language_view.dart';
import 'package:everesports/core/page/setting/view/theme_switcher.dart';
import 'package:everesports/core/page/spark/spark.dart';
import 'package:everesports/core/page/spark/upload/spark_upload.dart';
import 'package:everesports/core/page/subscription/subscription_page.dart';
import 'package:everesports/core/page/upload/upload_page.dart';
import 'package:everesports/core/tasks/tasks.dart';
import 'package:everesports/database/config/config.dart';
import 'package:everesports/language/controller/all_language.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:everesports/service/auth/profile_service.dart';
import 'package:everesports/widget/common_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int selectedIndex = 0;
  String? _userId;
  String? _docId;
  String? _profileImageBase64;
  ProfileService? profileService;
  final String serverBaseUrl = fileServerBaseUrl;
  ProfileServiceFireBase? profileServicefirebase;

  @override
  void initState() {
    super.initState();
    try {
      profileServicefirebase = ProfileServiceFireBase();
      _checkSessionAndFetch();
      _checkSessionAndFetchFireBase();
    } catch (e) {
      debugPrint('Error initializing services: $e');
      // Show error to user
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showError("Failed to initialize services. Please restart the app.");
        }
      });
    }
  }

  /// Returns the default avatar asset path.
  String get defaultAvatarPath => 'assets/icons/user_avatar.png';

  /// Returns the icon asset list, with a special case for the profile icon.
  List<Map<String, String>> get assetIcons => [
    {
      'default': 'assets/icons/home.png',
      'selected': 'assets/icons/home_selected.png',
    },
    {
      'default': 'assets/icons/spark.png',
      'selected': 'assets/icons/spark_selected.png',
    },
    {
      'default': 'assets/icons/game_controller.png',
      'selected': 'assets/icons/game_controller_selected.png',
    },
    {
      'default': 'assets/icons/notification.png',
      'selected': 'assets/icons/notification_selected.png',
    },
    {
      // Special handling for profile icon: use a dummy string if base64 exists
      'default':
          (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty)
          ? 'base64_profile'
          : "assets/icons/profile.png",
      'selected':
          (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty)
          ? 'base64_profile'
          : "assets/icons/profile_selected.png",
    },
    {
      'default': 'assets/icons/add_spark.png',
      'selected': 'assets/icons/add_spark_selected.png',
    },
    {
      'default': 'assets/icons/add.png',
      'selected': 'assets/icons/add_selected.png',
    },
    {
      'default': 'assets/icons/add_games.png',
      'selected': 'assets/icons/add_games_selected.png',
    },
    {
      'default': 'assets/icons/performance.png',
      'selected': 'assets/icons/performance_selected.png',
    },
    {
      'default': 'assets/icons/premium.png',
      'selected': 'assets/icons/premium_selected.png',
    },
  ];

  /// Returns the list of pages for navigation.
  final List<Widget> pages = [
    const HomePage(),
    SparkPage(),
    const EsportsPage(),
    const NotificationPage(),
    const FireBaseProfilePage(),
    const SparkUploadPage(),
    const UploadPage(),
    const AddGamePage(),
    const TasksPage(),
    const SubscriptionPage(),
  ];

  /// Returns the list of titles for navigation.
  List<String> get titles => [
    getHome(context),
    'Spark',
    getTournaments(context),
    'Notifications',
    'Profile',
    'Posts Spark',
    'Posts',
    'Add Games',
    'Performance',
    'Premium',
  ];

  /// Decodes a Base64 string to an ImageProvider.
  ImageProvider? imageFromBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      Uint8List bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } catch (e) {
      return null;
    }
  }

  /// Builds the icon for the navigation item at [index].
  Widget buildIcon(int index, bool isSelected) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String iconPath = isSelected
        ? assetIcons[index]['selected']!
        : assetIcons[index]['default']!;

    // Special handling for profile icon with base64 image
    if (iconPath == 'base64_profile') {
      final imageProvider = imageFromBase64(_profileImageBase64);
      if (imageProvider != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(200),
          child: Image(
            image: imageProvider,
            width: 25,
            height: 25,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Image.asset(defaultAvatarPath, width: 25, height: 25),
          ),
        );
      } else {
        // fallback to default avatar if base64 is invalid
        return ClipRRect(
          borderRadius: BorderRadius.circular(200),
          child: Image.asset(defaultAvatarPath, width: 25, height: 25),
        );
      }
    }

    // Always show the default avatar as a circle if requested
    if (iconPath == defaultAvatarPath) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(200),
        child: Image.asset(defaultAvatarPath, width: 25, height: 25),
      );
    }

    // Network image
    if (iconPath.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(200),
        child: Image.network(
          iconPath,
          width: 25,
          height: 25,
          errorBuilder: (context, error, stackTrace) =>
              Image.asset(defaultAvatarPath, width: 25, height: 25),
        ),
      );
    }

    // Asset image
    return Image.asset(
      iconPath,
      width: 24,
      height: 24,
      color: isDarkMode ? mainWhiteColor : mainBlackColor,
    );
  }

  /// Checks session and fetches user from local DB.
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
    await _connectAndFetchUser(_userId!);
  }

  /// Fetches user from local DB.
  Future<void> _connectAndFetchUser(String id) async {
    if (profileService == null) {
      _showError("Profile service not initialized. Please restart the app.");
      return;
    }

    try {
      final user = await profileService!.fetchUserById(id);
      if (user == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showError(getUserNotFound(context));
          }
        });
        return;
      }
      if (!mounted) return;
      setState(() {
        _userId = user['userId'];
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showError("${getFailedToFetchUser(context)} $e");
        }
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    commonSnackBarbuild(context, message);
  }

  /// Checks session and fetches user from Firebase.
  Future<void> _checkSessionAndFetchFireBase() async {
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
      await _connectAndFetchUserFireBase(_docId!);
    } catch (e) {
      await prefs.remove('userId');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginHomePage()),
      );
    }
  }

  /// Fetches user from Firebase and updates base64 profile image.
  Future<void> _connectAndFetchUserFireBase(String docId) async {
    if (profileServicefirebase == null) {
      _showError(
        "Firebase profile service not initialized. Please restart the app.",
      );
      return;
    }

    try {
      final user = await profileServicefirebase!.fetchUserById(docId);
      if (user == null) {
        if (!mounted) return;

        return;
      }

      setState(() {
        _profileImageBase64 = user['profileImageBase64'];
      });
    } catch (e) {
      _showError("Failed to fetch user: $e");
    }
  }

  /// Handles navigation selection.
  void onSelectPage(int index) {
    setState(() => selectedIndex = index);
  }

  /// Builds the sidebar for desktop/tablet.
  Widget buildSidebar(BuildContext context) {
    final bool showText = isDesktop(context);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: isTablet(context) ? 100 : 250,
      color: isDarkMode ? mainBlackColor : mainWhiteColor,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: titles.length,
              itemBuilder: (context, index) {
                final bool isSelected = selectedIndex == index;

                final backgroundColor = isSelected
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.transparent;

                final textColor = isSelected
                    ? (isDarkMode ? mainWhiteColor : mainBlackColor)
                    : (isDarkMode ? mainWhiteColor : mainBlackColor);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 1,
                    horizontal: 10,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      foregroundColor: textColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 17,
                        horizontal: 15,
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(150),
                      ),
                    ),
                    onPressed: () => onSelectPage(index),
                    child: Row(
                      mainAxisAlignment: showText
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        buildIcon(index, isSelected),
                        if (showText) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              titles[index],
                              style: TextStyle(
                                color: textColor,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool smallScreen = isMobile(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: !smallScreen
          ? AppBar(
              title: Text(
                getEveresports(context),
                style: TextStyle(
                  color: isDark ? mainWhiteColor : mainBlackColor,
                  fontFamily: 'LemonJelly',
                  fontSize: 35,
                  fontWeight: FontWeight.w300,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                CristolButton(),
                PopupMenuButton<int>(
                  icon: Icon(Icons.settings),
                  menuPadding: EdgeInsets.all(0),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      enabled: false,
                      padding: EdgeInsets.all(0),
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ThemeSwitcher(),
                                LanguageView(),
                                LogoutButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: smallScreen
            ? pages[selectedIndex]
            : Row(
                children: [
                  buildSidebar(context),
                  Expanded(child: pages[selectedIndex]),
                ],
              ),
      ),
      bottomNavigationBar: smallScreen
          ? BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              currentIndex: selectedIndex < 5 ? selectedIndex : 0,
              onTap: (index) {
                if (index < 5) {
                  onSelectPage(index);
                }
              },
              items: List.generate(5, (index) {
                final isSelected = selectedIndex == index;
                return BottomNavigationBarItem(
                  icon: buildIcon(index, isSelected),
                  label: titles[index],
                );
              }),
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.grey,
            )
          : null,
    );
  }
}
