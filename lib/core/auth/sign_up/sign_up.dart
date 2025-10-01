import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/auth/services/auth_service.dart';
import 'package:everesports/core/auth/sign_up/page/create_pass.dart';
import 'package:everesports/language/controller/all_language.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:everesports/widget/common_snackbar.dart';
import 'package:everesports/widget/common_textfield.dart'
    show commonTextfieldbuild;
import 'package:everesports/widget/common_textfield_email.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SignUpFireBase extends StatefulWidget {
  const SignUpFireBase({super.key});

  @override
  State<SignUpFireBase> createState() => _SignUpFireBaseState();
}

class _SignUpFireBaseState extends State<SignUpFireBase> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  bool _isInputValid = false;
  bool _isLoading = false;
  bool _emailExists = false;

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_validateInput);
    _emailController.addListener(() {
      _validateInput();
      _checkEmailExists(_emailController.text.trim());
    });
    _birthdayController.addListener(_validateInput);
  }

  Future<void> _checkEmailExists(String email) async {
    if (email.isEmpty) {
      setState(() => _emailExists = false);
      return;
    }

    final exists = await AuthServiceFireBase.isEmailExists(email);
    setState(() => _emailExists = exists);
  }

  void _validateInput() {
    setState(() {
      _isInputValid =
          _nameController.text.trim().isNotEmpty &&
          _emailController.text.trim().isNotEmpty &&
          _birthdayController.text.trim().isNotEmpty &&
          !_emailExists;
    });
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

  Future<void> _handleNext() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final birthday = _birthdayController.text.trim();
    final error = emailValidator(email);

    if (error != null) {
      commonSnackBarbuild(context, error);
      return;
    }
    if (name.isEmpty || email.isEmpty || birthday.isEmpty) {
      commonSnackBarbuild(context, "All fields are required");
      return;
    }

    setState(() => _isLoading = true);

    final exists = await AuthServiceFireBase.isEmailExists(email);
    if (exists) {
      setState(() {
        _emailExists = true;
        _isLoading = false;
      });

      commonSnackBarbuild(context, "This email is already in use");
      return;
    }

    setState(() => _emailExists = false);

    // Proceed to next page
    commonNavigationbuild(
      context,
      CreatePassFireBasePage(name: name, email: email, birthday: birthday),
    );

    setState(() => _isLoading = false);
  }

  String? emailValidator(String email) {
    if (email.isEmpty) return getEmailisrequired(context);

    final pattern = r'^[\w\.-]+@(?:gmail\.com|outlook\.com)$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(email.trim())) {
      return 'Only @gmail.com or @outlook.com emails are allowed';
    }

    return null; // valid
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "Create your account",
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
                      "Name",
                      "Name",
                      _nameController,
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        commonTextfieldEmailbuild(
                          context,
                          getEmail(context),
                          getEmail(context),

                          _emailController,
                        ),
                        if (_emailExists)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 15),
                            child: Text(
                              "This email is already in use",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),

                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: commonTextfieldbuild(
                          context,
                          "Birthday",
                          "Birthday",
                          _birthdayController,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: isMobile
                          ? MediaQuery.of(context).size.height * 0.35
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
                            getNext(context),
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
