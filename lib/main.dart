import 'package:everesports/core/page/home/view/post_view.dart';
import 'package:everesports/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Import your custom files
import 'package:everesports/Theme/theme_provider.dart';
import 'package:everesports/l10n/app_localizations.dart';
import 'package:everesports/navigation/navigation.dart';
import 'package:everesports/service/language_service.dart';
import 'package:everesports/service/auth/auth_service.dart';
import 'package:everesports/service/notification_service.dart';

// 🔑 Global key to access app state
final GlobalKey<_EverEsportsState> appKey = GlobalKey<_EverEsportsState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    // Initialize essential services
    await LanguageService().initialize();
    await AuthService.init();
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: EverEsports(key: appKey),
    ),
  );
}

class EverEsports extends StatefulWidget {
  const EverEsports({super.key});

  @override
  State<EverEsports> createState() => _EverEsportsState();
}

class _EverEsportsState extends State<EverEsports> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await Provider.of<ThemeProvider>(context, listen: false).loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageService>(
      builder: (context, themeProvider, languageService, child) {
        return MaterialApp(
          title: 'Everesports',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          locale: languageService.currentLocale,
          supportedLocales: LanguageService.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const NavigationPage(),
        );
      },
    );
  }
}
