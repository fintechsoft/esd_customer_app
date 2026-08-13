import 'package:esdcustomer/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App-wide theme, palette pulled from the ESD logo (deep maroon + gold).
/// Static fields below are referenced across the app as `AppTheme.primary`
/// etc — kept in sync with the `k`-prefixed constants in constants/app_color.dart
/// so this app's code stays copy-paste compatible with the employee app.
class AppTheme {
  AppTheme._();
  static final AppTheme instance = AppTheme._();

  static const Color primary = kPrimary;
  static const Color primaryDark = kPrimaryDark;
  static const Color primaryLight = kPrimaryLight;
  static const Color accent = kAccent;
  static const Color bg = kAppBgColor;
  static const Color surface = kCardBg;
  static const Color textDark = kDark;
  static const Color textMuted = kLightText;
  static const Color success = kSuccess;
  static const Color danger = kDanger;
  static const Color pending = kWarning;
  static const Color border = kBorder;

  ThemeData themeData() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.jostTextTheme(base.textTheme).apply(
      bodyColor: textDark,
      displayColor: textDark,
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      primaryColor: primary,
      textTheme: textTheme,
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: danger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.jost(
          color: textDark,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.jost(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: primary, width: 1.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.jost(color: textMuted),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 10,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
    );
  }

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
      case 'resolved':
      case 'closed':
        return success;
      case 'pending':
      case 'open':
        return pending;
      case 'in_progress':
        return primaryLight;
      default:
        return textMuted;
    }
  }
}
