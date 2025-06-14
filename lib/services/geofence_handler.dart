// // lib/services/geofence_handler.dart

// import 'package:geofence_service/geofence_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'audio_player_service.dart'; // File tempat Anda menaruh fungsi playReminderSound

// class GeofenceHandler {
//   // Buat instance service
//   final _geofenceService = GeofenceService.instance.setup(
//     interval: 5000, // Interval pengecekan (ms)
//     accuracy: 100, // Akurasi lokasi (m)
//     loiteringDelayMs: 60000, // Waktu tunggu sebelum status DWELL terpicu
//     statusChangeDelayMs: 10000, // Waktu tunggu sebelum status ENTER/EXIT terpicu
//     useActivityRecognition: true, // Optimasi baterai dengan sensor aktivitas
//     allowMockLocations: false,
//     printDevLog: true, // Tampilkan log di debug console
//     geofenceRadiusSortType: GeofenceRadiusSortType.DESC,
//   );

//   // Fungsi yang akan dijalankan di background saat geofence terpicu
//   @pragma('vm:entry-point')
//   static void onGeofenceStatusChanged(
//       Geofence geofence,
//       GeofenceRadius geofenceRadius,
//       GeofenceStatus geofenceStatus,
//       Location location,
//   ) {
//     print('Geofence terpicu! ID: ${geofence.id}, Status: $geofenceStatus');

//     // Hanya picu saat memasuki area (ENTER) atau berdiam diri (DWELL)
//     if (geofenceStatus == GeofenceStatus.ENTER || geofenceStatus == GeofenceStatus.DWELL) {
//       // Dapatkan detail reminder dari Firestore berdasarkan ID geofence
//       // NOTE: Anda tidak bisa langsung akses Firestore di sini tanpa setup khusus.
//       // Cara terbaik adalah menyimpan detail penting (nama, nada dering) di dalam 'geofence.data'
//       // atau memicu notifikasi yang saat diklik akan membuka aplikasi dan memutar suara.

//       // Cara yang lebih praktis: Tampilkan notifikasi dan putar suara
//       final reminderName = geofence.data['name'] as String;
//       final ringtonePath = geofence.data['ringtone'] as String;

//       // Panggil fungsi pemutaran suara dari service audio Anda
//       AudioPlayerService().playReminderSound(ringtonePath, reminderName);

//       // Anda juga harus menampilkan notifikasi ke pengguna
//       // (menggunakan paket seperti flutter_local_notifications)
//     }
//   }

//   // Fungsi untuk memulai service dan mendaftarkan semua reminder aktif
//   Future<void> startService() async {
//     // Ambil semua reminder aktif dari Firestore
//     final reminders = await FirebaseFirestore.instance
//         .collection('reminders')
//         .where('isActive', isEqualTo: true)
//         .get();

//     final geofenceList = reminders.docs.map((doc) {
//       final data = doc.data();
//       return Geofence(
//         id: doc.id, // Gunakan ID Dokumen Firestore sebagai ID Geofence
//         latitude: data['latitude'],
//         longitude: data['longitude'],
//         radius: [
//           GeofenceRadius(
//             id: 'radius_${data['triggerRadius'].toInt()}',
//             length: data['triggerRadius'],
//           ),
//         ],
//         // Simpan data penting agar bisa diakses di background callback
//         data: {
//           'name': data['name'],
//           'ringtone': data['ringtone'],
//         },
//       );
//     }).toList();

//     return _geofenceService.start(geofenceList).catchError((error) {
//       print('Gagal memulai service geofence: $error');
//     });
//   }

//   // Panggil ini di main.dart atau halaman utama
//   void initialize() {
//     _geofenceService.addGeofenceStatusChangedListener(onGeofenceStatusChanged);
//     _geofenceService.addLocationChangedListener((location) { /* ... */ });
//     _geofenceService.addLocationServicesStatusChangedListener((status) { /* ... */ });
//     _geofenceService.addStreamErrorListener((error) { /* ... */ });
    
//     // Mulai service
//     startService();
//   }
// }