import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/planner_repository.dart';
import '../domain/travel_models.dart';

class PlannerState extends ChangeNotifier {
  PlannerState({List<Trip>? trips, Set<String>? favorites})
    : trips = trips ?? createDemoTrips(),
      favorites = favorites ?? {'lake'},
      _store = null;

  PlannerState._({
    List<Trip>? trips,
    Set<String>? favorites,
    required this._store,
  }) : trips = trips ?? createDemoTrips(),
       favorites = favorites ?? {'lake'};

  final List<Trip> trips;
  final Set<String> favorites;
  final PlannerStore? _store;
  Future<void> _pendingSave = Future.value();

  static Future<PlannerState> open({
    String ownerId = 'guest',
    PlannerStore? store,
  }) async {
    final repository = store ?? PlannerRepository(ownerId: ownerId);
    final saved = await repository.load();
    return PlannerState._(
      trips: saved?.trips,
      favorites: saved?.favorites,
      store: repository,
    );
  }

  void toggleFavorite(String id) {
    if (!favorites.remove(id)) favorites.add(id);
    _save();
    notifyListeners();
  }

  Trip createTrip(
    String title,
    String destination,
    DateTime start,
    DateTime end,
  ) {
    final trip = Trip(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      destination: destination,
      start: start,
      end: end,
      image: 'assets/images/almaty.jpg',
    );
    trips.add(trip);
    _save();
    notifyListeners();
    return trip;
  }

  bool addPlace(Trip trip, Place place, int day) {
    if (trip.visits.any(
      (visit) => visit.place.id == place.id && visit.day == day,
    )) {
      return false;
    }
    trip.visits.add(Visit(place: place, day: day));
    _save();
    notifyListeners();
    return true;
  }

  void removeVisit(Trip trip, Visit visit) {
    trip.visits.remove(visit);
    _save();
    notifyListeners();
  }

  void saveNotes(Trip trip, String notes) {
    trip.notes = notes;
    _save();
    notifyListeners();
  }

  void _save() {
    final store = _store;
    if (store == null) return;
    final snapshot = PlannerSnapshot(
      trips: List<Trip>.from(trips),
      favorites: Set<String>.from(favorites),
    );
    _pendingSave = _pendingSave
        .then((_) => store.save(snapshot))
        .catchError((_) {});
  }

  Future<void> flush() => _pendingSave;
}

class PlannerScope extends InheritedNotifier<PlannerState> {
  const PlannerScope({
    super.key,
    required PlannerState state,
    required super.child,
  }) : super(notifier: state);
  static PlannerState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PlannerScope>()!.notifier!;
}
