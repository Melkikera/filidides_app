import 'package:flutter/material.dart';

class TravelInfo extends StatelessWidget {
  final String travelTime;
  final double journeyDistance;

  const TravelInfo({
    Key? key,
    required this.travelTime,
    required this.journeyDistance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Text(
        "Temps estimé: $travelTime\nDistance: ${journeyDistance.toStringAsFixed(2)} km",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
