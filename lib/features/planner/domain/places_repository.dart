import 'travel_models.dart';

/// Source of places shown in discovery. Firebase will later be used for user
/// data (trips and favourites); public place search stays independent of it.
abstract interface class PlacesRepository {
  Future<List<Place>> search(String query);
}
