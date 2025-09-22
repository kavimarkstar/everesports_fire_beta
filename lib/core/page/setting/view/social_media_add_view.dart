import 'package:everesports/language/controller/all_language.dart';
import 'package:everesports/main.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class SocialMediaAdd extends StatelessWidget {
  final VoidCallback? onLogoutSuccess;

  const SocialMediaAdd({super.key, this.onLogoutSuccess});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Bootstrap.instagram),
      title: Text(
        getAddSocialMedia(context),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      onTap: () => commonNavigationbuild(context, EverEsports()),
      trailing: Icon(Icons.arrow_forward_ios, size: 15),
    );
  }
}
