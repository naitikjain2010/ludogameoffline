import 'package:just_audio/just_audio.dart';

class Audio {
  static Future<void> _play(String path) async {
    try {
      final player = AudioPlayer();
      final duration = await player.setAsset(path);
      await player.play();
      await Future.delayed(duration ?? Duration.zero);
      await player.dispose();
    } catch (e) {
      print("Audio Error $path: $e");
    }
  }

  static Future<void> playMove() => _play('assets/sounds/move.wav');
  static Future<void> playKill() => _play('assets/sounds/laugh.mp3');
  static Future<void> rollDice() => _play('assets/sounds/roll_the_dice.mp3');
}