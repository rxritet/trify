import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/core/theme/app_theme.dart';
import 'package:trip_planner/core/theme/theme_controller.dart';
import 'package:trip_planner/features/planner/data/demo_places_repository.dart';
import 'package:trip_planner/features/planner/presentation/planner_shell.dart';
import 'package:trip_planner/features/planner/presentation/planner_state.dart';
import 'package:trip_planner/main.dart';

Future<void> start(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    const TrifyApp(placesRepository: DemoPlacesRepository()),
  );
  await tester.pumpAndSettle();
}

ThemeController appearance(WidgetTester tester) => ThemeScope.of(
  tester.element(find.byType(PlannerShell, skipOffstage: false)),
);

/// Compare positions, sizes and clipping radii, independently of palette.
List<Object> geometry(WidgetTester tester) {
  final result = <Object>[];
  for (final element
      in find
          .byWidgetPredicate(
            (widget) =>
                widget is Text ||
                widget is Image ||
                widget is Material ||
                widget is ClipRRect ||
                widget is TextField ||
                widget is NavigationBar ||
                widget is NavigationRail ||
                widget is AppBar,
          )
          .evaluate()) {
    final finder = find.byElementPredicate(
      (candidate) => identical(element, candidate),
    );
    result.add([element.widget.runtimeType.toString(), tester.getRect(finder)]);
    if (element.widget case final ClipRRect clip) result.add(clip.borderRadius);
    if (element.widget case final Material material) {
      final shape = material.shape;
      // Border color belongs to the palette, not the shape's geometry.
      result.add([
        material.borderRadius,
        shape is OutlinedBorder
            ? shape.copyWith(
                side: shape.side.copyWith(color: Colors.transparent),
              )
            : shape,
        material.clipBehavior,
      ]);
    }
  }
  return result;
}

Future<void> verifySwitch(WidgetTester tester) async {
  await tester.pumpAndSettle();
  final original = geometry(tester);
  final controller = appearance(tester);
  for (final mode in [
    ThemeMode.light,
    ThemeMode.dark,
    ThemeMode.light,
    ThemeMode.dark,
  ]) {
    controller.value = mode;
    await tester.pump();
    expect(tester.takeException(), isNull);
    // The very first frame must already have the right page palette.
    final scaffold = tester.element(find.byType(Scaffold).last);
    expect(
      Theme.of(scaffold).brightness,
      mode == ThemeMode.light ? Brightness.light : Brightness.dark,
    );
    expect(
      geometry(tester),
      original,
      reason: 'No layout jump in the first theme frame',
    );
    await tester.pump(const Duration(milliseconds: 16));
    expect(
      geometry(tester),
      original,
      reason: 'No shape morphing during the transition',
    );
    await tester.pumpAndSettle();
    expect(
      geometry(tester),
      original,
      reason: 'Theme switching must not move or reshape content',
    );
    expect(tester.takeException(), isNull);
  }
}

void main() {
  for (final size in [
    const Size(320, 700),
    const Size(390, 844),
    const Size(844, 390),
    const Size(1024, 768),
  ]) {
    testWidgets('theme round trips preserve geometry at $size', (tester) async {
      await start(tester, size);
      for (final section in ['Главная', 'Открывать', 'Поездки', 'Профиль']) {
        await tester.ensureVisible(find.text(section));
        await tester.tap(find.text(section));
        await tester.pumpAndSettle();
        await verifySwitch(tester);
      }
    });
  }

  testWidgets('theme button preserves search and favorites', (tester) async {
    await start(tester, const Size(390, 844));
    await tester.tap(find.byTooltip('Включить светлую тему'));
    await tester.pumpAndSettle();
    expect(appearance(tester).value, ThemeMode.light);
    await tester.tap(find.text('Открывать'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Чарын');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('В избранное'));
    await tester.pumpAndSettle();
    final state = PlannerScope.of(tester.element(find.byType(PlannerShell)));
    await verifySwitch(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Чарын',
    );
    expect(state.favorites, contains('canyon'));
    expect(find.text('Мест: 1'), findsOneWidget);
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(appearance(tester).value, ThemeMode.light);
  });

  testWidgets(
    'trip selection, notes and bottom sheet survive palette changes',
    (tester) async {
      await start(tester, const Size(390, 844));
      await tester.tap(find.text('Поездки'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Выше только горы'));
      await tester.pumpAndSettle();
      await verifySwitch(tester);
      await tester.ensureVisible(find.text('День 3'));
      await tester.tap(find.text('День 3'));
      await tester.pumpAndSettle();
      await verifySwitch(tester);
      expect(find.text('День для новых открытий'), findsOneWidget);
      await tester.ensureVisible(find.text('+ Добавить'));
      await tester.tap(find.text('+ Добавить'));
      await tester.pumpAndSettle();
      await verifySwitch(tester);
      appearance(tester).value = ThemeMode.light;
      await tester.pumpAndSettle();
      expect(
        tester.element(find.byType(BottomSheet)).colors.background,
        AppColors.light.background,
      );
      await tester.tap(find.text('Чарынский каньон').last);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('Чарынский каньон'), findsOneWidget);
      await tester.ensureVisible(find.text('Заметки'));
      await tester.tap(find.text('Заметки'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Редактировать заметки'));
      await tester.tap(find.text('Редактировать заметки'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Термос и билеты');
      await verifySwitch(tester);
      expect(find.text('Термос и билеты'), findsOneWidget);
      await tester.tap(find.text('Сохранить заметки'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.text('Термос и билеты'), findsOneWidget);
    },
  );

  testWidgets('form, calendar, place details and picker keep their geometry', (
    tester,
  ) async {
    await start(tester, const Size(390, 844));
    await tester.tap(find.text('Поездки'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Новая поездка'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Моя поездка');
    await verifySwitch(tester);
    expect(find.text('Моя поездка'), findsOneWidget);
    await tester.ensureVisible(find.text('Выбрать даты'));
    await tester.tap(find.text('Выбрать даты'));
    await tester.pumpAndSettle();
    await verifySwitch(tester);
    // Pop the calendar, then the form; switching must not replace routes.
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Открывать'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Большое Алматинское озеро'));
    await tester.pumpAndSettle();
    await verifySwitch(tester);
    await tester.ensureVisible(find.text('Добавить в поездку'));
    await tester.tap(find.text('Добавить в поездку'));
    await tester.pumpAndSettle();
    await verifySwitch(tester);
    expect(find.text('Добавить в план'), findsOneWidget);
  });

  test('text and accent colors meet contrast requirements in both themes', () {
    double contrast(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return (x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05));
    }

    for (final colors in [AppColors.dark, AppColors.light]) {
      for (final surface in [
        colors.background,
        colors.surface,
        colors.elevated,
      ]) {
        expect(contrast(colors.text, surface), greaterThanOrEqualTo(4.5));
        expect(contrast(colors.muted, surface), greaterThanOrEqualTo(4.5));
        expect(contrast(colors.primary, surface), greaterThanOrEqualTo(4.5));
      }
      expect(
        contrast(colors.onAccent, colors.accent),
        greaterThanOrEqualTo(4.5),
      );
    }
  });
}
