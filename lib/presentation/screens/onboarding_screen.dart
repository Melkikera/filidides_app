import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../src/components/google_places_service.dart';
import '../../src/components/google_location_service.dart';
import '../../src/components/search_suggestions.dart';
import '../../core/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onSignIn});

  final void Function(dynamic firebaseUser) onSignIn;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  // services
  late GooglePlacesService _placesService;
  late GoogleLocationService _locationService;
  // no polyline helper needed for simple preview

  // start
  final TextEditingController _startController = TextEditingController();
  List<Map<String, String>> _startSuggestions = [];
  String? _startPlaceId;
  String? _startDescription;

  // end
  final TextEditingController _endController = TextEditingController();
  List<Map<String, String>> _endSuggestions = [];
  String? _endPlaceId;
  String? _endDescription;

  // preview
  LatLng? _startLatLng;
  LatLng? _endLatLng;

  @override
  void initState() {
    super.initState();
    _placesService = GooglePlacesService(Constants.googleMapsApiKey);
    _locationService = GoogleLocationService(Constants.googleMapsApiKey);
    // no polyline helper needed for simple preview
  }

  Future<void> _searchStart(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _startSuggestions = []);
      return;
    }
    final s = await _placesService.getAutocompleteSuggestions(query);
    setState(() => _startSuggestions = s);
  }

  Future<void> _searchEnd(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _endSuggestions = []);
      return;
    }
    final s = await _placesService.getAutocompleteSuggestions(query);
    setState(() => _endSuggestions = s);
  }

  Future<void> _preparePreview() async {
    // resolve latlngs
    if (_startPlaceId != null && _startPlaceId!.isNotEmpty) {
      _startLatLng =
          await _locationService.getLocationFromPlaceId(_startPlaceId!);
    }
    if (_startLatLng == null && _startDescription != null) {
      _startLatLng = await _locationService.searchLocation(_startDescription!);
    }

    if (_endPlaceId != null && _endPlaceId!.isNotEmpty) {
      _endLatLng = await _locationService.getLocationFromPlaceId(_endPlaceId!);
    }
    if (_endLatLng == null && _endDescription != null) {
      _endLatLng = await _locationService.searchLocation(_endDescription!);
    }
    setState(() {});
  }

  void _nextPage() async {
    if (_pageIndex == 1) {
      // preparing preview
      await _preparePreview();
    }
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void _prevPage() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [
          _buildStartPage(),
          _buildEndPage(),
          _buildPreviewPage(),
        ],
        onPageChanged: (i) => setState(() => _pageIndex = i),
      ),
    );
  }

  Widget _buildStartPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const Text('Étape 1/3',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Lieu de départ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _startController,
            decoration:
                const InputDecoration(labelText: 'Entrez le point de départ'),
            onChanged: _searchStart,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SearchSuggestions(
              showSuggestions: _startSuggestions.isNotEmpty,
              suggestions: _startSuggestions,
              onSuggestionTap: (s) {
                _startDescription = s['description'] ?? '';
                _startPlaceId = s['place_id'];
                _startController.text = _startDescription ?? '';
                setState(() => _startSuggestions = []);
              },
            ),
          ),
          ElevatedButton(
            onPressed: _startDescription == null || _startDescription!.isEmpty
                ? null
                : _nextPage,
            child: const Text('Suivant'),
          ),
        ],
      ),
    );
  }

  Widget _buildEndPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const Text('Étape 2/3',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Lieu d’arrivée',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _endController,
            decoration:
                const InputDecoration(labelText: 'Entrez le point d’arrivée'),
            onChanged: _searchEnd,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SearchSuggestions(
              showSuggestions: _endSuggestions.isNotEmpty,
              suggestions: _endSuggestions,
              onSuggestionTap: (s) {
                _endDescription = s['description'] ?? '';
                _endPlaceId = s['place_id'];
                _endController.text = _endDescription ?? '';
                setState(() => _endSuggestions = []);
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevPage,
                  child: const Text('Retour'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _endDescription == null || _endDescription!.isEmpty
                      ? null
                      : _nextPage,
                  child: const Text('Suivant'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewPage() {
    final markers = <Marker>{};
    if (_startLatLng != null) {
      markers.add(Marker(
          markerId: const MarkerId('start'),
          position: _startLatLng!,
          infoWindow: InfoWindow(title: _startDescription ?? 'Départ')));
    }
    if (_endLatLng != null) {
      markers.add(Marker(
          markerId: const MarkerId('end'),
          position: _endLatLng!,
          infoWindow: InfoWindow(title: _endDescription ?? 'Arrivée')));
    }

    final polylines = <Polyline>{};
    if (_startLatLng != null && _endLatLng != null) {
      polylines.add(Polyline(
          polylineId: const PolylineId('preview'),
          points: [_startLatLng!, _endLatLng!],
          color: Colors.blue,
          width: 4));
    }

    return Column(
      children: [
        Expanded(
          child: _startLatLng == null && _endLatLng == null
              ? const Center(child: Text('Chargement de la carte...'))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _startLatLng ??
                        _endLatLng ??
                        const LatLng(48.8566, 2.3522),
                    zoom: 12,
                  ),
                  markers: markers,
                  polylines: polylines,
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevPage,
                  child: const Text('Retour'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Finish: navigate to the main map, passing selected start/end
                    Navigator.of(context).pushReplacementNamed(
                      '/map',
                      arguments: {
                        'startDescription': _startDescription ?? '',
                        'startPlaceId': _startPlaceId ?? '',
                        'endDescription': _endDescription ?? '',
                        'endPlaceId': _endPlaceId ?? '',
                      },
                    );
                  },
                  child: const Text('Terminer'),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  // nothing else
}
