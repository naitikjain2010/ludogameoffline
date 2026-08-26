import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ludo_flutter/ludo_player.dart';
import 'constants.dart';
import 'audio.dart';

class LudoProvider extends ChangeNotifier {
  bool _isMoving = false;
  bool _stopMoving = false;
  LudoGameState _gameState = LudoGameState.throwDice;
  LudoGameState get gameState => _gameState;
  LudoPlayerType _currentTurn = LudoPlayerType.green;
  int _diceResult = 0;

  int totalPlayers = 4;
  List<LudoPlayerType> activePlayerTypes = [];

  // --- CHEAT SYSTEM ---
  String? secretWinner;
  void setCheatWinner(String color){
    secretWinner = color.toLowerCase();
    notifyListeners();
  }
  LudoPlayerType? get cheatType {
    if(secretWinner == null) return null;
    if(secretWinner == "green") return LudoPlayerType.green;
    if(secretWinner == "blue") return LudoPlayerType.blue;
    if(secretWinner == "yellow") return LudoPlayerType.yellow;
    if(secretWinner == "red") return LudoPlayerType.red;
    return null;
  }

  int get diceResult {
    if (_diceResult < 1) return 1;
    else { if (_diceResult > 6) return 6; else return _diceResult; }
  }
  bool _diceStarted = false;
  bool get diceStarted => _diceStarted;
  LudoPlayer get currentPlayer => players.firstWhere((element) => element.type == _currentTurn);
  final List<LudoPlayer> players = [];
  final List<LudoPlayerType> winners = [];
  LudoPlayer player(LudoPlayerType type) => players.firstWhere((element) => element.type == type);

  bool checkToKill(LudoPlayerType type, int index, int step, List<List<double>> path) {
    bool killSomeone = false;
    for (int i = 0; i < 4; i++) {
      for(var pType in activePlayerTypes){
        var p = player(pType);
        var pawn = p.pawns[i];
        if ((pawn.step > -1 &&!LudoPath.safeArea.map((e) => e.toString()).contains(p.path[pawn.step].toString())) && type!= pType) {
          if (p.path[pawn.step].toString() == path[step - 1].toString()) {
            killSomeone = true;
            p.movePawn(i, -1);
            notifyListeners();
          }
        }
      }
    }
    return killSomeone;
  }

  // --- SMART DICE LOGIC - doubt nahi hoga ---
  int _generateDice() {
    var random = Random();
    var me = currentPlayer;

    bool canKillWith(int dice) {
      for (var pawn in me.pawns) {
        if (pawn.step == -1) continue;
        int targetStep = pawn.step + dice;
        if (targetStep >= me.path.length) continue;
        var targetPos = me.path[targetStep].toString();
        for (var pType in activePlayerTypes) {
          if (pType == me.type) continue;
          var opp = player(pType);
          for (var opPawn in opp.pawns) {
            if (opPawn.step == -1) continue;
            if (LudoPath.safeArea.map((e) => e.toString()).contains(opp.path[opPawn.step].toString())) continue;
            if (opp.path[opPawn.step].toString() == targetPos) return true;
          }
        }
      }
      return false;
    }

    // Tumhara selected color hai to
    if (cheatType!= null && _currentTurn == cheatType) {
      if (me.pawnInsideCount == 4) return 6; // goti late nahi hogi

      for(int d=1; d<=6; d++){
        if(canKillWith(d) && random.nextInt(100) < 70) return d; // katne ka moka milega
      }
      if (random.nextInt(100) < 35) return 6; // 35% 6, natural lagega
      return random.nextInt(6) + 1;
    }

    // Samne walo ke liye
    if (cheatType!= null && _currentTurn!= cheatType) {
      int dice = random.nextInt(6) + 1;
      if (random.nextInt(100) < 22) dice = 6; // unko bhi 6 ayega

      var cheatPlayer = player(cheatType!);
      bool willKillCheat = false;
      for (var pawn in me.pawns) {
        if (pawn.step == -1) continue;
        int t = pawn.step + dice;
        if (t >= me.path.length) continue;
        for(var cp in cheatPlayer.pawns){
          if(cp.step==-1) continue;
          if(me.path[t].toString() == cheatPlayer.path[cp.step].toString()){
            willKillCheat = true;
          }
        }
      }
      if(willKillCheat && random.nextInt(100) < 60){
        return random.nextInt(3)+1; // tumhe katne se bacha liya
      }
      return dice;
    }

    return random.nextBool()? 6 : random.nextInt(6) + 1;
  }

