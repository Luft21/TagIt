import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:path/path.dart' as p;

final audioPlayer = AudioPlayer();
final FlutterRingtonePlayer flutterRingtonePlayer = FlutterRingtonePlayer();

Future<void> playReminderSound(String ringtoneIdentifier, String reminderName) async {
  await audioPlayer.stop();

  switch (ringtoneIdentifier) {
    case 'Hening':
      break;
    
    case 'Nada Dering Alarm Default':
      flutterRingtonePlayer.playAlarm(looping: true);
      break;

    case 'Nada Notifikasi Default':
      flutterRingtonePlayer.playNotification(looping: true);
      break;

    default:
      final ringtoneFile = File(ringtoneIdentifier);
      if (await ringtoneFile.exists()) {
        await audioPlayer.play(
          DeviceFileSource(ringtoneIdentifier),
          mode: PlayerMode.mediaPlayer,
        );
        await audioPlayer.setReleaseMode(ReleaseMode.loop);
      } else {
        print('File nada dering kustom tidak ditemukan, memutar default.');
        flutterRingtonePlayer.playAlarm(looping: true);
      }
      break;
  }
}

Future<void> stopReminderSound() async {
  await audioPlayer.stop();
  await flutterRingtonePlayer.stop();
}