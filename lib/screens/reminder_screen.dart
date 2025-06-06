import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  GoogleMapController? _mapController;
  LatLng? _initialPosition; // Posisi awal pengguna
  LatLng? _selectedPosition; // Posisi yang dipilih oleh pin

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _initialPosition = const LatLng(-6.200000, 106.816666);
          _selectedPosition = _initialPosition;
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle kasus di mana pengguna memblokir izin lokasi secara permanen
       setState(() {
          _initialPosition = const LatLng(-6.200000, 106.816666);
          _selectedPosition = _initialPosition;
          _isLoading = false;
        });
      return;
    }

    // Jika izin diberikan, dapatkan posisi
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _selectedPosition = _initialPosition; // Awalnya, posisi terpilih sama dengan posisi awal
      _isLoading = false;
    });
  }

  // Callback yang dipanggil setiap kali peta digerakkan
  void _onCameraMove(CameraPosition position) {
    // Update posisi yang dipilih sesuai dengan pusat peta
    setState(() {
      _selectedPosition = position.target;
    });
  }

  void _simpanKoordinat() {
    if (_selectedPosition != null) {
      final lat = _selectedPosition!.latitude;
      final lon = _selectedPosition!.longitude;

      // Tampilkan notifikasi (SnackBar) dengan koordinat yang disimpan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lokasi disimpan! Koordinat: Lat: $lat, Lon: $lon'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Di sini Anda bisa menambahkan logika lebih lanjut,
      // misalnya menyimpan ke database atau mengirim ke halaman lain.
      // Navigator.pop(context, _selectedPosition);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tandai Lokasi Tujuan'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Widget Google Map sebagai background
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition!,
                    zoom: 16.0,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onCameraMove: _onCameraMove, // Ini adalah kunci utama!
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),

                // Pin yang berada di tengah layar
                Center(
                  child: Transform.translate(
                    // Sedikit menaikkan pin agar ujung bawahnya pas di tengah
                    offset: const Offset(0, -25), 
                    child: const Icon(
                      Icons.location_pin,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                ),
                
                // Tombol Simpan di bagian bawah
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(20.0),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Simpan Lokasi Ini'),
                      onPressed: _simpanKoordinat,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
