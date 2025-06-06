import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' as places_sdk;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tag_it/models/reminder_model.dart';

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
  Set<Marker> _reminderMarkers = {};

  @override
  void initState() {
    super.initState();
    _places = places_sdk.FlutterGooglePlacesSdk(kGoogleApiKey);
    _initLocation();
    _searchController.addListener(_onSearchChanged);
    _loadReminders();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .get();

    final markers = snapshot.docs.map((doc) {
      final data = doc.data();
      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(data['latitude'], data['longitude']),
        infoWindow: InfoWindow(title: data['name']),
      );
    }).toSet();

    setState(() {
      _reminderMarkers = markers;
    });
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

  void _showAddReminderModal(LatLng position) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _radiusController = TextEditingController(text: '100');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tambah Pengingat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Judul Pengingat'),
              ),
              TextField(
                controller: _radiusController,
                decoration: InputDecoration(labelText: 'Radius (meter)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;
                  final reminder = ReminderModel(
                    userId: user.uid,
                    name: _titleController.text,
                    latitude: position.latitude,
                    longitude: position.longitude,
                    triggerRadius: double.tryParse(_radiusController.text) ?? 100,
                    isActive: true,
                  );
                  await FirebaseFirestore.instance.collection('reminders').add({
                    'userId': reminder.userId,
                    'name': reminder.name,
                    'latitude': reminder.latitude,
                    'longitude': reminder.longitude,
                    'triggerRadius': reminder.triggerRadius,
                    'isActive': reminder.isActive,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pengingat berhasil disimpan!')),
                  );
                  _loadReminders(); // refresh marker
                },
                child: const Text('Simpan'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
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

  Future<void> _onSelectPrediction(places_sdk.AutocompletePrediction prediction) async {
    final placeId = prediction.placeId;

    final details = await _places.fetchPlace(
      placeId,
      fields: [places_sdk.PlaceField.Location],
    );

    final lat = details.place?.latLng?.lat;
    final lng = details.place?.latLng?.lng;
    if (lat != null && lng != null) {
      final newPos = LatLng(lat, lng);
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: newPos, zoom: 15),
      ));
      _searchController.removeListener(_onSearchChanged);
      setState(() {
        _searchController.text = prediction.fullText;
        _predictions = [];
      });
      _searchController.addListener(_onSearchChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _reminderMarkers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onLongPress: (LatLng tappedPosition) {
              _showAddReminderModal(tappedPosition);
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        suffixIcon: _searchController.text.isNotEmpty
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
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                            )
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
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}