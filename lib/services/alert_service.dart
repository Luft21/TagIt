import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class AlertService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> triggerAlert() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000);
    }

    await _audioPlayer.play(AssetSource('alarm.mp3'));
  }
}
