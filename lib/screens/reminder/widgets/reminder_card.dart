import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../utils/constants.dart';
import 'edit_reminder_sheet.dart';
import 'delete_reminder_dialog.dart';

class ReminderCard extends StatelessWidget {
  final DocumentSnapshot reminderDoc;

  const ReminderCard({super.key, required this.reminderDoc});

  void _showEditReminderModal(BuildContext context, DocumentSnapshot doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EditReminderSheet(reminderDoc: doc);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = reminderDoc.data() as Map<String, dynamic>;
    final formattedDate = data['createdAt'] == null
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
        onTap: () => _showEditReminderModal(context, reminderDoc),
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
                onPressed: () => showDeleteReminderDialog(context, reminderDoc.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}