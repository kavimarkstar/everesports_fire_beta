import 'package:everesports/core/auth/logout/logout.dart';
import 'package:everesports/core/page/setting/view/kyc.dart';
import 'package:everesports/core/page/setting/view/language_view.dart';
import 'package:everesports/core/page/setting/view/social_media_add_view.dart';
import 'package:everesports/core/page/setting/view/subscription_view.dart';
import 'package:everesports/core/page/setting/view/theme_view.dart';
import 'package:everesports/language/controller/all_language.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Setting")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              settingButtonsbuild(
                context,
                getAccount(context),
                Column(
                  children: [SocialMediaAdd(), SubscriptionView(), KYCView()],
                ),
              ),
              settingButtonsbuild(
                context,
                getContentDisplay(context),
                Column(children: [ThemeView(), LanguageView()]),
              ),
              settingButtonsbuild(
                context,
                getLogin(context),
                Column(children: [LogoutButton()]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget settingButtonsbuild(
    BuildContext context,
    String title,
    Widget content,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontFamily: "Poppins",
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Card(child: content),
      ],
    );
  }
}
