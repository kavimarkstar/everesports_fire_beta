import 'package:everesports/core/page/setting/page/theme_change_page.dart';
import 'package:everesports/language/controller/all_language.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:flutter/material.dart';

class ThemeView extends StatelessWidget {
  final VoidCallback? onLogoutSuccess;

  const ThemeView({super.key, this.onLogoutSuccess});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.dark_mode),
      title: Text(
        getDisplay(context),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      onTap: () => commonNavigationbuild(context, ThemeChangePage()),
      trailing: Icon(Icons.arrow_forward_ios, size: 15),
    );
  }
}
