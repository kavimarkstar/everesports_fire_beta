import 'package:everesports/service/language_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageSelector extends StatelessWidget {
  final bool showTitle;
  final EdgeInsetsGeometry? padding;

  const LanguageSelector({super.key, this.showTitle = true, this.padding});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        final currentLanguage = languageService.currentLanguageCode;

        return Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTitle) ...[
                const Text(
                  'Select Language',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
              ],

              // English Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    languageService.setLocale(const Locale('en'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentLanguage == 'en'
                        ? Colors.blue
                        : Colors.grey[300],
                    foregroundColor: currentLanguage == 'en'
                        ? Colors.white
                        : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('English', style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 12),

              // Sinhala Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    languageService.setLocale(const Locale('si'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentLanguage == 'si'
                        ? Colors.blue
                        : Colors.grey[300],
                    foregroundColor: currentLanguage == 'si'
                        ? Colors.white
                        : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('සිංහල', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
