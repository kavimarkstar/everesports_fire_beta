import 'package:everesports/core/page/setting/view/theme_switcher.dart';
import 'package:everesports/language/controller/all_language.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everesports/Theme/theme_provider.dart';

class ThemeChangePage extends StatelessWidget {
  const ThemeChangePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          appBar: AppBar(
            title: Text(getDisplay(context)),
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            foregroundColor: isDark ? Colors.white : Colors.black,
          ),
          backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Card(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Theme(
                              data: ThemeData.light(),
                              child: const MobilePhonePreview(
                                isDark: false,
                                label: "Light Theme",
                                value: false,
                              ),
                            ),

                            Theme(
                              data: ThemeData.dark(),
                              child: const MobilePhonePreview(
                                isDark: true,
                                label: "Dark Theme",
                                value: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Card(child: ThemeSwitcher()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MobilePhonePreview extends StatelessWidget {
  final bool isDark;
  final String label;
  final bool value;

  const MobilePhonePreview({
    super.key,
    required this.isDark,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context, listen: false);
    final color = isDark ? Colors.grey[700] : Colors.grey[300];
    final bgColor = isDark ? Colors.grey[900] : Colors.white;

    return Card(
      elevation: 2,
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 5,
              height: MediaQuery.of(context).size.height / 15,
              color: color,
              child: Center(
                child: Icon(
                  Icons.phone_android,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            SizedBox(height: 4),
            for (int i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width / 5,
                  height: 5,
                  color: color,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 16,
                    height: 40,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
