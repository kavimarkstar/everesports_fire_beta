import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/core/auth/home/login_home.dart';
import 'package:everesports/core/auth/services/auth_service.dart';
import 'package:everesports/core/page/profile/page/custom_cropper_page.dart';

import 'package:everesports/language/controller/all_language.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:everesports/widget/common_snackbar.dart';
import 'package:everesports/widget/common_textfield.dart';
import 'package:everesports/widget/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

/// Firestore Service
class ProfileServiceFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> fetchUserById(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  Future<bool> updateUserProfile({
    required String id,
    required String name,
    required String username,
    required String birthday,
    required String password,
    String? profileImageBase64,
    String? coverImageBase64,
  }) async {
    try {
      await _firestore.collection('users').doc(id).update({
        'name': name,
        'username': username,
        'birthday': birthday,
        'password': password,
        'profileImageBase64': profileImageBase64 ?? '',
        'coverImageBase64': coverImageBase64 ?? '',
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteImage({
    required String userId,
    required String imageField, // "profileImageBase64" or "coverImageBase64"
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({imageField: ''});
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Helper to convert image file → Base64
Future<String?> pickImageAsBase64() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  if (picked == null) return null;

  final bytes = await picked.readAsBytes();
  return base64Encode(bytes);
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

/// FireBase Edit Profile Page
class FireBaseEditProfilePage extends StatefulWidget {
  const FireBaseEditProfilePage({super.key});

  @override
  State<FireBaseEditProfilePage> createState() =>
      _FireBaseEditProfilePageState();
}

class _FireBaseEditProfilePageState extends State<FireBaseEditProfilePage> {
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _userId;
  String? _docId;
  String? _profileImageBase64;
  String? _coverImageBase64;

  late ProfileServiceFirebase profileService;

  @override
  void initState() {
    super.initState();
    profileService = ProfileServiceFirebase();
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

  Future<void> _connectAndFetchUser(String id) async {
    try {
      final user = await profileService.fetchUserById(id);
      if (user == null) {
        if (!mounted) return;
        _showError(getUserNotFound(context));
        return;
      }
      if (!mounted) return;
      setState(() {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _birthdayController.text = user['birthday'] ?? '';
        _usernameController.text = user['username'] ?? '';
        _passwordController.text = user['password'] ?? '';
        _profileImageBase64 = user['profileImageBase64'];
        _coverImageBase64 = user['coverImageBase64'];
      });
    } catch (e) {
      _showError("${getFailedToFetchUser(context)}: $e");
    }
  }

  Future<void> _updateUserProfile() async {
    if (_docId == null) {
      _showError(getUserIdIsMissing(context));
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      _showError(getNameCannotBeEmpty(context));
      return;
    }

    if (_usernameController.text.trim().isEmpty) {
      _showError(getUsernameCannotBeEmpty(context));
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      _showError(getPasswordCannotBeEmpty(context));
      return;
    }

    final success = await profileService.updateUserProfile(
      id: _docId!,
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      birthday: _birthdayController.text.trim(),
      password: _passwordController.text.trim(),
      profileImageBase64: _profileImageBase64,
      coverImageBase64: _coverImageBase64,
    );

    if (success) {
      setState(() => _isEditing = false);
      _showSuccess(getProfileupdatedsuccessfully(context));
      await _connectAndFetchUser(_docId!);
    } else {
      _showError(getFailedToUpdateProfile(context));
    }
  }

  Future<void> _changeProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    // Navigate to Cropper
    final croppedBase64 = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => FirebaseCustomCropperPage(
          imageBytes: bytes,
          isProfile: true,
          uploadCallback: (Uint8List croppedBytes) async {
            return base64Encode(croppedBytes); // Returns Base64
          },
        ),
      ),
    );

    if (croppedBase64 != null) {
      setState(() => _profileImageBase64 = croppedBase64);
      await _updateUserProfile();
    }
  }

  Future<void> _changeCoverImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    // Navigate to Cropper
    final croppedBase64 = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => FirebaseCustomCropperPage(
          imageBytes: bytes,
          isProfile: false,
          uploadCallback: (Uint8List croppedBytes) async {
            return base64Encode(croppedBytes); // Returns Base64
          },
        ),
      ),
    );

    if (croppedBase64 != null) {
      setState(() => _coverImageBase64 = croppedBase64);
      await _updateUserProfile();
    }
  }

  Future<void> _deleteProfileImage() async {
    if (_docId == null) return;

    final success = await profileService.deleteImage(
      userId: _docId!,
      imageField: 'profileImageBase64',
    );

    if (success) {
      setState(() => _profileImageBase64 = '');
      _showSuccess(getProfileImageDeleted(context));
    } else {
      _showError(getDeleteFailed(context));
    }
  }

  Future<void> _deleteCoverImage() async {
    if (_docId == null) return;

    final success = await profileService.deleteImage(
      userId: _docId!,
      imageField: 'coverImageBase64',
    );

    if (success) {
      setState(() => _coverImageBase64 = '');
      _showSuccess(getCoverPhotoDeleted(context));
    } else {
      _showError(getDeleteFailed(context));
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    commonSnackBarbuildError(context, message);
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    commonSnackBarbuild(context, message);
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
    final screenWidth = MediaQuery.of(context).size.width;

    double horizontalMargin;
    double avatarRadius;
    double coverHeight;

    if (screenWidth < 700) {
      horizontalMargin = 16;
      avatarRadius = 50;
      coverHeight = 180;
    } else if (screenWidth < 1100) {
      horizontalMargin = 120;
      avatarRadius = 70;
      coverHeight = 220;
    } else {
      horizontalMargin = 280;
      avatarRadius = 100;
      coverHeight = 300;
    }

    return Scaffold(
      appBar: AppBar(title: Text(getEditProfile(context))),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Image
              Card(
                margin: EdgeInsets.symmetric(
                  horizontal: horizontalMargin,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      FireBaseUserAvatar(
                        profileImage: _profileImageBase64,

                        radius: avatarRadius,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          commonElevatedButtonbuild(
                            context,
                            getChange(context),
                            _changeProfileImage,
                          ),
                          const SizedBox(width: 12),
                          if (_profileImageBase64 != null &&
                              _profileImageBase64!.isNotEmpty)
                            commonElevatedButtonbuild(
                              context,
                              getDelete(context),
                              _deleteProfileImage,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Cover Image
              Card(
                margin: EdgeInsets.symmetric(
                  horizontal: horizontalMargin,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        height: coverHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image:
                              _coverImageBase64 != null &&
                                  _coverImageBase64!.isNotEmpty
                              ? DecorationImage(
                                  image: imageFromBase64(
                                    _coverImageBase64!,
                                  )!, //todo
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Colors.grey[300],
                        ),
                        child:
                            _coverImageBase64 == null ||
                                _coverImageBase64!.isEmpty
                            ? Center(
                                child: Icon(
                                  Icons.photo_library,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          commonElevatedButtonbuild(
                            context,
                            getChange(context),
                            _changeCoverImage,
                          ),
                          const SizedBox(width: 12),
                          if (_coverImageBase64 != null &&
                              _coverImageBase64!.isNotEmpty)
                            commonElevatedButtonbuild(
                              context,
                              getDelete(context),
                              _deleteCoverImage,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Text Fields
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                child: Column(
                  children: [
                    commonTextfieldbuild(
                      context,
                      'Name',
                      'Name',
                      _nameController,
                      readOnly: !_isEditing,
                    ),
                    commonTextfieldbuild(
                      context,
                      'Email',
                      'Email',
                      _emailController,
                      readOnly: true,
                    ),
                    commonTextfieldbuild(
                      context,
                      'Birthday',
                      'Birthday',
                      _birthdayController,
                      readOnly: !_isEditing,
                    ),
                    commonTextfieldbuild(
                      context,
                      'Username',
                      'Username',
                      _usernameController,
                      readOnly: !_isEditing,
                    ),
                    commonTextfieldbuild(
                      context,
                      'Password',
                      'Password',
                      _passwordController,
                      readOnly: !_isEditing,
                      obscureText: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  commonElevatedButtonbuild(
                    context,
                    _isEditing
                        ? getSaveChanges(context)
                        : getEditProfile(context),
                    () {
                      if (_isEditing) {
                        _updateUserProfile();
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
                  ),
                  if (_isEditing) ...[
                    const SizedBox(width: 10),
                    commonElevatedButtonbuild(context, getCancel(context), () {
                      setState(() => _isEditing = false);
                      if (_docId != null) _connectAndFetchUser(_docId!);
                    }),
                  ],
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
