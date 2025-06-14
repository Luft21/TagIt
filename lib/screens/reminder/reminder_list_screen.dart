import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tag_it/utils/constants.dart';
import 'package:tag_it/widgets/custom_toast.dart';
import 'widgets/reminder_card.dart';
import 'widgets/delete_reminder_dialog.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
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

  Future<void> _deleteReminder(String docId) async {
    final bool? confirmDelete = await showDeleteReminderDialog(context);

    if (confirmDelete == true && mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('reminders')
            .doc(docId)
            .delete();
        showSuccessToast(context, 'Pengingat berhasil dihapus.');
      } catch (e) {
        showErrorToast(context, 'Gagal menghapus pengingat.');
      }
    }
  }

  Widget _buildHeader() {
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
          Text(
            'Daftar Pengingat',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Icon(Icons.list_alt_rounded, color: Colors.white, size: 32),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Center(
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
                  return _buildEmptyState();
                }
                final reminders = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: reminders.length,
                  padding: const EdgeInsets.fromLTRB(16, 120, 16, 100),
                  itemBuilder: (context, index) {
                    final reminderDoc = reminders[index];
                    return ReminderCard(
                      reminderDoc: reminderDoc,
                      onDelete: () => _deleteReminder(reminderDoc.id),
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
