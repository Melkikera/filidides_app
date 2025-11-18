import 'package:google_maps_flutter/google_maps_flutter.dart';

class Journey {
  final List<LatLng> points;
  final String startLocation;
  final String? startPlaceId;
  final String endLocation;
  final String? endPlaceId;
  final double distance;
  final String duration;
  final double price;

  Journey({
    required this.points,
    required this.startLocation,
    this.startPlaceId,
    required this.endLocation,
    this.endPlaceId,
    required this.distance,
    required this.duration,
    required this.price,
  });

  static double calculatePrice(double distance) {
    if (distance <= 42.0) {
      return 100.0;
    }
    return 100.0 + ((distance - 42.0) * 10.0);
  }

  // Convenience method to create Journey from JSON
  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      points: (json['routePoints'] as List)
          .map((p) => LatLng(
              (p['lat'] as num).toDouble(), (p['lng'] as num).toDouble()))
          .toList(),
      startLocation: json['startLocation'] as String,
      startPlaceId:
          json['start_place_id'] != null && json['start_place_id'] != ''
              ? json['start_place_id'] as String
              : null,
      endLocation: json['endLocation'] as String,
      endPlaceId: json['end_place_id'] != null && json['end_place_id'] != ''
          ? json['end_place_id'] as String
          : null,
      distance: (json['distance'] as num).toDouble(),
      duration: json['travelTime'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  // Convert Journey to JSON
  Map<String, dynamic> toJson() {
    return {
      'routePoints':
          points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'startLocation': startLocation,
      'start_place_id': startPlaceId ?? '',
      'endLocation': endLocation,
      'end_place_id': endPlaceId ?? '',
      'distance': distance,
      'travelTime': duration,
      'price': price,
    };
  }
}
