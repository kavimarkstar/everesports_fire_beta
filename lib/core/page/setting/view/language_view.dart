import 'package:everesports/core/page/setting/page/language_change_page.dart';
import 'package:everesports/language/controller/all_language.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:flutter/material.dart';

class LanguageView extends StatelessWidget {
  final VoidCallback? onLogoutSuccess;

  const LanguageView({super.key, this.onLogoutSuccess});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.language),
      title: Text(
        getLanguage(context),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      onTap: () => commonNavigationbuild(context, LanguageChangePage()),
      trailing: Icon(Icons.arrow_forward_ios, size: 15),
    );
  }
}
