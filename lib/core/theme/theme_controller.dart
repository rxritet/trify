import 'package:flutter/material.dart';

/// Appearance is independent of navigation and prototype travel data.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController([super.value = ThemeMode.dark]);
  void toggle() =>
      value = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);
  static ThemeController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeScope>()!.notifier!;
}

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = ThemeScope.of(context);
    final isDark = controller.value == ThemeMode.dark;
    return IconButton(
      tooltip: isDark ? 'Включить светлую тему' : 'Включить тёмную тему',
      onPressed: controller.toggle,
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
    );
  }
}
