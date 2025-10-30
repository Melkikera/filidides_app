import 'package:google_maps_flutter/google_maps_flutter.dart';

class Journey {
  final List<LatLng> points;
  final String startLocation;
  final String endLocation;
  final double distance;
  final String duration;
  final double price;

  Journey({
    required this.points,
    required this.startLocation,
    required this.endLocation,
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
          .map((p) => LatLng(p['lat'] as double, p['lng'] as double))
          .toList(),
      startLocation: json['startLocation'] as String,
      endLocation: json['endLocation'] as String,
      distance: json['distance'] as double,
      duration: json['travelTime'] as String,
      price: json['price'] as double,
    );
  }

  // Convert Journey to JSON
  Map<String, dynamic> toJson() {
    return {
      'routePoints':
          points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'startLocation': startLocation,
      'endLocation': endLocation,
      'distance': distance,
      'travelTime': duration,
      'price': price,
    };
  }
}
