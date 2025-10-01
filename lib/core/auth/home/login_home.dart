import 'package:everesports/core/auth/sign_in/sign_in.dart';
import 'package:everesports/core/auth/sign_up/sign_up.dart';
import 'package:everesports/core/auth/widget/common_text_button_login.dart';
import 'package:everesports/language/controller/all_language.dart';

import 'package:everesports/responsive/responsive.dart';
import 'package:everesports/view/pages/terms_of_service.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:flutter/material.dart';

/// Industry-level full page wrapper for system-wide consistency.
/// This widget can be used to wrap any page to provide a consistent
/// background, branding, and layout structure.
class IndustryLevelFullPage extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Widget? header;
  final Widget? footer;

  const IndustryLevelFullPage({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFFF7F8FA),
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            if (header != null) header!,
            Expanded(child: child),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}

class LoginHomePage extends StatefulWidget {
  const LoginHomePage({super.key});

  @override
  State<LoginHomePage> createState() => _LoginHomePageState();
}

class _LoginHomePageState extends State<LoginHomePage> {
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    // Wrap the original page in the industry-level full page system
    return IndustryLevelFullPage(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Image.asset(
              "assets/logo/ic_launcher.png",
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(width: 32),
        Flexible(child: _buildLoginContent()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 32),
        Image.asset(
          "assets/logo/ic_launcher.png",
          height: 60,
          fit: BoxFit.contain,
        ),
        if (isMobile(context)) SizedBox(height: 10),
        _buildLoginContent(),
      ],
    );
  }

  Widget _buildLoginContent() {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 50,
        vertical: isMobile ? 16 : 32,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              getSeewhatshappeningintheeSportsworldrightnow(context),
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w800,
                fontSize: isMobile
                    ? 25
                    : MediaQuery.of(context).size.width < 1200
                    ? 36
                    : 42,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(
            height: isMobile ? MediaQuery.of(context).size.height * 0.15 : 48,
          ),
          SizedBox(
            width: double.infinity,
            height: isMobile ? 80 : 80,
            child: commonElevatedButtonbuild(
              context,
              getCreateAccount(context),
              () {
                commonNavigationbuild(context, SignUpFireBase());
              },
            ),
          ),
          SizedBox(height: isMobile ? 20 : 32),
          _buildFooterText(),
        ],
      ),
    );
  }

  Widget _buildFooterText() {
    return Center(
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(getBysigningupyouagreetoour(context)),
              commonTextButtonLoginbuild(
                context,
                getTermsofService(context),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TermsOfServicePage(),
                    ),
                  );
                },
              ),
              Text(","),
              commonTextButtonLoginbuild(
                context,
                getPrivacyPolicy(context),
                () {},
              ),
              Text(","),
              Text(getand(context)),
              commonTextButtonLoginbuild(context, getCookieUse(context), () {}),
            ],
          ),
          SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(getHaveanaccountalready(context)),
              commonTextButtonLoginbuild(context, getLogin(context), () {
                commonNavigationbuild(context, SignInFireBase());
              }),
            ],
          ),
        ],
      ),
    );
  }
}
