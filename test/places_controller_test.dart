import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/features/planner/data/demo_places_repository.dart';
import 'package:trip_planner/features/planner/presentation/places_controller.dart';

void main() {
  test(
    'search exposes data and restores the visual fallback after reset',
    () async {
      final controller = PlacesController(const DemoPlacesRepository());
      addTearDown(controller.dispose);

      await controller.search('Чарын');
      expect(controller.status, PlacesLoadState.success);
      expect(controller.places.single.id, 'canyon');

      await controller.search('нет такого места');
      expect(controller.status, PlacesLoadState.empty);

      await controller.search('');
      expect(controller.status, PlacesLoadState.initial);
      expect(controller.places, hasLength(3));
    },
  );
}
