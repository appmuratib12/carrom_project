import 'package:flutter/material.dart';

class AppColors {
  // Board colors
  static const boardWood = Color(0xFFD4A055);
  static const boardWoodDark = Color(0xFF8B5E2A);
  static const boardWoodLight = Color(0xFFE8C07A);
  static const boardSurface = Color(0xFFC8973D);
  static const boardBorder = Color(0xFF5C3510);
  static const boardInner = Color(0xFFBF8C35);

  // Piece colors
  static const pieceBlack = Color(0xFF1A1A1A);
  static const pieceWhite = Color(0xFFF5F0E8);
  static const pieceQueen = Color(0xFFE8001A);
  static const strikerColor = Color(0xFFFFD700);
  static const strikerBorder = Color(0xFFB8860B);

  // UI colors
  static const bgDark = Color(0xFF1A0A00);
  static const bgMid = Color(0xFF2D1500);
  static const gold = Color(0xFFFFD700);
  static const goldLight = Color(0xFFFFE44D);
  static const accent = Color(0xFFFF6B35);
  static const accentLight = Color(0xFFFF9A6C);

  // Score colors
  static const player1Color = Color(0xFF4FC3F7);
  static const player2Color = Color(0xFFEF9A9A);

  // Pocket
  static const pocketColor = Color(0xFF0D0500);
  static const pocketRing = Color(0xFF3D1F00);

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color limeGreen = Color(0xFF52B788);
  static const Color freshMint = Color(0xFF74C69D);
  static const Color lightMint = Color(0xFFB7E4C7);
  static const Color citrus = Color(0xFFF4A261);
  static const Color softOrange = Color(0xFFFDBA74);
  static const Color cream = Color(0xFFFEFAE0);
  static const Color softCream = Color(0xFFF8F4E3);
  static const Color charcoal = Color(0xFF1B1B2F);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9CA3AF);
  static const Color lightGrey = Color(0xFFF3F4F6);

}

class GameConfig {
  // Board dimensions (logical units matching Forge2D world)
  static const double boardSize = 400.0; // pixels shown on screen
  static const double worldSize = 10.0;  // Forge2D world units

  // Scale factor: pixels per world unit
  static double get scale => boardSize / worldSize;

  // Piece radii in world units
  static const double coinRadius = 0.22;
  static const double strikerRadius = 0.28;
  static const double pocketRadius = 0.38;

  // Board geometry
  static const double wallThickness = 0.15;
  static const double boardCenter = worldSize / 2; // 5.0

  // Physics
  static const double coinFriction = 0.35;
  static const double strikerFriction = 0.25;
  static const double restitution = 0.65;
  static const double linearDamping = 1.8;
  static const double maxStrikerImpulse = 18.0;
  static const double minStrikerImpulse = 3.0;

  // Striker Y positions (world units) for each player
  static const double player1StrikerY = 8.35; // bottom
  static const double player2StrikerY = 1.65; // top
  static const double strikerMinX = 3.35;
  static const double strikerMaxX = 6.65;

  // Scores
  static const int queenPoints = 3;
  static const int coinPoints = 1;



}