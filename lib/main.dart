import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:nobochitro/firebase_options.dart';
import 'package:nobochitro/screens/splash_screen.dart';
import 'package:nobochitro/support_hub/support_hub.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  // flutter engine load
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://whdyselehlvbshnoezgz.supabase.co",
    anonKey: "sb_publishable_J2XyM8ebvtPM7la-GHbZjg_0aEVlOT0",
  );
  // firebase start
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // await DatabaseHelper.insertDemoPhotographers();
  // await DatabaseHelper.insertDemoPackages();
  // await DatabaseHelper.instance.insertAddons();
  await DatabaseHelper.insertDemoCampaignOnStart();

  runApp(const PhotographyApp());
}

class PhotographyApp extends StatefulWidget {
  const PhotographyApp({Key? key}) : super(key: key);

  @override
  State<PhotographyApp> createState() => _PhotographyAppState();
}

class _PhotographyAppState extends State<PhotographyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  // support hub
  bool _showSupportHub = false;

  void toggleTheme(bool isOn) {
    setState(() {
      _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Splash screen
  void onAppReady() {
    setState(() {
      _showSupportHub = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Nobochitro',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF008080),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD4AF37),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,

      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryAccent = isDark
            ? const Color(0xFFD4AF37)
            : const Color(0xFF008080);

        return Scaffold(
          body: child,
          // কেবল মাত্র যখন _showSupportHub true হবে, তখনই এটি দেখাবে
          floatingActionButton: _showSupportHub
              ? SupportHub(primaryAccent: primaryAccent)
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },

      // SplashScreen এ onAppReady
      home: SplashScreen(onThemeChanged: toggleTheme, onAppReady: onAppReady),
    );
  }
}
