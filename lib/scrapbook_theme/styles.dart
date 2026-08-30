import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScrapbookColors {
  static const Color creamPaper = Color(0xFFF5E6C8);
  static const Color agedPaper = Color(0xFFE8D5B7);
  static const Color kraftPaper = Color(0xFFC4A47A);
  static const Color darkKraft = Color(0xFF8B6914);

  static const Color washiPink = Color(0xFFE8A0BF);
  static const Color washiMint = Color(0xFF98D8C8);
  static const Color washiYellow = Color(0xFFF4D03F);
  static const Color washiBlue = Color(0xFF85C1E9);

  static const Color washiLilac = Color(0xFFC9A7EB);
  static const Color washiPeach = Color(0xFFF7C5A8);
  static const Color washiCoral = Color(0xFFF1948A);
  static const Color washiSage = Color(0xFFB5D6B2);
  static const Color washiSky = Color(0xFFAED6F1);
  static const Color washiLemon = Color(0xFFF9E79F);

  static const Color stickyYellow = Color(0xFFFDF2A9);
  static const Color receiptWhite = Color(0xFFFAF7F0);
  static const Color indexCard = Color(0xFFF8F0DC);

  static const Color inkBlack = Color(0xFF2C2C2C);
  static const Color inkBrown = Color(0xFF5D4037);
  static const Color polaroid = Color(0xFFFDFBF7);

  // Semantic "ledger ink" — readable on cream paper.
  static const Color owedGreen = Color(0xFF3E7B4F); // money coming back to you
  static const Color oweRed = Color(0xFFB24632); // money you owe
}

class ScrapbookStyles {
  ScrapbookStyles._();

  static TextStyle title({double size = 42, Color? color}) =>
      GoogleFonts.amaticSc(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color ?? ScrapbookColors.inkBrown,
        height: 1.1,
      );

  static TextStyle handwriting({
    double size = 18,
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.caveat(
    fontSize: size,
    fontWeight: weight,
    color: color ?? ScrapbookColors.inkBlack,
    height: 1.4,
  );

  static TextStyle typewriter({double size = 12, Color? color}) =>
      GoogleFonts.specialElite(
        fontSize: size,
        color: color ?? ScrapbookColors.inkBlack.withValues(alpha: 0.8),
        height: 1.3,
      );

  static TextStyle marker({double size = 15, Color? color}) =>
      GoogleFonts.permanentMarker(
        fontSize: size,
        color: color ?? ScrapbookColors.inkBlack,
      );

  static TextStyle body({
    double size = 14,
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.lora(
    fontSize: size,
    color: color ?? ScrapbookColors.inkBlack,
    fontWeight: weight,
    height: 1.5,
  );
}
