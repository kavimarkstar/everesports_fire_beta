import 'package:flutter/material.dart';
import 'package:everesports/Theme/colors.dart'; // your colors file

class PasswordFieldWidget extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const PasswordFieldWidget({
    Key? key,
    required this.passwordController,
    required this.confirmPasswordController,
  }) : super(key: key);

  @override
  State<PasswordFieldWidget> createState() => _PasswordFieldWidgetState();
}

class _PasswordFieldWidgetState extends State<PasswordFieldWidget> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _passwordError;
  String? _confirmPasswordError;

  // Password strength regex: min 8 chars, uppercase, lowercase, digit, special char
  final RegExp strongPasswordRegExp = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
  );

  void _validatePassword() {
    final password = widget.passwordController.text;
    final confirmPassword = widget.confirmPasswordController.text;

    setState(() {
      // Check password strength
      if (!strongPasswordRegExp.hasMatch(password)) {
        _passwordError =
            "Password must be at least 8 characters and include uppercase, lowercase, number & special character";
      } else {
        _passwordError = null;
      }

      // Check passwords match
      if (confirmPassword.isNotEmpty && password != confirmPassword) {
        _confirmPasswordError = "Passwords do not match";
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to validate on text change
    widget.passwordController.addListener(_validatePassword);
    widget.confirmPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_validatePassword);
    widget.confirmPasswordController.removeListener(_validatePassword);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: TextField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: mainColor),
              hintText: 'Enter your password',
              hintStyle: TextStyle(color: Colors.grey),
              errorText: _passwordError,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: mainColor, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Colors.grey, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: mainColor, width: 2),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: isDarkMode ? mainWhiteColor : mainBlackColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            style: TextStyle(
              fontSize: 17,
              color: isDarkMode ? mainWhiteColor : mainBlackColor,
            ),
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: TextField(
            controller: widget.confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              labelStyle: TextStyle(color: mainColor),
              hintText: 'Re-enter your password',
              hintStyle: TextStyle(color: Colors.grey),
              errorText: _confirmPasswordError,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: mainColor, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Colors.grey, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: mainColor, width: 2),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: isDarkMode ? mainWhiteColor : mainBlackColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),
            style: TextStyle(
              fontSize: 17,
              color: isDarkMode ? mainWhiteColor : mainBlackColor,
            ),
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
          ),
        ),
      ],
    );
  }
}
