import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/auth/services/auth_service.dart';
import 'package:everesports/core/auth/sign_in/sign_in.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:everesports/widget/common_snackbar.dart';
import 'package:everesports/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class CreateUsernameFireBasePage extends StatefulWidget {
  final String name;
  final String email;
  final String birthday;
  final String password;

  const CreateUsernameFireBasePage({
    super.key,
    required this.name,
    required this.email,
    required this.birthday,
    required this.password,
  });

  @override
  State<CreateUsernameFireBasePage> createState() =>
      _CreateUsernameFireBasePageState();
}

class _CreateUsernameFireBasePageState
    extends State<CreateUsernameFireBasePage> {
  final TextEditingController _userNameCreate = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _userNameCreate.dispose();

    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final username = _userNameCreate.text.trim();
    if (username.isEmpty) {
      commonSnackBarbuild(context, "Username cannot be empty");

      return;
    }

    final isTaken = await UserServiceFireBase.isUsernameTaken(username);
    if (isTaken) {
      commonSnackBarbuild(
        context,
        "Username already taken, please choose another.",
      );

      return;
    }

    try {
      await UserServiceFireBase.insertUser(
        name: widget.name,
        email: widget.email,
        birthday: widget.birthday,
        password: widget.password,
        username: username,
      );

      commonSnackBarbuild(context, "User created successfully!");
      commonNavigationbuild(context, SignInFireBase());

      // Navigate or reset logic if needed here
    } catch (e) {
      commonSnackBarbuild(context, "Error creating user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDarkMode ? mainWhiteColor : mainBlackColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? screenSize.width : 500,
                  minHeight: isMobile ? 0 : screenSize.height * 0.8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "Create Username",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 24 : 28,
                          height: 1.3,
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 32 : 40),
                    commonTextfieldbuild(
                      context,
                      "Username",
                      "Username",
                      _userNameCreate,
                    ),
                    SizedBox(
                      height: isMobile
                          ? MediaQuery.of(context).size.height * 0.55
                          : 40,
                    ),
                    Column(
                      children: [
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 80,
                          child: commonElevatedButtonbuild(
                            context,
                            "Sign Up",

                            () async => await _handleSubmit(),
                          ),
                        ),
                      ],
                    ),
                    if (!isMobile) SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
