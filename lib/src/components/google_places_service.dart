import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GooglePlacesService {
  final String apiKey;
  GooglePlacesService(this.apiKey);

  /// Returns a list of maps with keys: 'description' and 'place_id'
  Future<List<Map<String, String>>> getAutocompleteSuggestions(
      String input) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$apiKey',
    );
    if (kDebugMode) {
      print('URL: $url');
    }
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        return List<Map<String, String>>.from(
          data['predictions'].map((p) => {
                'description': p['description'] as String,
                'place_id': p['place_id'] as String,
              }),
        );
      }
    }
    return [];
  }
}
