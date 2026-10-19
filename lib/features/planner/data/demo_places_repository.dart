import '../domain/places_repository.dart';
import '../domain/travel_models.dart';
import 'demo_data.dart';

/// Deterministic repository for widget tests and offline visual previews.
class DemoPlacesRepository implements PlacesRepository {
  const DemoPlacesRepository();

  @override
  Future<List<Place>> search(String query) async {
    final normalized = query.trim().toLowerCase();
    return demoPlaces
        .where(
          (place) =>
              normalized.isEmpty ||
              '${place.name} ${place.region} ${place.category}'
                  .toLowerCase()
                  .contains(normalized),
        )
        .toList(growable: false);
  }
}