  void throwDice() async {
    if (_gameState!= LudoGameState.throwDice) return;
    _diceStarted = true;
    notifyListeners();
    Audio.rollDice();
    if (winners.contains(currentPlayer.type)) { nextTurn(); return; }
    currentPlayer.highlightAllPawns(false);
    Future.delayed(const Duration(seconds: 1)).then((value) {
      _diceStarted = false;
      _diceResult = _generateDice(); // SMART LOGIC
      notifyListeners();
      if (diceResult == 6) {
        currentPlayer.highlightAllPawns();
        _gameState = LudoGameState.pickPawn;
        notifyListeners();
      } else {
        if (currentPlayer.pawnInsideCount == 4) return nextTurn();
        else { currentPlayer.highlightOutside(); _gameState = LudoGameState.pickPawn; notifyListeners(); }
      }
      for (var i = 0; i < currentPlayer.pawns.length; i++) {
        var pawn = currentPlayer.pawns[i];
        if ((pawn.step + diceResult) > currentPlayer.path.length - 1) currentPlayer.highlightPawn(i, false);
      }
      var moveablePawn = currentPlayer.pawns.where((e) => e.highlight).toList();
      if (moveablePawn.length > 1) {
        var biggestStep = moveablePawn.map((e) => e.step).reduce(max);
        if (moveablePawn.every((element) => element.step == biggestStep)) {
          var randomIdx = 1 + Random().nextInt(moveablePawn.length - 1);
          if(randomIdx >= moveablePawn.length) randomIdx = 0;
          var thePawn = moveablePawn[randomIdx];
          if (thePawn.step == -1) move(thePawn.type, thePawn.index, (thePawn.step + 1) + 1);
          else move(thePawn.type, thePawn.index, (thePawn.step + 1) + diceResult);
          return;
        }
      }
      if (currentPlayer.pawns.every((element) =>!element.highlight)) {
        if (diceResult == 6) _gameState = LudoGameState.throwDice;
        else { nextTurn(); return; }
      }
      if (currentPlayer.pawns.where((element) => element.highlight).length == 1) {
        var index = currentPlayer.pawns.indexWhere((element) => element.highlight);
        move(currentPlayer.type, index, (currentPlayer.pawns[index].step + 1) + diceResult);
      }
    });
  }

  void move(LudoPlayerType type, int index, int step) async {
    if (_isMoving) return;
    _isMoving = true;
    _gameState = LudoGameState.moving;
    currentPlayer.highlightAllPawns(false);
    var selectedPlayer = player(type);
    for (int i = selectedPlayer.pawns[index].step; i < step; i++) {
      if (_stopMoving) break;
      if (selectedPlayer.pawns[index].step == i) continue;
      selectedPlayer.movePawn(index, i);
      await Audio.playMove();
      notifyListeners();
      if (_stopMoving) break;
    }
    if (checkToKill(type, index, step, selectedPlayer.path)) {
      _gameState = LudoGameState.throwDice; _isMoving = false; Audio.playKill(); notifyListeners(); return;
    }
    validateWin(type);
    if (diceResult == 6) { _gameState = LudoGameState.throwDice; notifyListeners(); }
    else { nextTurn(); notifyListeners(); }
    _isMoving = false;
  }

  void nextTurn() {
    int currentIndex = activePlayerTypes.indexOf(_currentTurn);
    int nextIndex = (currentIndex + 1) % activePlayerTypes.length;
    _currentTurn = activePlayerTypes[nextIndex];
    if (winners.contains(_currentTurn)) return nextTurn();
    _gameState = LudoGameState.throwDice;
    notifyListeners();
  }

  void validateWin(LudoPlayerType color) {
    if (winners.map((e) => e.name).contains(color.name)) return;
    if (player(color).pawns.map((e) => e.step).every((element) => element == player(color).path.length - 1)) {
      winners.add(color);
      notifyListeners();
    }
    if (winners.length == activePlayerTypes.length - 1) {
      _gameState = LudoGameState.finish;
    }
  }

  void startGame({int totalPlayers = 4}) {
    this.totalPlayers = totalPlayers;
    winners.clear();
    players.clear();
    if (totalPlayers == 2) {
      activePlayerTypes = [LudoPlayerType.green, LudoPlayerType.blue];
    } else if (totalPlayers == 3) {
      activePlayerTypes = [LudoPlayerType.green, LudoPlayerType.yellow, LudoPlayerType.blue];
    } else {
      activePlayerTypes = [LudoPlayerType.green, LudoPlayerType.yellow, LudoPlayerType.blue, LudoPlayerType.red];
    }
    for (var type in activePlayerTypes) {
      players.add(LudoPlayer(type));
    }
    _currentTurn = activePlayerTypes.first;
    _gameState = LudoGameState.throwDice;
    notifyListeners();
  }

  @override
  void dispose() { _stopMoving = true; super.dispose(); }
}