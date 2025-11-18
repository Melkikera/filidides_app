import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleLocationService {
  final String apiKey;
  GoogleLocationService(this.apiKey);

  Future<LatLng?> searchLocation(String query) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      }
    }
    return null;
  }

  /// Fetch place details by place_id and return its LatLng if available.
  Future<LatLng?> getLocationFromPlaceId(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=${Uri.encodeComponent(placeId)}&fields=geometry&key=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['result'] != null) {
        final location = data['result']['geometry']['location'];
        return LatLng((location['lat'] as num).toDouble(),
            (location['lng'] as num).toDouble());
      }
    }
    return null;
  }
}
