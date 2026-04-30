import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = Typography.englishLike2021;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        background: AppColors.background,
        onBackground: AppColors.onBackground,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceVariant: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
        surfaceTint: AppColors.surfaceTint,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppColors.onSurface),
        displayMedium: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppColors.onSurface),
        displaySmall: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppColors.onSurface),
        headlineLarge: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        headlineSmall: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        titleLarge: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.onSurface),
        titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.onSurface),
        bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.normal, color: AppColors.onSurface),
        bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.normal, color: AppColors.onSurfaceVariant),
        bodySmall: GoogleFonts.inter(fontWeight: FontWeight.normal, color: AppColors.onSurfaceVariant),
        labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.onSurface),
        labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: AppColors.onSurface),
        labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w500, color: AppColors.onSurface),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
