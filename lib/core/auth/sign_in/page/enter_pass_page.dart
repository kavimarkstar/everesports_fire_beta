import 'package:everesports/core/page/profile/profile_page.dart';
import 'package:everesports/language/controller/all_language.dart';
import 'package:everesports/main.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:everesports/widget/common_line_elevated_button.dart';
import 'package:everesports/widget/common_textfield.dart'
    show commonTextfieldbuild;
import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/auth/services/auth_service.dart';

class EnterPassFireBasePage extends StatefulWidget {
  final String userInput;
  const EnterPassFireBasePage({super.key, required this.userInput});

  @override
  State<EnterPassFireBasePage> createState() => _EnterPassFireBasePageState();
}

class _EnterPassFireBasePageState extends State<EnterPassFireBasePage> {
  final TextEditingController _inputController = TextEditingController();
  bool _isInputValid = false;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedInById();
    _inputController.addListener(_validateInput);
  }

  /// Check if user ID is already saved in SharedPreferences
  Future<void> _checkIfLoggedInById() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      // If userId exists, directly navigate to ProfilePage
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => FireBaseProfilePage()),
      );
    }
  }

  void _validateInput() {
    final text = _inputController.text.trim();
    setState(() {
      _isInputValid = text.isNotEmpty;
      _errorText = null;
    });
  }

  Future<void> _handleNext() async {
    if (!_isInputValid) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // Verify password using AuthServiceFireBase
      final isValid = await AuthServiceFireBase.verifyPassword(
        widget.userInput,
        _inputController.text.trim(),
      );

      if (!mounted) return;

      if (isValid) {
        // Fetch user document by email
        final userData = await AuthServiceFireBase.getUserByEmail(
          widget.userInput,
        );

        if (userData != null && userData.containsKey('userId')) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userData['userId']);

          // Navigate to main app
          commonNavigationbuild(context, EverEsports());
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorText = getIncorrectpassword(context);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorText = "Error connecting to database.";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        getEnteryourpassword(context),
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 24 : 28,
                          height: 1.3,
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 20 : 40),

                    // Read-only username/email
                    commonTextfieldbuild(
                      context,
                      "@username",
                      "",
                      TextEditingController(text: widget.userInput),
                      readOnly: true,
                    ),

                    // Password input
                    commonTextfieldbuild(
                      context,
                      getPassword(context),
                      getPassword(context),

                      _inputController,
                    ),

                    if (_errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 6),
                        child: Text(
                          _errorText!,
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),

                    SizedBox(
                      height: isMobile
                          ? MediaQuery.of(context).size.height * 0.4
                          : 40,
                    ),

                    // Buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 80,
                          child: commonLineElevatedButtonbuild(
                            context,
                            getForgotpassword(context),
                            () {
                              // TODO: Implement forgot password logic
                            },
                          ),
                        ),
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
