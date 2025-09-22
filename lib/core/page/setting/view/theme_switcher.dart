import 'package:everesports/Theme/colors.dart';
import 'package:everesports/Theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SwitchListTile(
      activeColor: mainColor,
      title: Text('Dark Mode', style: Theme.of(context).textTheme.titleMedium),
      value: themeProvider.isDarkMode,
      onChanged: (value) => themeProvider.toggleTheme(),
      secondary: Icon(
        themeProvider.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
        color: mainColor,
      ),
    );
  }
}
