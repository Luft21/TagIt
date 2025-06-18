import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tag_it/models/reminder_model.dart';
import 'package:tag_it/utils/constants.dart';
import 'package:tag_it/widgets/custom_toast.dart';
import 'package:tag_it/services/alarm_service.dart';


class EditReminderSheet extends StatefulWidget {
  final DocumentSnapshot reminderDoc;
  const EditReminderSheet({super.key, required this.reminderDoc});
  @override
  State<EditReminderSheet> createState() => _EditReminderSheetState();
}

class _EditReminderSheetState extends State<EditReminderSheet> {
  late ReminderModel _reminder;
  late TextEditingController _nameController;
  late TextEditingController _radiusController;
  late bool _vibrateOn;
  late bool _isTextToSpeechEnabled;
  late String _selectedRingtone;
  late bool _isActive;
  List<String> _ringtones = [];
  bool _isLoadingRingtones = true;

  Timer? _testTimer;

  static const String _customRingtoneOption = 'Pilih Nada Dering Kustom...';
  static const String _silentOption = 'Hening';
  static const String _defaultAlarmOption = 'Nada Dering Alarm Default';
  static const String _defaultNotificationOption = 'Nada Notifikasi Default';

  @override
  void initState() {
    super.initState();
    final data = widget.reminderDoc.data() as Map<String, dynamic>;
    _reminder = ReminderModel.fromMap(data);

    _nameController = TextEditingController(text: _reminder.name);
    _radiusController = TextEditingController(
      text: _reminder.triggerRadius.toString(),
    );
    _vibrateOn = _reminder.vibrate;
    _isTextToSpeechEnabled = _reminder.ttsEnabled;
    _selectedRingtone = _reminder.ringtone;
    _isActive = _reminder.isActive;

    _loadAvailableRingtones();
  }

  Future<void> _loadAvailableRingtones() async {
    setState(() => _isLoadingRingtones = true);

    List<String> availableRingtones = [
      _silentOption,
      _defaultAlarmOption,
      _defaultNotificationOption,
    ];

    final ringtoneDir = await _getRingtoneDirectory();
    if (ringtoneDir.existsSync()) {
      final files = ringtoneDir.listSync();
      for (var file in files) {
        if (file is File) {
          availableRingtones.add(p.basename(file.path));
        }
      }
    }

    availableRingtones.add(_customRingtoneOption);

    setState(() {
      _ringtones = availableRingtones;
      if (_selectedRingtone.startsWith('/')) {
        _selectedRingtone = p.basename(_selectedRingtone);
      }
      if (!_ringtones.contains(_selectedRingtone)) {
        _selectedRingtone = _defaultAlarmOption;
      }
      _isLoadingRingtones = false;
    });
  }

  Future<Directory> _getRingtoneDirectory() async {
    final dirs = await getExternalStorageDirectories(
      type: StorageDirectory.documents,
    );
    if (dirs == null || dirs.isEmpty) {
      final internalDir = await getApplicationDocumentsDirectory();
      return Directory(p.join(internalDir.path, 'Ringtones'))
        ..createSync(recursive: true);
    }
    final ringtonePath = p.join(dirs.first.path, 'Ringtones');
    return Directory(ringtonePath)..createSync(recursive: true);
  }

  Future<void> _pickAndCopyRingtone() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      final sourceFile = File(result.files.single.path!);
      final ringtoneDir = await _getRingtoneDirectory();
      final fileName = p.basename(sourceFile.path);
      final destinationFile = File(p.join(ringtoneDir.path, fileName));

      await sourceFile.copy(destinationFile.path);
      showSuccessToast(context, '$fileName ditambahkan.');

