import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/auth/sign_up/page/create_username.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:everesports/widget/common_textfield_pass.dart';
import 'package:flutter/material.dart';

class CreatePassFireBasePage extends StatefulWidget {
  final String name;
  final String email;
  final String birthday;
  const CreatePassFireBasePage({
    super.key,
    required this.name,
    required this.email,
    required this.birthday,
  });

  @override
  State<CreatePassFireBasePage> createState() => _CreatePassFireBasePageState();
}

class _CreatePassFireBasePageState extends State<CreatePassFireBasePage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isInputValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validateInput);
    _confirmPasswordController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _isInputValid =
          _passwordController.text.trim().isNotEmpty &&
          _confirmPasswordController.text.trim().isNotEmpty;
    });
  }

  Future<void> _handleNext() async {
    if (!_isInputValid) return;

    setState(() => _isLoading = true);
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Simulate processing

    if (!mounted) return;
    commonNavigationbuild(
      context,
      CreateUsernameFireBasePage(
        name: widget.name,
        email: widget.email,
        birthday: widget.birthday,
        password: _passwordController.text.trim(),
      ),
    );
    setState(() => _isLoading = false);
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "Enter password",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 24 : 28,
                          height: 1.3,
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 32 : 40),

                    PasswordFieldWidget(
                      confirmPasswordController: _confirmPasswordController,
                      passwordController: _passwordController,
                    ),

                    SizedBox(
                      height: isMobile
                          ? MediaQuery.of(context).size.height * 0.5
                          : 40,
                    ),

                    // Buttons Section
                    Column(
                      children: [
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: isMobile ? 80 : 80,
                          child: commonElevatedButtonbuild(
                            context,
                            "Next",
                            _isInputValid && !_isLoading ? _handleNext : null,
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
