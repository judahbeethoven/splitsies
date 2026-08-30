import 'package:flutter/material.dart';
import 'package:splitsies/scrapbook_theme/styles.dart';
import 'package:splitsies/screens/home.dart';
import 'package:splitsies/services/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splitsies',
      debugShowCheckedModeBanner: false,
      theme: _scrapbookTheme(),
      home: const HomeScreen(),
    );
  }
}

ThemeData _scrapbookTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ScrapbookColors.kraftPaper,
      primary: ScrapbookColors.inkBrown,
      surface: ScrapbookColors.creamPaper,
    ),
    scaffoldBackgroundColor: ScrapbookColors.creamPaper,
  );

  return base.copyWith(
    splashColor: ScrapbookColors.washiYellow.withValues(alpha: 0.3),
    highlightColor: ScrapbookColors.washiYellow.withValues(alpha: 0.15),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: ScrapbookColors.inkBrown,
      selectionHandleColor: ScrapbookColors.inkBrown,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ScrapbookColors.inkBrown,
      contentTextStyle: ScrapbookStyles.body(color: Colors.white),
      actionTextColor: ScrapbookColors.washiYellow,
    ),
  );
}
