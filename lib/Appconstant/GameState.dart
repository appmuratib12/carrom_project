import 'package:flutter/material.dart';

enum GamePhase { aiming, shooting, piecesMoving, turnEnd, gameOver }
enum PieceType { black, white, queen, striker }
enum Player { one, two }

class GameState extends ChangeNotifier {
  Player currentPlayer = Player.one;
  GamePhase phase = GamePhase.aiming;

  int player1Score = 0;
  int player2Score = 0;
  bool queenPotted = false;
  bool queenCovered = false; // queen covered after potting

  int piecesLeft = 18; // 9 black + 9 white
  bool queenOnBoard = true;

  // Striker aim
  double strikerX = 5.0; // world units
  double aimAngle = -90.0; // degrees, -90 = straight up
  double power = 0.5; // 0.0 to 1.0

  String? lastMessage;
  List<String> eventLog = [];

  void switchPlayer() {
    currentPlayer = currentPlayer == Player.one ? Player.two : Player.one;
    phase = GamePhase.aiming;
    notifyListeners();
  }

  void addScore(Player player, int points, String reason) {
    if (player == Player.one) {
      player1Score += points;
    } else {
      player2Score += points;
    }
    lastMessage = '${player == Player.one ? "P1" : "P2"}: +$points ($reason)';
    eventLog.insert(0, lastMessage!);
    if (eventLog.length > 5) eventLog.removeLast();
    notifyListeners();
  }

  void setPhase(GamePhase newPhase) {
    phase = newPhase;
    notifyListeners();
  }

  void updateStrikerX(double x) {
    strikerX = x.clamp(
      3.35 + 0.28, // strikerMinX + radius
      6.65 - 0.28, // strikerMaxX - radius
    );
    notifyListeners();
  }

  void updateAimAngle(double angle) {
    aimAngle = angle;
    notifyListeners();
  }

  void updatePower(double p) {
    power = p.clamp(0.05, 1.0);
    notifyListeners();
  }

  bool get isGameOver => player1Score + player2Score >= 24 || piecesLeft == 0;

  Player get winner => player1Score >= player2Score ? Player.one : Player.two;

  String get currentPlayerName =>
      currentPlayer == Player.one ? 'Player 1' : 'Player 2';

  void reset() {
    currentPlayer = Player.one;
    phase = GamePhase.aiming;
    player1Score = 0;
    player2Score = 0;
    queenPotted = false;
    queenCovered = false;
    piecesLeft = 18;
    queenOnBoard = true;
    strikerX = 5.0;
    aimAngle = -90.0;
    power = 0.5;
    lastMessage = null;
    eventLog.clear();
    notifyListeners();
  }
}