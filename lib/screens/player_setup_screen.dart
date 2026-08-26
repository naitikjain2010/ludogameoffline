import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../ludo_provider.dart';
import '../main_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});
  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  int selectedPlayers = 2;
  List<String> playerColors = ["green", "blue"];
  String? cheatColor;
  final AudioPlayer _bgPlayer = AudioPlayer();
  bool _started = false;

  final Map<String, Color> colorMap = {
    "red": Colors.red,
    "green": Colors.green,
    "yellow": Colors.yellow,
    "blue": Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    updateColors();
    _initMusic();
  }

  Future<void> _initMusic() async {
    try {
      await _bgPlayer.setAsset('assets/sounds/bg.mp3');
      await _bgPlayer.setLoopMode(LoopMode.all);
      await _bgPlayer.setVolume(0.4);
      await _bgPlayer.play();
      _started = true;
    } catch (e) {
      debugPrint("music init: $e");
    }
  }

  Future<void> _ensurePlay() async {
    if (_bgPlayer.playing) return;
    try {
      if (!_started) {
        await _bgPlayer.play();
        _started = true;
      } else {
        await _bgPlayer.play();
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    _bgPlayer.stop();
    _bgPlayer.dispose();
    super.dispose();
  }

  void updateColors() {
    if (selectedPlayers == 2) {
      playerColors = ["green", "blue"];
    } else if (selectedPlayers == 3) {
      playerColors = ["green", "yellow", "blue"];
    } else {
      playerColors = ["red", "green", "yellow", "blue"];
    }
    cheatColor = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _ensurePlay,
      child: Scaffold(
        backgroundColor: const Color(0xFF4E1D95),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text("SELECT PLAYERS", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_btn(2), _btn(3), _btn(4)],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: playerColors.length,
                  itemBuilder: (context, index) {
                    String colorName = playerColors[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onLongPress: () {
                              HapticFeedback.mediumImpact();
                              cheatColor = colorName;
                            },
                            child: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                color: colorMap[colorName],
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text("Player ${index + 1} - ${colorName.toUpperCase()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  },
                ),
             