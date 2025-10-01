import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/auth/services/auth_service.dart';
import 'package:everesports/core/auth/sign_in/page/enter_pass_page.dart';
import 'package:everesports/language/controller/all_language.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:everesports/widget/common_line_elevated_button.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:everesports/widget/common_snackbar.dart';
import 'package:everesports/widget/common_textfield_email.dart';
import 'package:flutter/material.dart';

class SignInFireBase extends StatefulWidget {
  const SignInFireBase({super.key});

  @override
  State<SignInFireBase> createState() => _SignInFireBaseState();
}

class _SignInFireBaseState extends State<SignInFireBase> {
  final TextEditingController _emailController = TextEditingController();
  bool _isInputValid = false;
  bool _isLoading = false;
  bool _emailExists = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();

    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    final email = _emailController.text.trim();

    // Validate email format
    final emailError = emailValidator(email);

    // Update error state
    setState(() {
      _emailError = emailError;
      _isInputValid = emailError == null && email.isNotEmpty && _emailExists;
    });

    if (emailError == null && email.isNotEmpty) {
      _checkEmailExists(email);
    } else {
      setState(() => _emailExists = false);
    }
  }

  Future<void> _checkEmailExists(String email) async {
    final exists = await AuthServiceFireBase.isEmailExists(email);
    setState(() {
      _emailExists = exists;
      _isInputValid = _emailError == null && exists;
    });
  }

  Future<void> _handleNext() async {
    if (!_isInputValid) {
      if (_emailError != null) {
        commonSnackBarbuild(context, _emailError!);
      } else if (!_emailExists) {
        commonSnackBarbuild(context, getEmaildoesnotexistPleasesignup(context));
      }
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Simulate processing

    if (!mounted) return;

    commonNavigationbuild(
      context,
      EnterPassFireBasePage(userInput: _emailController.text.trim()),
    );

    setState(() => _isLoading = false);
  }

  String? emailValidator(String email) {
    if (email.isEmpty) return getEmailisrequired(context);

    // Accept any email format (basic validation)
    final pattern = r'^[\w\.-]+@[\w\.-]+\.\w+$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(email)) {
      return getPleaseenteravalidemailaddress(context);
    }

    return null; // valid
  }

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
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
                        getTogetstartedfirstenteryouremail(context),
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 24 : 28,
                          height: 1.3,
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 32 : 40),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        commonTextfieldEmailbuild(
                          context,
                          getEmail(context),
                          getEmail(context),
                          _emailController,
                        ),
                        if (_emailError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 15),
                            child: Text(
                              _emailError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (_emailError == null &&
                            !_emailExists &&
                            _emailController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 15),
                            child: Text(
                              getEmaildoesnotexistPleasesignup(context),
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: isMobile
                          ? MediaQuery.of(context).size.height * 0.4
                          : 40,
                    ),

                    // Buttons Section
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: isMobile ? 80 : 80,
                          child: commonLineElevatedButtonbuild(
                            context,
                            getForgotpassword(context),
                            () {
                              // Add forgot password action here
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: isMobile ? 80 : 80,
                          child: commonElevatedButtonbuild(
                            context,
                            getNext(context),
                            _isInputValid && !_isLoading ? _handleNext : null,
                          ),
                        ),
                      ],
                    ),
                    if (!isMobile) const SizedBox(height: 32),
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
