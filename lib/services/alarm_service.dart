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

  void stopAlarm({String? reminderId}) async { // <-- Make the function async
    print("---------- STOP ALARM INITIATED for $reminderId ----------");

    // Await all asynchronous stop commands
    await _flutterTts.stop().then((_) => print("LOG: TTS stop command sent."));
    await _audioPlayer.stop().then((_) => print("LOG: AudioPlayer stop command sent."));
    await FlutterRingtonePlayer().stop().then((_) => print("LOG: RingtonePlayer stop command sent."));
    // Vibration.cancel() is synchronous, but placing it here is fine
    Vibration.cancel();
    print("LOG: Vibration cancel command sent.");

    _alarmTimer?.cancel();
    print("LOG: Alarm timer cancelled.");

    if (reminderId != null) {
      await FirebaseFirestore.instance // <-- Await the Firestore update as well
          .collection('reminders')
          .doc(reminderId)
          .update({'alarmActive': false, 'isActive': false}).then((_) {
            print("LOG: Firestore updated: alarmActive for $reminderId is now false.");
          }).catchError((e) {
            print("ERROR: Firestore update failed for $reminderId: $e");
          });
    }
    print("---------- STOP ALARM FUNCTION ENDED ----------");
  }

  Future<void> playAlarm({
    required String name,
    required String ringtone,
    required bool vibrate,
    required bool ttsEnabled,
    Duration? duration,
  }) async {

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
    
    _alarmTimer = Timer(duration ?? const Duration(minutes: 1), () {
      stopAlarm();
    });
  }
}