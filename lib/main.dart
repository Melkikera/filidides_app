import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:permission_handler/permission_handler.dart';
import 'src/components/settings_component.dart';
import 'src/components/google_location_service.dart';
import 'src/components/google_places_service.dart';
import 'src/components/list_journey.dart';
import 'src/components/search_tab.dart';
import 'src/components/search_bar.dart' as custom;
import 'src/components/search_suggestions.dart';
import 'src/components/travel_info.dart';
import 'src/components/chat_tab.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'src/components/app_logger.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'domain/repositories/auth_repository.dart';
import 'data/datasources/google_auth_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/entities/user.dart' hide User;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = true;
  User? _currentUser;
  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl(GoogleAuthDataSource());
  }

  void _handleThemeChange(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData && snapshot.data != null) {
            _currentUser = snapshot.data;
            return MapScreen(
              onThemeChanged: _handleThemeChange,
              themeMode: _themeMode,
              user: _currentUser,
            );
          }

          return OnboardingScreen(
            onSignIn: (firebaseUser) {
              // Firebase user is automatically handled by the stream
              AppLogger().info('User signed in: ${firebaseUser.displayName}');
            },
          );
        },
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;
  final ThemeMode themeMode;
  final User? user; // Add this

  const MapScreen({
    Key? key,
    required this.onThemeChanged,
    required this.themeMode,
    this.user, // Add this
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _firstName = 'John';
  String _lastName = 'Doe';
  String _email = 'john.doe@email.com';
  String _avatarUrl = '';
  final TextEditingController _chatInputController = TextEditingController();
  late GoogleLocationService _locationService;
  late GooglePlacesService _placesService;
  List<String> _autocompleteSuggestions = [];
  bool _showSuggestions = false;
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  PolylinePoints polylinePoints = PolylinePoints(
    apiKey: 'AIzaSyDfNy_m1wSjiIHHNQksb54mB3nVddGWOhw',
  );
  String googleApiKey = "AIzaSyDfNy_m1wSjiIHHNQksb54mB3nVddGWOhw";
  String _travelTime = "Calcul en cours...";
  TravelMode _selectedMode = TravelMode.driving;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  List<String> _chatMessages = [
    'Bienvenue dans le chat!',
    'Message reçu via SignalR (simulé)',
    'Autre message...',
  ];
  double _journeyDistance = 0.0;

  @override
  void initState() {
    super.initState();
    checkAndRequestPermission();
    _locationService = GoogleLocationService(googleApiKey);
    _placesService = GooglePlacesService(googleApiKey);
  }

  Future<void> checkAndRequestPermission() async {
    PermissionStatus status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      String markerId = "marker_${_markers.length}";
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(title: "Point ${_markers.length + 1}"),
          onTap: () {
            setState(() {
              _markers.removeWhere(
                (marker) => marker.markerId.value == markerId,
              );
              _updateRoute();
            });
          },
        ),
      );
      _updateRoute();
    });
  }

  // Calculate total distance in kilometers
  double _calculateDistance(List<LatLng> points) {
    if (points.length < 2) return 0.0;
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += _distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  // Haversine formula
  double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth radius in km
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * pi / 180;

  void _updateRoute() async {
    if (_markers.length < 2) return;

    _routePoints.clear();
    List<Marker> markerList = _markers.toList();

    for (int i = 0; i < markerList.length - 1; i++) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(
            markerList[i].position.latitude,
            markerList[i].position.longitude,
          ),
          destination: PointLatLng(
            markerList[i + 1].position.latitude,
            markerList[i + 1].position.longitude,
          ),
          mode: _selectedMode,
        ),
      );

      if (result.points.isNotEmpty) {
        _routePoints.addAll(
          result.points.map((p) => LatLng(p.latitude, p.longitude)),
        );
      }
    }

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blue,
          width: 5,
          points: _routePoints,
        ),
      );
      _journeyDistance = _calculateDistance(_routePoints);
      _calculateTravelTime();
      _recenterMap(); // Recentrer la carte
    });
  }

  void _calculateTravelTime() {
    setState(() {
      _travelTime = "~ ${(_routePoints.length / 5).toStringAsFixed(1)} min";
    });
  }

  // Recentrer la carte pour afficher tous les points
  void _recenterMap() {
    if (_markers.isEmpty) return;

    double minLat = _routePoints.first.latitude;
    double maxLat = _routePoints.first.latitude;
    double minLon = _routePoints.first.longitude;
    double maxLon = _routePoints.first.longitude;

    for (LatLng point in _routePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLon) minLon = point.longitude;
      if (point.longitude > maxLon) maxLon = point.longitude;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLon),
      northeast: LatLng(maxLat, maxLon),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  void _saveJourney() async {
    if (_journeyDistance < 42.5) {
      AppLogger().info(
        'Attempted to save journey with insufficient distance ($_journeyDistance km)',
      );
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Distance insuffisante'),
            content: const Text("Ce n'est pas une course pour Filidides"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }
    // Prepare data to save
    final journeyData = {
      'markers': _markers
          .map(
            (m) => {
              'lat': m.position.latitude,
              'lng': m.position.longitude,
              'title': m.infoWindow.title,
            },
          )
          .toList(),
      'routePoints': _routePoints
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
      'travelTime': _travelTime,
      'mode': _selectedMode.toString(),
      'distance': _journeyDistance,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Save to file (local storage)
    try {
      final directory = await getDownloadsDirectory();
      final file = File(
        '${directory?.path}/journey_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonEncode(journeyData));
      AppLogger().info(
        'Journey saved: distance=$_journeyDistance, time=$_travelTime',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journey saved successfully!')),
        );
      }
    } catch (e) {
      AppLogger().error('Error saving journey: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving journey: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedIndex == 0
            ? const Text("Planificateur d'itinéraire")
            : _selectedIndex == 1
            ? const Text("List")
            : _selectedIndex == 2
            ? const Text("Messages")
            : _selectedIndex == 3
            ? const Text("Mes paramêtres utilisateur")
            : null,
        actions: _selectedIndex == 0
            ? [
                DropdownButton<TravelMode>(
                  value: _selectedMode,
                  onChanged: (TravelMode? mode) {
                    setState(() {
                      _selectedMode = mode!;
                      _updateRoute();
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                      value: TravelMode.driving,
                      child: Text("Voiture"),
                    ),
                    DropdownMenuItem(
                      value: TravelMode.walking,
                      child: Text("Marche"),
                    ),
                    DropdownMenuItem(
                      value: TravelMode.transit,
                      child: Text("Transport"),
                    ),
                    DropdownMenuItem(
                      value: TravelMode.bicycling,
                      child: Text("Vélo"),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: _buildTabBody(),
      floatingActionButton: _selectedIndex == 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'clear',
                  onPressed: () {
                    setState(() {
                      _markers.clear();
                      _polylines.clear();
                      _routePoints.clear();
                      _travelTime = "Calcul en cours...";
                    });
                  },
                  child: const Icon(Icons.delete),
                  tooltip: 'Clear',
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'save',
                  onPressed: _saveJourney,
                  child: const Icon(Icons.save),
                  tooltip: 'Save journey',
                ),
              ],
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.6),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 28),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt, size: 28),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 28),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined, size: 28),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBody() {
    if (_selectedIndex == 0) {
      return SearchTab(
        googleMap: GoogleMap(
          onMapCreated: (controller) => mapController = controller,
          initialCameraPosition: const CameraPosition(
            target: LatLng(48.8566, 2.3522),
            zoom: 12.0,
          ),
          markers: _markers,
          polylines: _polylines,
          onTap: _onMapTap,
        ),
        searchBar: custom.SearchBar(
          controller: _searchController,
          onChanged: (value) async {
            if (value.trim().isEmpty) {
              setState(() {
                _autocompleteSuggestions = [];
                _showSuggestions = false;
              });
              return;
            }
            final suggestions = await _placesService.getAutocompleteSuggestions(
              value,
            );
            setState(() {
              _autocompleteSuggestions = suggestions;
              _showSuggestions = suggestions.isNotEmpty;
            });
          },
          onSubmitted: (value) async {
            if (value.trim().isEmpty) return;
            final LatLng? location = await _locationService.searchLocation(
              value,
            );
            if (location != null) {
              setState(() {
                String markerId = "search_location";
                _markers.add(
                  Marker(
                    markerId: MarkerId(markerId),
                    position: location,
                    infoWindow: InfoWindow(title: value),
                  ),
                );
                mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(location, 15),
                );
                _showSuggestions = false;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lieu non trouvé: $value')),
              );
            }
          },
        ),
        suggestions: SearchSuggestions(
          showSuggestions: _showSuggestions,
          suggestions: _autocompleteSuggestions,
          onSuggestionTap: (suggestion) async {
            _searchController.text = suggestion;
            setState(() {
              _showSuggestions = false;
            });
            final LatLng? location = await _locationService.searchLocation(
              suggestion,
            );
            if (location != null) {
              setState(() {
                String markerId = "search_location";
                _markers.add(
                  Marker(
                    markerId: MarkerId(markerId),
                    position: location,
                    infoWindow: InfoWindow(title: suggestion),
                  ),
                );
                mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(location, 15),
                );
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lieu non trouvé: $suggestion')),
              );
            }
          },
        ),
        travelInfo: TravelInfo(
          travelTime: _travelTime,
          journeyDistance: _journeyDistance,
        ),
      );
    } else if (_selectedIndex == 1) {
      return ListJourney(steps: exampleSteps);
    } else if (_selectedIndex == 2) {
      return ChatTab(
        messages: _chatMessages,
        inputController: _chatInputController,
        onSend: (text) {
          setState(() {
            _chatMessages.add(text);
            _chatInputController.clear();
          });
        },
      );
    } else {
      return SettingsComponent(
        firstName: _firstName,
        lastName: _lastName,
        email: _email,
        avatarUrl: _avatarUrl,
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
        onProfileUpdated: (profile) {
          setState(() {
            _firstName = profile['firstName'] ?? _firstName;
            _lastName = profile['lastName'] ?? _lastName;
            _email = profile['email'] ?? _email;
            _avatarUrl = profile['avatarUrl'] ?? _avatarUrl;
          });
        },
      );
    }
  }
}
