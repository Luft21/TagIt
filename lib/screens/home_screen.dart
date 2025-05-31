import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    as places_sdk;
import 'package:geolocator/geolocator.dart';
import 'package:tag_it/screens/profile_screen.dart';
import '../widgets/navbar_view.dart';

const kGoogleApiKey = 'AIzaSyDvbiq-Uwemy8QMtkLvtuheSxCqkq1xZ-U';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late places_sdk.FlutterGooglePlacesSdk _places;
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final TextEditingController _searchController = TextEditingController();
  List<places_sdk.AutocompletePrediction> _predictions = [];
  Timer? _debounce;

  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _places = places_sdk.FlutterGooglePlacesSdk(kGoogleApiKey);
    _initLocation();
    _searchController.addListener(_onSearchChanged);

    _pages = [
      // HOME PAGE
      _buildMapContent(),
      // PAGE KONTRIBUSI
      const Center(child: Text('Ini adalah Halaman Kontribusi')),
      // SAVED PAGE
      const Center(child: Text('Ini adalah Halaman Disimpan')),
      // PROFILE PAGE
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final input = _searchController.text;
      if (input.isEmpty) {
        setState(() => _predictions = []);
        return;
      }
      final result = await _places.findAutocompletePredictions(input);
      setState(() {
        _predictions = result.predictions;
      });
    });
  }

  Future<void> _onSelectPrediction(
    places_sdk.AutocompletePrediction prediction,
  ) async {
    final placeId = prediction.placeId;

    final details = await _places.fetchPlace(
      placeId,
      fields: [places_sdk.PlaceField.Location],
    );

    final lat = details.place?.latLng?.lat;
    final lng = details.place?.latLng?.lng;
    if (lat != null && lng != null) {
      final newPos = LatLng(lat, lng);
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newPos, zoom: 15),
        ),
      );
      _searchController.removeListener(_onSearchChanged);
      setState(() {
        _searchController.text = prediction.fullText;
        _predictions = [];
      });
      _searchController.addListener(_onSearchChanged);
    }
  }

  Widget _buildMapContent() {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition!,
            zoom: 15,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onMapCreated: (controller) {
            _mapController = controller;
          },
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari lokasi...',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _predictions = [];
                                  });
                                },
                              )
                              : null,
                    ),
                  ),
                ),
                if (_predictions.isNotEmpty)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: _predictions.length,
                        itemBuilder: (context, index) {
                          final pred = _predictions[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(pred.fullText),
                            onTap: () => _onSelectPrediction(pred),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Peta TagIt'
              : _selectedIndex == 1
              ? 'Kontribusi'
              : _selectedIndex == 2
              ? 'Disimpan'
              : 'Profil',
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavbarView(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),

      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  print('Menandai tempat di: $_currentPosition');
                },
                child: const Icon(Icons.add_location_alt),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
