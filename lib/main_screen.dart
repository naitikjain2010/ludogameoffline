import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ludo_flutter/ludo_provider.dart';
import 'package:ludo_flutter/widgets/board_widget.dart';
import 'package:ludo_flutter/widgets/dice_widget.dart';
import 'package:provider/provider.dart';
import 'screens/player_setup_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF060E40), Color(0xFF10248A), Color(0xFF060E40)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -50, left: -50, child: _glow(200)),
            Positioned(bottom: -50, right: -50, child: _glow(200)),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text("👑", style: TextStyle(fontSize: 38)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFB8860B)]),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
                    ),
                    child: const Text(
                      "LUDO BADSHAH",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Board ko Expanded diya taaki overflow na ho
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: BoardWidget(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Dice
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.8), blurRadius: 20, spreadRadius: 2)],
                    ),
                    child: const SizedBox(width: 55, height: 55, child: DiceWidget()),
                  ),
                  const SizedBox(height: 10), // 30 ki jagah 10 kar diya
                ],
              ),
            ),
            Consumer<LudoProvider>(
              builder: (context, value, child) => value.winners.length == 3
                  ? Container(
                color: Colors.black.withOpacity(0.9),
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Image.asset("assets/images/thankyou.gif"),
                    Text("Winners: ${value.winners.map((e) => e.name.toUpperCase()).join(", ")}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => PlayerSetupScreen()), (r) => false), child: const Text("NEW GAME"))
                  ]),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.amber.withOpacity(0.15)),
    );
  }
}