import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignTokens {
  // Colors
  static const Color primary = Color(0xFF6FCF97);
  static const Color primaryDark = Color(0xFF59A679);
  static const Color onPrimary = Color(0xFF2D2A3A);
  static const Color surfaceLight = Color(0xFFEAEEF0);
  static const Color surfaceDark = Color(0xFF1C2526);
  static const Color onSurfaceLight = Color(0xFF2D2A3A); // For light theme
  static const Color onSurfaceDark = Color(0xFFE0E0E0); // Lighter color for dark theme
  static const Color secondary = Color.fromARGB(255, 235, 96, 177);
  static const Color lightGrey = Color.fromRGBO(218, 227, 238, 1);
  static const Color error = Colors.red;
  static const Color cupertinoScaffoldBackgroundLight = surfaceLight; // For CupertinoPageScaffold
  static const Color cupertinoScaffoldBackgroundDark = surfaceDark;
  static const Color cupertinoNavBarBackgroundLight = surfaceLight; // For CupertinoSliverNavigationBar
  static const Color cupertinoNavBarBackgroundDark = surfaceDark;
  static const Color inputBackgroundColorLight = lightGrey;
  static Color inputBackgroundColorDark = lightGrey.withAlpha(10);

  // Typography Sizes
  static const double pageTitleSize = 26.0;
  static const double pageSubtitleSize = 22.0;
  static const double h1Size = 28.0;
  static const double h2Size = 24.0;
  static const double h3Size = 20.0;
  static const double h4Size = 18.0;
  static const double h5Size = 16.0;
  static const double h6Size = 14.0;
  static const double bodySize = 14.0;
  static const double smallSize = 12.0;

  // Button-Specific Sizes
  static const double buttonSmallHeight = 38.0;
  static const double buttonMediumHeight = 54.0;
  static const double buttonLargeHeight = 64.0;
  static const double buttonSmallFontSize = 14.0;
  static const double buttonMediumFontSize = 16.0;
  static const double buttonLargeFontSize = 18.0;
  static const FontWeight buttonFontWeight = FontWeight.w600;
  static const double buttonTextHeight = 0;
  static const double buttonBorderRadius = 14.0;

  // Font Weights
  static const FontWeight pageTitleWeight = FontWeight.w800;
  static const FontWeight pageSubtitleWeight = FontWeight.w700;
  static const FontWeight headingWeight = FontWeight.w900;
  static const FontWeight headingLessWeight = FontWeight.w600;
  static const FontWeight bodyWeight = FontWeight.w400;
  static const FontWeight smallWeight = FontWeight.w400;

  // Font Heights
  static const double pageTitleHeight = 0.0;
  static const double pageSubtitleHeight = 0.0;
  static const double h1Height = 0.0;
  static const double h2Height = 0.0;
  static const double h3Height = 0.0;
  static const double h4Height = 0.0;
  static const double h5Height = 0.0;
  static const double h6Height = 0.0;
  static const double bodyHeight = 0.0;
  static const double smallHeight = 0.0;

  // Shadows
  static const List<BoxShadow> defaultShadow = [BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 4, spreadRadius: 0)];

  // Centralized Text Styles (without color)
  static final TextStyle basePageTitleStyle = GoogleFonts.plusJakartaSans(
    fontSize: pageTitleSize,
    fontWeight: pageTitleWeight,
    height: pageTitleHeight,
  );

  static final TextStyle basePageSubtitleStyle = GoogleFonts.plusJakartaSans(
    fontSize: pageSubtitleSize,
    fontWeight: pageSubtitleWeight,
    height: pageSubtitleHeight,
  );

  static final TextStyle baseH1Style = GoogleFonts.plusJakartaSans(fontSize: h1Size, fontWeight: headingWeight, height: h1Height);

  static final TextStyle baseH2Style = GoogleFonts.plusJakartaSans(fontSize: h2Size, fontWeight: headingWeight, height: h2Height);

  static final TextStyle baseH3Style = GoogleFonts.plusJakartaSans(fontSize: h3Size, fontWeight: headingWeight, height: h3Height);

  static final TextStyle baseH4Style = GoogleFonts.plusJakartaSans(fontSize: h4Size, fontWeight: headingWeight, height: h4Height);

  static final TextStyle baseH5Style = GoogleFonts.plusJakartaSans(fontSize: h5Size, fontWeight: headingWeight, height: h5Height);

  static final TextStyle baseH6Style = GoogleFonts.plusJakartaSans(fontSize: h6Size, fontWeight: headingLessWeight, height: h6Height);

  static final TextStyle baseBodyStyle = GoogleFonts.plusJakartaSans(fontSize: bodySize, fontWeight: bodyWeight, height: bodyHeight);

  static final TextStyle baseSmallStyle = GoogleFonts.plusJakartaSans(fontSize: smallSize, fontWeight: smallWeight, height: smallHeight);

  // Button-Specific Base Styles
  static final TextStyle baseButtonSmallStyle = GoogleFonts.plusJakartaSans(
    fontSize: buttonSmallFontSize,
    fontWeight: buttonFontWeight,
    height: buttonTextHeight,
  );

  static final TextStyle baseButtonMediumStyle = GoogleFonts.plusJakartaSans(
    fontSize: buttonMediumFontSize,
    fontWeight: buttonFontWeight,
    height: buttonTextHeight,
  );

  static final TextStyle baseButtonLargeStyle = GoogleFonts.plusJakartaSans(
    fontSize: buttonLargeFontSize,
    fontWeight: buttonFontWeight,
    height: buttonTextHeight,
  );
}

