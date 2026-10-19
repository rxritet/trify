import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/features/planner/data/demo_data.dart';
import 'package:trip_planner/features/planner/data/planner_repository.dart';
import 'package:trip_planner/features/planner/presentation/planner_state.dart';

class MemoryPlannerStore implements PlannerStore {
  PlannerSnapshot? snapshot;

  @override
  Future<PlannerSnapshot?> load() async => snapshot;

  @override
  Future<void> save(PlannerSnapshot value) async {
    snapshot = PlannerSnapshot(
      trips: List.of(value.trips),
      favorites: Set.of(value.favorites),
    );
  }
}

void main() {
  test('a place can occur on different days, but not twice on one day', () {
    final state = PlannerState();
    addTearDown(state.dispose);
    final trip = state.createTrip(
      'Тест',
      'Алматы',
      DateTime(2026, 12, 1),
      DateTime(2026, 12, 3),
    );
    expect(trip.days, 3);
    expect(state.addPlace(trip, demoPlaces.first, 0), isTrue);
    expect(state.addPlace(trip, demoPlaces.first, 0), isFalse);
    expect(state.addPlace(trip, demoPlaces.first, 1), isTrue);
    state.removeVisit(trip, trip.visits.first);
    expect(trip.visits.single.day, 1);
    state.saveNotes(trip, 'Взять термос');
    expect(trip.notes, 'Взять термос');
  });

  test('planning changes are restored from the local store', () async {
    final store = MemoryPlannerStore();
    final state = await PlannerState.open(store: store);
    addTearDown(state.dispose);

    final trip = state.createTrip(
      'Тест сохранения',
      'Караганда',
      DateTime(2026, 12, 1),
      DateTime(2026, 12, 2),
    );
    state.addPlace(trip, demoPlaces.first, 1);
    state.saveNotes(trip, 'Проверить билеты');
    state.toggleFavorite('canyon');
    await state.flush();

    final restored = await PlannerState.open(store: store);
    addTearDown(restored.dispose);
    final restoredTrip = restored.trips.singleWhere(
      (item) => item.id == trip.id,
    );
    expect(restoredTrip.visits.single.place.id, 'lake');
    expect(restoredTrip.notes, 'Проверить билеты');
    expect(restored.favorites, contains('canyon'));
  });
}
