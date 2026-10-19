import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/features/planner/data/demo_places_repository.dart';
import 'package:trip_planner/main.dart';

void main() {
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

  for (final size in [
    const Size(320, 700),
    const Size(390, 844),
    const Size(844, 390),
    const Size(1024, 768),
  ]) {
    testWidgets('main sections fit ${size.width} x ${size.height}', (
      tester,
    ) async {
      await start(tester, size);
      expect(find.text('trify'), findsOneWidget);
      expect(tester.takeException(), isNull);
      for (final section in ['Открывать', 'Поездки', 'Профиль', 'Главная']) {
        await tester.ensureVisible(find.text(section));
        await tester.tap(find.text(section));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: section);
      }
    });
  }

  testWidgets('search empty state can be reset', (tester) async {
    await start(tester, const Size(390, 844));
    await tester.tap(find.text('Открывать'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Несуществующее место');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Место не найдено'), findsOneWidget);
    await tester.tap(find.text('Сбросить фильтры'));
    await tester.pumpAndSettle();
    expect(find.text('Мест: 3'), findsOneWidget);
    expect(find.text('Место не найдено'), findsNothing);
  });

  testWidgets('saved places stay consistent across sections', (tester) async {
    await start(tester, const Size(390, 844));
    await tester.tap(find.byTooltip('Сохранённые места'));
    await tester.pumpAndSettle();
    expect(find.text('Мест: 1'), findsOneWidget);
    await tester.tap(find.byTooltip('Убрать из избранного').first);
    await tester.pumpAndSettle();
    expect(find.text('Пока ничего не сохранено'), findsOneWidget);
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('trip has different days and validates an empty form', (
    tester,
  ) async {
    await start(tester, const Size(390, 844));
    await tester.tap(find.text('Поездки'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Выше только горы'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('День 3'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('День 3'));
    await tester.pumpAndSettle();
    expect(find.text('День для новых открытий'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Новая поездка'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Создать поездку'));
    await tester.tap(find.text('Создать поездку'));
    await tester.pumpAndSettle();
    expect(find.text('Придумай название поездки'), findsOneWidget);
    expect(find.text('Укажи направление'), findsOneWidget);
    expect(find.text('Выбери даты поездки'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
