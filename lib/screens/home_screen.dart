import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    as places_sdk;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_toast.dart';
import '../screens/reminder/widgets/edit_reminder_sheet.dart';

const kGoogleApiKey = 'AIzaSyDvbiq-Uwemy8QMtkLvtuheSxCqkq1xZ-U';
const Color primaryColor = Color(0xFF4A90E2);
const Color textColor = Color(0xFF2D3748);

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
  Set<Circle> _reminderCircles = {};
  StreamSubscription<QuerySnapshot>? _remindersSubscription;
  bool _showInstruction = true;
  Timer? _instructionTimer;

  @override
  void initState() {
    super.initState();
    _places = places_sdk.FlutterGooglePlacesSdk(kGoogleApiKey);
    _initLocation();
    _searchController.addListener(_onSearchChanged);
    _listenToReminders();

    _instructionTimer = Timer(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() {
          _showInstruction = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _remindersSubscription?.cancel();
    _debounce?.cancel();
    _instructionTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _listenToReminders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query = FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true);

    _remindersSubscription = query.snapshots().listen((snapshot) {
      final Set<Marker> markers = {};
      final Set<Circle> circles = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final position = LatLng(data['latitude'], data['longitude']);
        final radius = (data['triggerRadius'] as num).toDouble();

        markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: position,
            infoWindow: InfoWindow(
              title: data['name'] ?? 'Tanpa Judul',
              snippet: 'Ketuk di sini untuk mengedit Pengingat',
              onTap: () {
                _showEditReminderModal(doc);
              },
            ),
          ),
        );

        circles.add(
          Circle(
            circleId: CircleId(doc.id),
            center: position,
            radius: radius,
            fillColor: Colors.blue.withOpacity(0.2),
            strokeColor: Colors.blue,
            strokeWidth: 1,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _reminderMarkers = markers;
          _reminderCircles = circles;
        });
      }
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
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    }
  }

  void _showAddReminderModal(LatLng position) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _radiusController = TextEditingController(
      text: '100',
    );

    const Color primaryColor = Color(0xFF4A90E2);
    const Color cardColor = Colors.white;
    const Color textColor = Color(0xFF2D3748);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                8,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Tambah Pengingat',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    style: GoogleFonts.lato(),
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Judul Pengingat',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.label_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _radiusController,
                    style: GoogleFonts.lato(),
                    decoration: InputDecoration(
                      labelText: 'Radius Pemicu',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.radar_outlined),
                      suffixText: 'meter',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: Text(
                        'Simpan Pengingat',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () async {
                        final name = _titleController.text;
                        final radius = double.tryParse(_radiusController.text);

                        if (name.trim().isEmpty) {
                          showErrorToast(
                            context,
                            'Judul pengingat tidak boleh kosong.',
                          );
                          return;
                        }
                        if (radius == null || radius <= 0) {
                          showErrorToast(
                            context,
                            'Radius harus berupa angka positif.',
                          );
                          return;
                        }

                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;
                        await FirebaseFirestore.instance
                            .collection('reminders')
                            .add({
                              'userId': user.uid,
                              'name': name,
                              'latitude': position.latitude,
                              'longitude': position.longitude,
                              'triggerRadius': radius,
                              'isActive': true,
                              'createdAt': FieldValue.serverTimestamp(),
                            });

                        if (context.mounted) {
                          Navigator.pop(context);
                          showSuccessToast(
                            context,
                            'Pengingat berhasil disimpan!',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditReminderModal(DocumentSnapshot doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EditReminderSheet(reminderDoc: doc);
      },
    );
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final input = _searchController.text;
      if (input.isEmpty) {
        if (mounted) {
          setState(() => _predictions = []);
        }
        return;
      }
      final result = await _places.findAutocompletePredictions(input);
      if (mounted) {
        setState(() {
          _predictions = result.predictions;
        });
      }
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

  Widget _buildInstructionOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !_showInstruction,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showInstruction ? 1.0 : 0.0,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.touch_app_outlined,
                        color: textColor,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tekan Lama di Peta',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'untuk menambahkan pengingat baru.',
                        style: GoogleFonts.lato(fontSize: 14, color: textColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
            circles: _reminderCircles,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onLongPress: (LatLng tappedPosition) {
              _showAddReminderModal(tappedPosition);
            },
          ),
          _buildInstructionOverlay(),
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
      ),
    );
  }
}
