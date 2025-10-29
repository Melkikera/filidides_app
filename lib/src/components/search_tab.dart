import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchTab extends StatelessWidget {
  final GoogleMap googleMap;
  final Widget searchBar;
  final Widget suggestions;
  final Widget travelInfo;

  const SearchTab({
    Key? key,
    required this.googleMap,
    required this.searchBar,
    required this.suggestions,
    required this.travelInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        googleMap,
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchBar,
              suggestions,
              const SizedBox(height: 10),
              travelInfo,
            ],
          ),
        ),
      ],
    );
  }
}
