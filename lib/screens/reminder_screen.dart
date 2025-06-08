import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Package untuk format tanggal

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  // Mendapatkan stream data pengingat dari Firestore
  Stream<QuerySnapshot> _getRemindersStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Mengembalikan stream kosong jika pengguna tidak login
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: user.uid)
        .orderBy(
          'createdAt',
          descending: true,
        ) // Menampilkan yang terbaru di atas
        .snapshots(); // .snapshots() membuat stream real-time
  }

  // Fungsi untuk menghapus pengingat
  Future<void> _deleteReminder(String docId) async {
    // Tampilkan dialog konfirmasi sebelum menghapus
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Pengingat'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus pengingat ini?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Batal
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed:
                  () => Navigator.of(context).pop(true), // Konfirmasi hapus
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    // Jika pengguna mengkonfirmasi, hapus dokumen dari Firestore
    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('reminders')
            .doc(docId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengingat berhasil dihapus')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus pengingat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengingat'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getRemindersStream(),
        builder: (context, snapshot) {
          // Tampilkan indikator loading saat menunggu data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Tampilkan pesan error jika terjadi kesalahan
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          // Tampilkan pesan jika tidak ada data/pengingat
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Pengingat',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan pengingat melalui halaman Peta.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          // Jika ada data, tampilkan dalam bentuk ListView
          final reminders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reminders.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final reminderDoc = reminders[index];
              final data = reminderDoc.data() as Map<String, dynamic>;

              // Format tanggal (jika ada)
              String formattedDate = 'Tanggal tidak tersedia';
              if (data['createdAt'] != null) {
                DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
                formattedDate = DateFormat(
                  'd MMMM yyyy, HH:mm',
                ).format(createdAt);
              }

              return Card(
                elevation: 3.0,
                margin: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 8.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Text(
                    data['name'] ?? 'Tanpa Judul',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Radius: ${data['triggerRadius']} meter\nDibuat pada: $formattedDate',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      _deleteReminder(reminderDoc.id);
                    },
                    tooltip: 'Hapus Pengingat',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
