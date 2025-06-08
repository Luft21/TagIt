import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

const Color primaryColor = Color(0xFF4A90E2);
const Color backgroundColor = Color(0xFFF4F6F8);
const Color cardColor = Colors.white;
const Color textColor = Color(0xFF333333);
const Color secondaryTextColor = Color(0xFF7A7A7A);

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  Stream<QuerySnapshot> _getRemindersStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
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

  Future<void> _deleteReminder(String docId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Hapus Pengingat',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus pengingat ini?',
            style: GoogleFonts.lato(),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Hapus',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true && mounted) {
      await FirebaseFirestore.instance
          .collection('reminders')
          .doc(docId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Daftar Pengingat',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getRemindersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: GoogleFonts.lato(),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 24),
                  Text(
                    'Belum Ada Pengingat',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan lama pada peta untuk menambahkan pengingat pertama Anda.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            );
          }
          final reminders = snapshot.data!.docs;
          return ListView.builder(
            itemCount: reminders.length,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            itemBuilder: (context, index) {
              final reminderDoc = reminders[index];
              final data = reminderDoc.data() as Map<String, dynamic>;
              final formattedDate =
                  data['createdAt'] == null
                      ? 'N/A'
                      : DateFormat(
                        'd MMM y, HH:mm',
                      ).format((data['createdAt'] as Timestamp).toDate());
              return Card(
                elevation: 4.0,
                shadowColor: Colors.black.withOpacity(0.1),
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showEditReminderModal(reminderDoc),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: primaryColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'] ?? 'Tanpa Judul',
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 12.0,
                                runSpacing: 4.0,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.radar_outlined,
                                        size: 14,
                                        color: secondaryTextColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${data['triggerRadius']} meter',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: secondaryTextColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        formattedDate,
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever_outlined,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _deleteReminder(reminderDoc.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EditReminderSheet extends StatefulWidget {
  final DocumentSnapshot reminderDoc;
  const EditReminderSheet({super.key, required this.reminderDoc});
  @override
  State<EditReminderSheet> createState() => _EditReminderSheetState();
}

class _EditReminderSheetState extends State<EditReminderSheet> {
  late TextEditingController _nameController;
  late TextEditingController _radiusController;
  late bool _vibrateOn;
  late String _selectedRingtone;
  final List<String> _ringtones = [
    'Nada Dering 1',
    'Nada Dering 2',
    'Nada Dering 3',
    'Hening',
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.reminderDoc.data() as Map<String, dynamic>;
    _nameController = TextEditingController(text: data['name'] ?? '');
    _radiusController = TextEditingController(
      text: (data['triggerRadius'] ?? 100.0).toString(),
    );
    _vibrateOn = true;
    _selectedRingtone = _ringtones.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text;
    final radius = double.tryParse(_radiusController.text);
    if (name.isEmpty || radius == null || radius <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pastikan nama dan radius diisi dengan benar.'),
        ),
      );
      return;
    }
    if (mounted) {
      await FirebaseFirestore.instance
          .collection('reminders')
          .doc(widget.reminderDoc.id)
          .update({'name': name, 'triggerRadius': radius});
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Edit Pengingat',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.lato(),
                decoration: InputDecoration(
                  labelText: 'Nama Pengingat',
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRingtone,
                style: GoogleFonts.lato(),
                decoration: InputDecoration(
                  labelText: 'Nada Dering',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.music_note_outlined),
                ),
                items:
                    _ringtones.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: GoogleFonts.lato()),
                      );
                    }).toList(),
                onChanged:
                    (String? newValue) =>
                        setState(() => _selectedRingtone = newValue!),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: Text('Getar', style: GoogleFonts.poppins()),
                value: _vibrateOn,
                onChanged: (bool value) => setState(() => _vibrateOn = value),
                activeColor: primaryColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_as_outlined),
                  label: Text(
                    'Simpan Perubahan',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: _saveChanges,
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
  }
}
