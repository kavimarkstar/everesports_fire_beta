import 'dart:convert';

import 'package:everesports/core/auth/home/login_home.dart';
import 'package:everesports/core/page/cristols/widget/cristol_button.dart';
import 'package:everesports/core/page/profile/page/edit_profile_form.dart';
import 'package:everesports/core/page/profile/service/profile_service.dart';
import 'package:everesports/core/page/profile/widget/follow_counts.dart';
import 'package:everesports/core/page/profile/widget/navigatin_bar_profile.dart';
import 'package:everesports/core/page/profile/widget/social_media_buttons.dart';
import 'package:everesports/core/page/setting/setting_page.dart';
import 'package:everesports/core/page/upload/upload_page.dart';

import 'package:everesports/language/controller/all_language.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:everesports/widget/common_snackbar.dart';
import 'package:everesports/Theme/colors.dart';
import 'package:everesports/widget/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FireBaseProfilePage extends StatefulWidget {
  const FireBaseProfilePage({super.key});

  @override
  State<FireBaseProfilePage> createState() =>
      _FireBaseProfilePageProfilePageState();
}

class _FireBaseProfilePageProfilePageState extends State<FireBaseProfilePage> {
  bool _isLoading = true;
  bool _isUploadingImage = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _userId;
  String? _docId;
  String? _profileImageBase64;
  String? _coverImageBase64;

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
        _showError("User not found.");
        return;
      }

      setState(() {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _birthdayController.text = user['birthday'] ?? '';
        _usernameController.text = user['username'] ?? '';
        _passwordController.text = user['password'] ?? '';
        _profileImageBase64 = user['profileImageBase64'];
        _coverImageBase64 = user['coverImageBase64'];
        _isLoading = false;
      });
    } catch (e) {
      _showError("Failed to fetch user: $e");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    commonSnackBarbuild(context, message);
  }

  /// Decode Base64 string → ImageProvider
  ImageProvider? imageFromBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      Uint8List bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: isMobile(context)
          ? AppBar(
              title: Text(_nameController.text.toString()),
              backgroundColor: isDark ? mainBlackColor : mainWhiteColor,
              foregroundColor: isDark ? mainWhiteColor : mainBlackColor,

              actions: [
                CristolButton(),
                IconButton(
                  onPressed: () =>
                      commonNavigationbuild(context, const SettingPage()),
                  icon: Icon(
                    Icons.settings_outlined,
                    color: isDark ? mainWhiteColor : mainBlackColor,
                  ),
                ),
              ],
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile(context) ? 16 : 40,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Container(
                      height: isMobile(context)
                          ? 280
                          : isTablet(context)
                          ? 350
                          : 450,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? secondBlackColor : mainWhiteColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          // Cover Photo
                          Container(
                            height: isMobile(context)
                                ? 180
                                : isTablet(context)
                                ? 200
                                : 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image:
                                  (_coverImageBase64 != null &&
                                      _coverImageBase64!.isNotEmpty &&
                                      imageFromBase64(_coverImageBase64) !=
                                          null)
                                  ? DecorationImage(
                                      image: imageFromBase64(
                                        _coverImageBase64,
                                      )!,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: Colors.grey[300],
                            ),
                            child:
                                (_coverImageBase64 == null ||
                                    _coverImageBase64!.isEmpty ||
                                    imageFromBase64(_coverImageBase64) == null)
                                ? Center(
                                    child: Icon(
                                      Icons.photo_library,
                                      size: 50,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                : null,
                          ),
                          // Cover Photo Actions
                          Positioned(
                            bottom: isMobile(context)
                                ? 10
                                : isTablet(context)
                                ? 70
                                : 70,
                            right: 0,
                            child: Row(
                              children: [
                                SizedBox(
                                  height: isDesktop(context) ? 75 : 75,
                                  child: commonElevatedButtonbuild(
                                    context,
                                    getEdit(context),
                                    () {
                                      commonNavigationbuild(
                                        context,
                                        FireBaseEditProfilePage(),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Profile Picture
                          Positioned(
                            bottom: isMobile(context) ? 20 : 40,
                            left: isMobile(context) ? 20 : 40,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? mainBlackColor
                                      : mainWhiteColor,
                                  width: 4,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  FireBaseUserAvatar(
                                    profileImage: _profileImageBase64,
                                    radius: isMobile(context) ? 50 : 100,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isDesktop(context))
                            Positioned(
                              top: 316,
                              left: 260,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  profileDataDesktopbuild(context),
                                  FollowCounts(),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!isDesktop(context))
                      Card(
                        elevation: 5,
                        shadowColor: Colors.grey.withOpacity(0.3),

                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FollowCounts(),
                              socialMediaButtonbuild(context),
                              profileDatabuild(context),
                            ],
                          ),
                        ),
                      ),

                    // Cntents
                    NavigatinBarProfile(),
                  ],
                ),
              ),
            ),

      floatingActionButton: isMobile(context)
          ? FloatingActionButton(
              backgroundColor: isDark ? mainWhiteColor : mainBlackColor,

              onPressed: () {
                commonNavigationbuild(context, UploadPage());
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget profileDatabuild(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        if (!isDesktop(context))
          if (!isMobile(context))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                _nameController.text.toString(),
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: GestureDetector(
            onTap: () {
              Clipboard.setData(
                ClipboardData(text: _usernameController.text.toString()),
              );
              commonSnackBarbuild(
                context,
                "@${_usernameController.text.toString()} ${getUsernamecopiedt(context)} ",
              );
            },
            child: Text(
              "@${_usernameController.text.toString()}",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
            ),
          ),
        ),

        SizedBox(
          width: MediaQuery.of(context).size.width * 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  getUserID(context),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                GestureDetector(
                  onTap: () {
                    if (_userId != null) {
                      Clipboard.setData(
                        ClipboardData(text: _userId.toString()),
                      );
                      commonSnackBarbuild(
                        context,
                        '${_userId.toString()} ${getCopied(context)}',
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        _userId != null ? _userId.toString() : '',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? mainWhiteColor : mainBlackColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.copy, size: 16, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget profileDataDesktopbuild(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (!isMobile(context))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  _nameController.text.toString(),
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: _usernameController.text.toString()),
                  );
                  commonSnackBarbuild(
                    context,
                    "@${_usernameController.text.toString()} ${getUsernamecopiedt(context)} ",
                  );
                },
                child: Text(
                  "@${_usernameController.text.toString()}",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            children: [
              Text(
                getUserID(context),
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              GestureDetector(
                onTap: () {
                  if (_userId != null) {
                    Clipboard.setData(ClipboardData(text: _userId.toString()));
                    commonSnackBarbuild(
                      context,
                      '${_userId.toString()} ${getCopied(context)}',
                    );
                  }
                },
                child: Row(
                  children: [
                    Text(
                      _userId != null ? _userId.toString() : '',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? mainWhiteColor : mainBlackColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.copy, size: 16, color: Colors.grey[600]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
