import 'package:everesports/language/controller/all_language.dart';
import 'package:everesports/widget/language_selector.dart';
import 'package:flutter/material.dart';

class LanguageChangePage extends StatelessWidget {
  const LanguageChangePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(getLanguage(context))),
      body: const SafeArea(child: LanguageSelector()),
    );
  }
}
