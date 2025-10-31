part of 'package:plex_user/services/domain/service/api/api_import.dart';

class MapApi {
  final Dio _dio = Dio();
  final String _apiKey = "AIzaSyAoVauo0szWOaKCsNW6lqklZCXmZED-7ZU";

  /// 🔹 Fetch autocomplete suggestions from Google Places
  Future<List<Map<String, dynamic>>> fetchAutocomplete(String input, String sessionToken) async {
    const endpoint = "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    final params = {
      'input': input,
      'key': _apiKey,
      'language': 'en',
      'sessiontoken': sessionToken,
      'components': 'country:in', // Optional: restrict to India
    };

    final resp = await _dio.get(endpoint, queryParameters: params);
    if (resp.statusCode == 200 && resp.data['status'] == 'OK') {
      final predictions = resp.data['predictions'] as List;
      return predictions.map((p) => {
        'description': p['description'],
        'place_id': p['place_id'],
      }).toList();
    } else {
      return [];
    }
  }

  /// 🔹 Fetch place details (lat/lng) using place_id
  Future<Map<String, dynamic>?> fetchPlaceDetails(String placeId, String sessionToken) async {
    const endpoint = "https://maps.googleapis.com/maps/api/place/details/json";
    final params = {
      'place_id': placeId,
      'key': _apiKey,
      'language': 'en',
      'fields': 'geometry,formatted_address',
      'sessiontoken': sessionToken,
    };

    final resp = await _dio.get(endpoint, queryParameters: params);
    if (resp.statusCode == 200 && resp.data['status'] == 'OK') {
      final result = resp.data['result'];
      final loc = result['geometry']['location'];
      return {
        'lat': (loc['lat'] as num).toDouble(),
        'lng': (loc['lng'] as num).toDouble(),
        'address': result['formatted_address'],
      };
    }
    return null;
  }

  /// 🔹 Fetch route (Directions API) between origin & destination
  Future<List<Map<String, double>>> fetchRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    const endpoint = "https://maps.googleapis.com/maps/api/directions/json";
    final params = {
      'origin': '$originLat,$originLng',
      'destination': '$destLat,$destLng',
      'key': _apiKey,
      'mode': 'driving',
    };

    final resp = await _dio.get(endpoint, queryParameters: params);

    if (resp.statusCode == 200 && resp.data['status'] == 'OK') {
      final steps = resp.data['routes'][0]['legs'][0]['steps'] as List;
      List<Map<String, double>> polyPoints = [];

      for (var step in steps) {
        final start = step['start_location'];
        polyPoints.add({
          'lat': (start['lat'] as num).toDouble(),
          'lng': (start['lng'] as num).toDouble(),
        });

        final end = step['end_location'];
        polyPoints.add({
          'lat': (end['lat'] as num).toDouble(),
          'lng': (end['lng'] as num).toDouble(),
        });
      }
      return polyPoints;
    }
    return [];
  }


}