// Theme extension to include custom tokens
extension CustomThemeData on ThemeData {
  Color get primaryColor => colorScheme.primary;
  Color get onPrimaryColor => colorScheme.onPrimary;
  Color get surfaceColor => colorScheme.surface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get secondaryColor => colorScheme.secondary;
  Color get errorColor => colorScheme.error;

  // Getter for text styles
  TextStyle get pageTitleStyle => DesignTokens.basePageTitleStyle.copyWith(color: onSurfaceColor);
  TextStyle get pageSubtitleStyle => DesignTokens.basePageSubtitleStyle.copyWith(color: onSurfaceColor);
  TextStyle get h1Style => DesignTokens.baseH1Style.copyWith(color: onSurfaceColor);
  TextStyle get h2Style => DesignTokens.baseH2Style.copyWith(color: onSurfaceColor);
  TextStyle get h3Style => DesignTokens.baseH3Style.copyWith(color: onSurfaceColor);
  TextStyle get h4Style => DesignTokens.baseH4Style.copyWith(color: onSurfaceColor);
  TextStyle get h5Style => DesignTokens.baseH5Style.copyWith(color: onSurfaceColor);
  TextStyle get h6Style => DesignTokens.baseH6Style.copyWith(color: onSurfaceColor);
  TextStyle get bodyStyle => DesignTokens.baseBodyStyle.copyWith(color: onSurfaceColor);
  TextStyle get smallStyle => DesignTokens.baseSmallStyle.copyWith(color: onSurfaceColor);

  // Getter for button text styles
  TextStyle get buttonSmallStyle => DesignTokens.baseButtonSmallStyle.copyWith(color: onSurfaceColor);
  TextStyle get buttonMediumStyle => DesignTokens.baseButtonMediumStyle.copyWith(color: onSurfaceColor);
  TextStyle get buttonLargeStyle => DesignTokens.baseButtonLargeStyle.copyWith(color: onSurfaceColor);
}

