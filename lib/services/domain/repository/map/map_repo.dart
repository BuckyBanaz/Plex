part of 'package:plex_user/services/domain/repository/repository_imports.dart';

class MapRepository {
  final MapApi _mapApi = MapApi();

  /// Get autocomplete suggestions
  Future<List<Map<String, dynamic>>> getSuggestions(String input, String sessionToken) async {
    try {
      return await _mapApi.fetchAutocomplete(input, sessionToken);
    } catch (e) {
      debugPrint("❌ Error fetching suggestions: $e");
      return [];
    }
  }

  /// Get place details with lat/lng
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId, String sessionToken) async {
    try {
      return await _mapApi.fetchPlaceDetails(placeId, sessionToken);
    } catch (e) {
      debugPrint("❌ Error fetching place details: $e");
      return null;
    }
  }
}
