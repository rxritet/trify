import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../domain/places_repository.dart';
import '../domain/travel_models.dart';

enum PlacesLoadState { initial, loading, success, empty, failure }

class PlacesController extends ChangeNotifier {
  PlacesController(this._repository) : places = demoPlaces;

  final PlacesRepository _repository;
  List<Place> places;
  PlacesLoadState status = PlacesLoadState.initial;
  String query = '';
  String? errorMessage;
  int _requestId = 0;

  Future<void> search(String value) async {
    query = value.trim();
    final request = ++_requestId;
    if (query.isEmpty) {
      places = demoPlaces;
      status = PlacesLoadState.initial;
      errorMessage = null;
      notifyListeners();
      return;
    }
    status = PlacesLoadState.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final found = await _repository.search(query);
      if (request != _requestId) return;
      places = found;
      status = found.isEmpty ? PlacesLoadState.empty : PlacesLoadState.success;
    } on Exception catch (error) {
      if (request != _requestId) return;
      places = const [];
      status = PlacesLoadState.failure;
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }
}

class PlacesScope extends InheritedNotifier<PlacesController> {
  const PlacesScope({
    super.key,
    required PlacesController controller,
    required super.child,
  }) : super(notifier: controller);

  static PlacesController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PlacesScope>()!.notifier!;
}