      await _loadAvailableRingtones();
      setState(() => _selectedRingtone = fileName);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _radiusController.dispose();
    _stopTest();
    _testTimer?.cancel();
    super.dispose();
  }

  Future<void> _stopTest() async {
    AlarmService().stopAlarm();
  }

  Future<void> _runTest() async {
    await _stopTest();

    String ringtoneToPlay = _selectedRingtone;
    if (_isTextToSpeechEnabled) {
      ringtoneToPlay = 'Hening';
    } else if (_selectedRingtone != _defaultAlarmOption &&
        _selectedRingtone != _defaultNotificationOption &&
        _selectedRingtone != _silentOption) {
      final ringtoneDir = await _getRingtoneDirectory();
      ringtoneToPlay = p.join(ringtoneDir.path, _selectedRingtone);
    }

    await AlarmService().playAlarm(
      name: _nameController.text.trim().isEmpty
          ? "Ini adalah contoh notifikasi text to speech."
          : _nameController.text.trim(),
      ringtone: ringtoneToPlay,
      vibrate: _vibrateOn,
      ttsEnabled: _isTextToSpeechEnabled,
      duration: const Duration(seconds: 5), // Uji coba hanya 5 detik
    );

    showSuccessToast(context, 'Uji coba selesai.');
  }

  Future<void> _saveChanges() async {
    if (_isActive) {
      final name = _nameController.text;
      final radius = double.tryParse(_radiusController.text);

      if (name.trim().isEmpty) {
        showErrorToast(context, 'Nama pengingat tidak boleh kosong.');
        return;
      }
      if (radius == null || radius <= 0) {
        showErrorToast(context, 'Radius harus berupa angka positif.');
        return;
      }
    }

    if (mounted) {
      String ringtoneToSave = _selectedRingtone;
      if (_isTextToSpeechEnabled) {
        ringtoneToSave = _silentOption;
      } else if (_selectedRingtone != _defaultAlarmOption &&
          _selectedRingtone != _defaultNotificationOption &&
          _selectedRingtone != _silentOption) {
        final ringtoneDir = await _getRingtoneDirectory();
        ringtoneToSave = p.join(ringtoneDir.path, _selectedRingtone);
      }

      await FirebaseFirestore.instance
          .collection('reminders')
          .doc(widget.reminderDoc.id)
          .update({
            'isActive': _isActive,
            'name': _nameController.text,
            'alarmActive': false,
            'triggerRadius': double.tryParse(_radiusController.text) ?? 100.0,
            'vibrate': _vibrateOn,
            'ttsEnabled': _isTextToSpeechEnabled,
            'ringtone': ringtoneToSave,
          });

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
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Pengingat Aktif',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _isActive ? 'Notifikasi akan muncul' : 'Notifikasi dimatikan',
                  style: GoogleFonts.lato(),
                ),
                value: _isActive,
                onChanged: (bool value) => setState(() => _isActive = value),
                activeColor: primaryColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Divider(height: 24),
              IgnorePointer(
                ignoring: !_isActive,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isActive ? 1.0 : 0.4,
                  child: Column(
                    children: [
                      TextFormField(
                        enabled: _isActive,
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
                        enabled: _isActive,
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
                      SwitchListTile(
                        title: Text(
                          'Gunakan Text to Speech',
                          style: GoogleFonts.poppins(),
                        ),
                        subtitle: Text(
                          'Mengucapkan nama pengingat',
                          style: GoogleFonts.lato(),
                        ),
                        value: _isTextToSpeechEnabled,
                        onChanged:
                            _isActive
                                ? (bool value) => setState(
                                  () => _isTextToSpeechEnabled = value,
                                )
                                : null,
                        activeColor: primaryColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_isLoadingRingtones)
                        const Center(child: CircularProgressIndicator())
                      else
                        DropdownButtonFormField<String>(
                          value: _selectedRingtone,
                          isExpanded: true,
                          style: GoogleFonts.lato(
                            color:
                                _isTextToSpeechEnabled || !_isActive
                                    ? Colors.grey
                                    : textColor,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Nada Dering',
                            labelStyle: GoogleFonts.poppins(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.music_note_outlined),
                            filled: _isTextToSpeechEnabled || !_isActive,
                            fillColor: Colors.grey[200],
                          ),
                          items:
                              _ringtones.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lato(
                                      color:
                                          value == _customRingtoneOption
                                              ? primaryColor
                                              : null,
                                      fontStyle:
                                          value == _customRingtoneOption
                                              ? FontStyle.italic
                                              : FontStyle.normal,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged:
                              _isTextToSpeechEnabled || !_isActive
                                  ? null
                                  : (String? newValue) {
                                    if (newValue == _customRingtoneOption) {
                                      _pickAndCopyRingtone();
                                    } else if (newValue != null) {
                                      setState(
                                        () => _selectedRingtone = newValue,
                                      );
                                    }
                                  },
                        ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: Text('Getar', style: GoogleFonts.poppins()),
                        value: _vibrateOn,
                        onChanged:
                            _isActive
                                ? (bool value) =>
                                    setState(() => _vibrateOn = value)
                                : null,
                        activeColor: primaryColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.volume_up_outlined),
                          label: Text(
                            'Uji Coba Notifikasi',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: _isActive ? _runTest : null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: primaryColor,
                            side: BorderSide(
                              color: _isActive ? primaryColor : Colors.grey,
                              width: 1.5,
                            ),
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
              const SizedBox(height: 12),
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
