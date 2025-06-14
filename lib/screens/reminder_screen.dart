import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_toast.dart';

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
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> _getRemindersStream() {
    if (currentUser == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: currentUser!.uid)
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.redAccent,
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Hapus Pengingat?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tindakan ini tidak dapat diurungkan. Anda akan menghapus pengingat ini secara permanen.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Hapus',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmDelete == true && mounted) {
      await FirebaseFirestore.instance
          .collection('reminders')
          .doc(docId)
          .delete();
      showSuccessToast(context, 'Pengingat berhasil dihapus.');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi,';
    if (hour < 15) return 'Selamat Siang,';
    if (hour < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
  }

  Widget _buildHeader() {
    String userName = currentUser?.displayName?.split(' ').first ?? 'Pengguna';
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              backgroundImage:
                  currentUser?.photoURL != null
                      ? NetworkImage(currentUser!.photoURL!)
                      : null,
              child:
                  currentUser?.photoURL == null
                      ? Text(
                        userName.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      )
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
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
                  return Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 100,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Belum Ada Pengingat',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
                final reminders = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: reminders.length,
                  padding: const EdgeInsets.fromLTRB(16, 130, 16, 100),
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
                      elevation: 2.0,
                      shadowColor: Colors.black.withOpacity(0.05),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: primaryColor.withOpacity(0.5),
                          width: 1,
                        ),
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
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
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
                                onPressed:
                                    () => _deleteReminder(reminderDoc.id),
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
            Positioned(top: 0, left: 0, right: 0, child: _buildHeader()),
          ],
        ),
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

    if (name.trim().isEmpty) {
      showErrorToast(context, 'Nama pengingat tidak boleh kosong.');
      return;
    }
    if (radius == null || radius < 0) {
      showErrorToast(context, 'Radius harus angka dan tidak boleh negatif.');
      return;
    }

    if (mounted) {
      await FirebaseFirestore.instance
          .collection('reminders')
          .doc(widget.reminderDoc.id)
          .update({'name': name, 'triggerRadius': radius});

      Navigator.pop(context);
      showSuccessToast(context, 'Pengingat berhasil diperbarui.');
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