// App Themes
class AppThemes {
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: DesignTokens.surfaceLight,
    splashFactory: NoSplash.splashFactory,
    highlightColor: DesignTokens.primary.withAlpha(100),
    splashColor: Colors.transparent,
    primaryColor: DesignTokens.primary,
    primaryColorLight: DesignTokens.primary,
    primaryColorDark: DesignTokens.primary,
    inputDecorationTheme: const InputDecorationTheme(filled: true, fillColor: DesignTokens.inputBackgroundColorLight),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: DesignTokens.surfaceLight,
      selectedItemColor: DesignTokens.primary,
      unselectedItemColor: Colors.grey,
      unselectedIconTheme: const IconThemeData(size: 24, color: Colors.black45),
      selectedIconTheme: const IconThemeData(size: 24, color: DesignTokens.primary),
      selectedLabelStyle: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w800),
      unselectedLabelStyle: const TextStyle(fontSize: 12, color: DesignTokens.primary),
    ),
    colorScheme: const ColorScheme.light(
      primary: DesignTokens.primary,
      onPrimary: DesignTokens.onPrimary,
      surface: DesignTokens.surfaceLight,
      onSurface: DesignTokens.onSurfaceLight,
      secondary: DesignTokens.primary,
      error: DesignTokens.error,
    ),
    iconTheme: const IconThemeData(size: 20, color: DesignTokens.onSurfaceLight),
    actionIconTheme: ActionIconThemeData(backButtonIconBuilder: (BuildContext context) => const Icon(Icons.arrow_back)),
    textTheme: TextTheme(
      displayLarge: DesignTokens.basePageTitleStyle.copyWith(color: DesignTokens.onSurfaceLight),
      displayMedium: DesignTokens.basePageSubtitleStyle.copyWith(color: DesignTokens.onSurfaceLight),
      headlineLarge: DesignTokens.baseH1Style.copyWith(color: DesignTokens.onSurfaceLight),
      headlineMedium: DesignTokens.baseH2Style.copyWith(color: DesignTokens.onSurfaceLight),
      headlineSmall: DesignTokens.baseH3Style.copyWith(color: DesignTokens.onSurfaceLight),
      titleLarge: DesignTokens.baseH4Style.copyWith(color: DesignTokens.onSurfaceLight),
      titleMedium: DesignTokens.baseH5Style.copyWith(color: DesignTokens.onSurfaceLight),
      titleSmall: DesignTokens.baseH6Style.copyWith(color: DesignTokens.onSurfaceLight),
      bodyLarge: DesignTokens.baseBodyStyle.copyWith(color: DesignTokens.onSurfaceLight),
      bodyMedium: DesignTokens.baseSmallStyle.copyWith(color: DesignTokens.onSurfaceLight),
    ),
    appBarTheme: AppBarTheme(
      titleTextStyle: DesignTokens.basePageTitleStyle.copyWith(color: DesignTokens.onSurfaceLight),
      backgroundColor: DesignTokens.surfaceLight,
    ),
    buttonTheme: ButtonThemeData(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.buttonBorderRadius)),
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      scaffoldBackgroundColor: DesignTokens.cupertinoScaffoldBackgroundLight,
      barBackgroundColor: DesignTokens.cupertinoNavBarBackgroundLight,
      primaryColor: DesignTokens.primary,
      textTheme: CupertinoTextThemeData(
        navLargeTitleTextStyle: DesignTokens.basePageTitleStyle.copyWith(color: DesignTokens.onSurfaceLight),
        navTitleTextStyle: DesignTokens.basePageTitleStyle.copyWith(
          color: DesignTokens.onSurfaceLight,
          fontSize: 17.0, // Standard iOS nav bar title size
        ),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: DesignTokens.surfaceDark,
    splashFactory: NoSplash.splashFactory,
    highlightColor: DesignTokens.primary.withAlpha(100),
    splashColor: Colors.transparent,
    primaryColor: DesignTokens.primary,
    primaryColorLight: DesignTokens.primary,
    primaryColorDark: DesignTokens.primary,
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: DesignTokens.inputBackgroundColorDark),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: DesignTokens.surfaceDark,
      selectedItemColor: DesignTokens.primary,
      unselectedItemColor: Colors.grey,
      unselectedIconTheme: const IconThemeData(size: 24, color: Colors.black45),
      selectedIconTheme: const IconThemeData(size: 24, color: DesignTokens.primary),
      selectedLabelStyle: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w800),
      unselectedLabelStyle: const TextStyle(fontSize: 12, color: DesignTokens.primary),
    ),
    colorScheme: const ColorScheme.dark(
      primary: DesignTokens.primary,
      onPrimary: DesignTokens.onPrimary,
      surface: DesignTokens.surfaceDark,
      onSurface: DesignTokens.onSurfaceDark,
      secondary: DesignTokens.primary,
      error: DesignTokens.error,
    ),
    iconTheme: const IconThemeData(size: 20, color: DesignTokens.onSurfaceDark),
    actionIconTheme: ActionIconThemeData(backButtonIconBuilder: (BuildContext context) => const Icon(Icons.arrow_back)),
    textTheme: TextTheme(
      displayLarge: DesignTokens.basePageTitleStyle.copyWith(color: DesignTokens.onSurfaceDark),
      displayMedium: DesignTokens.basePageSubtitleStyle.copyWith(color: DesignTokens.onSurfaceDark),
      headlineLarge: DesignTokens.baseH1Style.copyWith(color: DesignTokens.onSurfaceDark),
      headlineMedium: DesignTokens.baseH2Style.copyWith(color: DesignTokens.onSurfaceDark),
      headlineSmall: DesignTokens.baseH3Style.copyWith(color: DesignTokens.onSurfaceDark),
      titleLarge: DesignTokens.baseH4Style.copyWith(color: DesignTokens.onSurfaceDark),
      titleMedium: DesignTokens.baseH5Style.copyWith(color: DesignTokens.onSurfaceDark),
      titleSmall: DesignTokens.baseH6Style.copyWith(color: DesignTokens.onSurfaceDark),
      bodyLarge: DesignTokens.baseBodyStyle.copyWith(color: DesignTokens.onSurfaceDark),
      bodyMedium: DesignTokens.baseSmallStyle.copyWith(color: DesignTokens.onSurfaceDark),
    ),
    appBarTheme: AppBarTheme(
      titleTextStyle: DesignTokens.basePageTitleStyle.copyWith(color: DesignTokens.onSurfaceDark),
      backgroundColor: DesignTokens.surfaceDark,
    ),
    buttonTheme: ButtonThemeData(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.buttonBorderRadius)),
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      scaffoldBackgroundColor: DesignTokens.cupertinoScaffoldBackgroundDark,
      barBackgroundColor: DesignTokens.cupertinoNavBarBackgroundDark,
      primaryColor: DesignTokens.primary,
      textTheme: CupertinoTextThemeData(
        navLargeTitleTextStyle: DesignTokens.basePageTitleStyle.copyWith(color: DesignTokens.onSurfaceDark),
        navTitleTextStyle: DesignTokens.basePageTitleStyle.copyWith(
          color: DesignTokens.onSurfaceDark,
          fontSize: DesignTokens.h4Size, // Standard iOS nav bar title size
        ),
      ),
    ),
  );
}
