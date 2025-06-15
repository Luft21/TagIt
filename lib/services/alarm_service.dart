import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _alarmTimer;

  Future<void> stopAlarm({String? reminderId}) async {
    await _flutterTts.stop();
    await _audioPlayer.stop();
    await FlutterRingtonePlayer().stop();
    await Vibration.cancel();
    _alarmTimer?.cancel();

    if (reminderId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('reminders')
            .doc(reminderId)
            .update({'isActive': false});
        await FirebaseFirestore.instance
            .collection('reminders')
            .doc(reminderId)
            .update({'alarmActive': false});
      } catch (e) {
        print("Error updating Firestore on alarm stop: $e");
      }
    }
  }

  Future<void> playAlarm({
    required String name,
    required String ringtone,
    required bool vibrate,
    required bool ttsEnabled,
    Duration? duration,
  }) async {
    await stopAlarm();

    if (vibrate) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(pattern: [500, 1000, 500, 2000], repeat: 0);
      }
    }

    if (ttsEnabled) {
      _flutterTts.setLanguage("id-ID");
      await _flutterTts.speak(name);
       _flutterTts.setCompletionHandler(() {
         _flutterTts.speak(name);
       });
    } else {
       switch (ringtone) {
        case 'Nada Dering Alarm Default':
          FlutterRingtonePlayer().playAlarm(looping: true);
          break;
        case 'Nada Notifikasi Default':
          FlutterRingtonePlayer().playNotification(looping: true);
          break;
        case 'Hening':
          break;
        default:
          if (File(ringtone).existsSync()) {
            await _audioPlayer.play(DeviceFileSource(ringtone), volume: 1.0);
            _audioPlayer.setReleaseMode(ReleaseMode.loop);
          }
      }
    }
    
    _alarmTimer = Timer(duration ?? const Duration(minutes: 2), () {
      stopAlarm();
    });
  }
}