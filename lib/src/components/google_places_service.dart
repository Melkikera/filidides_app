import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GooglePlacesService {
  final String apiKey;
  GooglePlacesService(this.apiKey);

  Future<List<String>> getAutocompleteSuggestions(String input) async {
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
        return List<String>.from(
          data['predictions'].map((p) => p['description']),
        );
      }
    }
    return [];
  }
}
