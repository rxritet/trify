import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Semantic colors. Geometry is shared by both themes.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.elevated,
    required this.line,
    required this.primary,
    required this.text,
    required this.muted,
  });
  final Color background, surface, elevated, line, primary, text, muted;
  Color get accent => const Color(0xFFD2F880);
  Color get onAccent => const Color(0xFF111413);
  Color get photoScrim => const Color(0xC7111413);
  Color get onPhoto => const Color(0xFFF4F5EF);

  static const dark = AppColors(
    background: Color(0xFF111413),
    surface: Color(0xFF1C201E),
    elevated: Color(0xFF272D29),
    line: Color(0xFF343B35),
    primary: Color(0xFFD2F880),
    text: Color(0xFFF4F5EF),
    muted: Color(0xFFA3ADA5),
  );
  static const light = AppColors(
    background: Color(0xFFF5F6F0),
    surface: Color(0xFFFFFFFF),
    elevated: Color(0xFFE9EDDF),
    line: Color(0xFFCDD3C6),
    primary: Color(0xFF3D611B),
    text: Color(0xFF182019),
    muted: Color(0xFF596454),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? elevated,
    Color? line,
    Color? primary,
    Color? text,
    Color? muted,
  }) => AppColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    elevated: elevated ?? this.elevated,
    line: line ?? this.line,
    primary: primary ?? this.primary,
    text: text ?? this.text,
    muted: muted ?? this.muted,
  );

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
      line: Color.lerp(line, other.line, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

abstract final class AppTheme {
  static final dark = _build(Brightness.dark, AppColors.dark);
  static final light = _build(Brightness.light, AppColors.light);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final isDark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF6F8B42),
          brightness: brightness,
        ).copyWith(
          primary: colors.primary,
          onPrimary: isDark ? colors.onAccent : Colors.white,
          primaryContainer: colors.accent,
          onPrimaryContainer: colors.onAccent,
          secondary: colors.primary,
          onSecondary: isDark ? colors.onAccent : Colors.white,
          secondaryContainer: colors.elevated,
          onSecondaryContainer: colors.text,
          surface: colors.surface,
          onSurface: colors.text,
          onSurfaceVariant: colors.muted,
          surfaceContainerLowest: colors.background,
          surfaceContainerLow: colors.surface,
          surfaceContainer: colors.surface,
          surfaceContainerHigh: colors.elevated,
          surfaceContainerHighest: colors.elevated,
          outline: colors.line,
          outlineVariant: colors.line,
          surfaceTint: Colors.transparent,
        );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      extensions: [colors],
      splashFactory: InkRipple.splashFactory,
    );
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    return base.copyWith(
      // Font metrics, shapes and padding must never depend on brightness.
      textTheme: base.textTheme
          .copyWith(
            headlineLarge: const TextStyle(
              fontSize: 36,
              height: 1.1,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.4,
            ),
            headlineMedium: const TextStyle(
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w700,
              letterSpacing: -.8,
            ),
            titleLarge: const TextStyle(
              fontSize: 21,
              height: 1.25,
              fontWeight: FontWeight.w600,
              letterSpacing: -.4,
            ),
            titleMedium: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            bodyMedium: const TextStyle(fontSize: 14, height: 1.5),
            bodySmall: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: colors.muted,
            ),
          )
          .apply(bodyColor: colors.text, displayColor: colors.text),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      dividerTheme: DividerThemeData(color: colors.line, thickness: 1),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.onAccent,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: rounded,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(48, 50),
          shape: rounded,
          side: BorderSide(color: colors.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary),
        ),
        hintStyle: TextStyle(color: colors.muted),
        labelStyle: TextStyle(color: colors.muted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        selectedColor: colors.accent,
        secondarySelectedColor: colors.accent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        pressElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: colors.line),
        labelStyle: TextStyle(color: colors.text),
        secondaryLabelStyle: TextStyle(color: colors.onAccent),
        checkmarkColor: colors.onAccent,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? colors.elevated
                : colors.surface,
          ),
          foregroundColor: WidgetStatePropertyAll(colors.text),
          side: WidgetStatePropertyAll(BorderSide(color: colors.line)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.background,
        indicatorColor: colors.elevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.text,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        unselectedIconTheme: IconThemeData(color: colors.text),
        unselectedLabelTextStyle: TextStyle(color: colors.text, fontSize: 12),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: colors.muted,
        modalBarrierColor: const Color(0x80000000),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      datePickerTheme: DatePickerThemeData(
        // Keep the Russian range labels inside narrow mobile headers.
        rangePickerHeaderHeadlineStyle: const TextStyle(
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        rangePickerBackgroundColor: colors.background,
        rangePickerSurfaceTintColor: Colors.transparent,
        headerBackgroundColor: colors.elevated,
        headerForegroundColor: colors.text,
        rangePickerHeaderBackgroundColor: colors.elevated,
        rangePickerHeaderForegroundColor: colors.text,
        rangeSelectionBackgroundColor: colors.elevated,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: rounded,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.elevated,
        contentTextStyle: TextStyle(color: colors.text),
      ),
    );
  }
}
