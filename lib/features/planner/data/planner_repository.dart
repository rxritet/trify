import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/travel_models.dart';

abstract interface class PlannerStore {
  Future<PlannerSnapshot?> load();
  Future<void> save(PlannerSnapshot snapshot);
}

class PlannerSnapshot {
  const PlannerSnapshot({required this.trips, required this.favorites});

  final List<Trip> trips;
  final Set<String> favorites;
}

/// Persists the local planning state independently from the UI.
class PlannerRepository implements PlannerStore {
  PlannerRepository({
    required String ownerId,
    SharedPreferencesAsync? preferences,
  }) : _storageKey = 'trify_planner_v2_$ownerId',
       _preferences = preferences ?? SharedPreferencesAsync();

  final String _storageKey;
  final SharedPreferencesAsync _preferences;

  @override
  Future<PlannerSnapshot?> load() async {
    final raw = await _preferences.getString(_storageKey);
    if (raw == null) return null;
    try {
      return snapshotFromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Future<void> save(PlannerSnapshot snapshot) =>
      _preferences.setString(_storageKey, jsonEncode(snapshotToJson(snapshot)));

  static Map<String, Object?> snapshotToJson(PlannerSnapshot snapshot) => {
    'trips': snapshot.trips.map(_tripToJson).toList(growable: false),
    'favorites': snapshot.favorites.toList()..sort(),
  };

  static PlannerSnapshot snapshotFromJson(Map<String, dynamic> value) {
    final trips = (value['trips'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_tripFromJson)
        .toList(growable: false);
    final favorites = (value['favorites'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toSet();
    return PlannerSnapshot(trips: trips, favorites: favorites);
  }

  static Map<String, Object?> _tripToJson(Trip trip) => {
    'id': trip.id,
    'title': trip.title,
    'destination': trip.destination,
    'start': trip.start.toIso8601String(),
    'end': trip.end.toIso8601String(),
    'image': trip.image,
    'notes': trip.notes,
    'visits': trip.visits.map(_visitToJson).toList(growable: false),
  };

  static Trip _tripFromJson(Map<String, dynamic> value) => Trip(
    id: value['id'] as String,
    title: value['title'] as String,
    destination: value['destination'] as String,
    start: DateTime.parse(value['start'] as String),
    end: DateTime.parse(value['end'] as String),
    image: value['image'] as String,
    notes: value['notes'] as String? ?? '',
    visits: (value['visits'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_visitFromJson)
        .toList(growable: false),
  );

  static Map<String, Object?> _visitToJson(Visit visit) => {
    'day': visit.day,
    'time': visit.time,
    'place': _placeToJson(visit.place),
  };

  static Visit _visitFromJson(Map<String, dynamic> value) => Visit(
    day: value['day'] as int,
    time: value['time'] as String? ?? '10:00',
    place: _placeFromJson(value['place'] as Map<String, dynamic>),
  );

  static Map<String, String> _placeToJson(Place place) => {
    'id': place.id,
    'name': place.name,
    'region': place.region,
    'category': place.category,
    'image': place.image,
    'description': place.description,
    'duration': place.duration,
  };

  static Place _placeFromJson(Map<String, dynamic> value) => Place(
    id: value['id'] as String,
    name: value['name'] as String,
    region: value['region'] as String,
    category: value['category'] as String,
    image: value['image'] as String,
    description: value['description'] as String,
    duration: value['duration'] as String,
  );
}
