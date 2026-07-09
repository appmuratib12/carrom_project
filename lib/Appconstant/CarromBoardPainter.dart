import 'dart:math';
import 'package:flutter/material.dart';

import 'AppColors.dart';

class CarromBoardPainter extends CustomPainter {
  final List<PieceData> pieces;
  final StrikerData striker;
  final double? aimAngle; // degrees
  final double power;
  final bool showAim;
  final int currentPlayer; // 1 or 2

  CarromBoardPainter({
    required this.pieces,
    required this.striker,
    this.aimAngle,
    this.power = 0.5,
    this.showAim = false,
    this.currentPlayer = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width; // square board
    final scale = s / GameConfig.worldSize;

    _drawWoodBackground(canvas, s);
    _drawBoardFrame(canvas, s);
    _drawPlaySurface(canvas, s);
    _drawBoardMarkings(canvas, s);
    _drawPockets(canvas, s);
    _drawStrikerZone(canvas, s, scale);
    if (showAim && aimAngle != null) {
      _drawAimLine(canvas, s, scale);
    }
    _drawPieces(canvas, s, scale);
    _drawStriker(canvas, s, scale);
  }

  void _drawWoodBackground(Canvas canvas, double s) {
    final paint = Paint()..color = AppColors.boardBorder;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, s, s), const Radius.circular(12)),
      paint,
    );

    // Wood grain lines
    final grainPaint = Paint()
      ..color = AppColors.boardWoodDark.withOpacity(0.3)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 20; i++) {
      final y = (s / 20) * i + s / 40;
      canvas.drawLine(Offset(8, y + sin(i * 0.8) * 4), Offset(s - 8, y + sin(i * 0.8 + 1) * 4), grainPaint);
    }
  }

  void _drawBoardFrame(Canvas canvas, double s) {
    const pad = 12.0;
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pad, pad, s - pad * 2, s - pad * 2),
      const Radius.circular(8),
    );

    // Outer frame
    final framePaint = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.boardWoodLight, AppColors.boardWood, AppColors.boardWoodDark],
        stops: const [0.0, 0.5, 1.0],
        center: const Alignment(-0.3, -0.3),
      ).createShader(Rect.fromLTWH(pad, pad, s - pad * 2, s - pad * 2));
    canvas.drawRRect(frameRect, framePaint);

    // Frame border
    final borderPaint = Paint()
      ..color = AppColors.boardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(frameRect, borderPaint);
  }

  void _drawPlaySurface(Canvas canvas, double s) {
    const margin = 28.0;
    final surfaceRect = Rect.fromLTWH(margin, margin, s - margin * 2, s - margin * 2);

    final surfacePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFCB9A3E),
          const Color(0xFFBF8C35),
          const Color(0xFFD4A550),
          const Color(0xFFBF8C35),
        ],
      ).createShader(surfaceRect);
    canvas.drawRect(surfaceRect, surfacePaint);

    // Subtle texture
    final texturePaint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 30; i++) {
      final y = margin + (s - margin * 2) / 30 * i;
      canvas.drawLine(Offset(margin, y), Offset(s - margin, y + 2), texturePaint);
    }
  }

  void _drawBoardMarkings(Canvas canvas, double s) {
    const margin = 28.0;
    final playSize = s - margin * 2;
    final center = Offset(s / 2, s / 2);

    // Diagonal lines from corners
    final diagPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final corners = [
      Offset(margin, margin),
      Offset(s - margin, margin),
      Offset(s - margin, s - margin),
      Offset(margin, s - margin),
    ];

    for (final corner in corners) {
      canvas.drawLine(corner, center, diagPaint);
    }

    // Main center circle (large)
    final circlePaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, playSize * 0.15, circlePaint);

    // Inner center circle
    canvas.drawCircle(center, playSize * 0.06, circlePaint);

    // Tiny center dot
    final dotPaint = Paint()..color = Colors.black.withOpacity(0.5);
    canvas.drawCircle(center, 4, dotPaint);

    // Red center dot
    final redDot = Paint()..color = AppColors.pieceQueen.withOpacity(0.7);
    canvas.drawCircle(center, 3, redDot);

    // Arrow lines (baseline for striker)
    _drawBaselineArrows(canvas, s, margin);
  }

  void _drawBaselineArrows(Canvas canvas, double s, double margin) {
    final arrowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final playSize = s - margin * 2;

    // Bottom baseline (player 1)
    final p1BaseY = s - margin - playSize * 0.165;
    canvas.drawLine(
      Offset(s / 2 - playSize * 0.165, p1BaseY),
      Offset(s / 2 + playSize * 0.165, p1BaseY),
      arrowPaint,
    );
    // Small ticks
    canvas.drawLine(Offset(s / 2 - playSize * 0.165, p1BaseY - 5),
        Offset(s / 2 - playSize * 0.165, p1BaseY + 5), arrowPaint);
    canvas.drawLine(Offset(s / 2 + playSize * 0.165, p1BaseY - 5),
        Offset(s / 2 + playSize * 0.165, p1BaseY + 5), arrowPaint);

    // Top baseline (player 2)
    final p2BaseY = margin + playSize * 0.165;
    canvas.drawLine(
      Offset(s / 2 - playSize * 0.165, p2BaseY),
      Offset(s / 2 + playSize * 0.165, p2BaseY),
      arrowPaint,
    );
    canvas.drawLine(Offset(s / 2 - playSize * 0.165, p2BaseY - 5),
        Offset(s / 2 - playSize * 0.165, p2BaseY + 5), arrowPaint);
    canvas.drawLine(Offset(s / 2 + playSize * 0.165, p2BaseY - 5),
        Offset(s / 2 + playSize * 0.165, p2BaseY + 5), arrowPaint);
  }

  void _drawPockets(Canvas canvas, double s) {
    const margin = 28.0;
    final pocketRadius = s * 0.065;

    final pocketPositions = [
      Offset(margin, margin),
      Offset(s - margin, margin),
      Offset(s - margin, s - margin),
      Offset(margin, s - margin),
    ];

    for (final pos in pocketPositions) {
      // Shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(pos + const Offset(2, 2), pocketRadius, shadowPaint);

      // Dark hole
      final holePaint = Paint()..color = AppColors.pocketColor;
      canvas.drawCircle(pos, pocketRadius, holePaint);

      // Ring
      final ringPaint = Paint()
        ..color = AppColors.pocketRing
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(pos, pocketRadius, ringPaint);

      // Inner sheen
      final sheenPaint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withOpacity(0.08), Colors.transparent],
          center: const Alignment(-0.4, -0.4),
        ).createShader(Rect.fromCircle(center: pos, radius: pocketRadius));
      canvas.drawCircle(pos, pocketRadius, sheenPaint);
    }
  }

  void _drawStrikerZone(Canvas canvas, double s, double scale) {
    const margin = 28.0;
    final playSize = s - margin * 2;

    // Player 1 zone (bottom) - highlight if current
    final p1ZoneY = s - margin - playSize * 0.165;
    final p2ZoneY = margin + playSize * 0.165;

    final zoneWidth = playSize * 0.33;
    final zoneX = s / 2 - zoneWidth / 2;

    final p1Active = currentPlayer == 1;

    final zonePaint1 = Paint()
      ..color = (p1Active ? AppColors.player1Color : Colors.white).withOpacity(p1Active ? 0.15 : 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(zoneX, p1ZoneY - 15, zoneWidth, 15), zonePaint1);

    final zonePaint2 = Paint()
      ..color = (!p1Active ? AppColors.player2Color : Colors.white).withOpacity(!p1Active ? 0.15 : 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(zoneX, p2ZoneY, zoneWidth, 15), zonePaint2);
  }

  void _drawAimLine(Canvas canvas, double s, double scale) {
    if (striker.x == 0 && striker.y == 0) return;

    final sx = striker.x * scale + 28;
    final sy = striker.y * scale + 28;

    final angle = (aimAngle! * pi / 180);
    final dx = cos(angle);
    final dy = sin(angle);

    // Draw dotted aim line
    final aimPaint = Paint()
      ..color = AppColors.gold.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const segLen = 8.0;
    const gapLen = 5.0;
    double dist = 0;
    final maxDist = 120.0 + power * 80;
    bool draw = true;

    double cx = sx, cy = sy;
    while (dist < maxDist) {
      final nextDist = dist + (draw ? segLen : gapLen);
      final nx = sx + dx * min(nextDist, maxDist);
      final ny = sy + dy * min(nextDist, maxDist);
      if (draw) {
        canvas.drawLine(Offset(cx, cy), Offset(nx, ny), aimPaint);
      }
      cx = nx;
      cy = ny;
      dist = nextDist;
      draw = !draw;
    }

    // Arrowhead
    final arrowPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;
    final arrowX = sx + dx * maxDist;
    final arrowY = sy + dy * maxDist;
    final path = Path();
    const arrowSize = 8.0;
    path.moveTo(arrowX + dx * arrowSize, arrowY + dy * arrowSize);
    path.lineTo(
        arrowX + (-dy) * arrowSize * 0.5, arrowY + dx * arrowSize * 0.5);
    path.lineTo(
        arrowX + dy * arrowSize * 0.5, arrowY + (-dx) * arrowSize * 0.5);
    path.close();
    canvas.drawPath(path, arrowPaint);

    // Power indicator circle around striker
    final powerPaint = Paint()
      ..color = Color.lerp(Colors.green, Colors.red, power)!.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final strikerR = GameConfig.strikerRadius * scale;
    canvas.drawCircle(Offset(sx, sy), strikerR + 4 + power * 6, powerPaint);
  }

  void _drawPieces(Canvas canvas, double s, double scale) {
    for (final piece in pieces) {
      if (!piece.active) continue;
      _drawSinglePiece(canvas, piece, scale);
    }
  }

  void _drawSinglePiece(Canvas canvas, PieceData piece, double scale) {
    final px = piece.x * scale + 28;
    final py = piece.y * scale + 28;
    final r = GameConfig.coinRadius * scale;

    Color baseColor;
    Color topColor;
    Color borderColor;

    switch (piece.type) {
      case 'black':
        baseColor = const Color(0xFF1A1A1A);
        topColor = const Color(0xFF3A3A3A);
        borderColor = const Color(0xFF555555);
        break;
      case 'white':
        baseColor = const Color(0xFFE8E0D0);
        topColor = const Color(0xFFFFF8F0);
        borderColor = const Color(0xFFCCBB99);
        break;
      case 'queen':
        baseColor = const Color(0xFFCC0000);
        topColor = const Color(0xFFFF3333);
        borderColor = const Color(0xFFFFD700);
        break;
      default:
        baseColor = Colors.grey;
        topColor = Colors.grey.shade300;
        borderColor = Colors.grey.shade700;
    }

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(px + 2, py + 2), r, shadowPaint);

    // Base
    final basePaint = Paint()
      ..shader = RadialGradient(
        colors: [topColor, baseColor],
        center: const Alignment(-0.3, -0.3),
        radius: 1.0,
      ).createShader(Rect.fromCircle(center: Offset(px, py), radius: r));
    canvas.drawCircle(Offset(px, py), r, basePaint);

    // Border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(px, py), r, borderPaint);

    // Inner ring design
    final innerRingPaint = Paint()
      ..color = borderColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(Offset(px, py), r * 0.65, innerRingPaint);

    // Shine
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(piece.type == 'black' ? 0.15 : 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(px - r * 0.3, py - r * 0.3), r * 0.25, shinePaint);

    // Queen crown symbol
    if (piece.type == 'queen') {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '♛',
          style: TextStyle(
            fontSize: r * 0.8,
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(px - textPainter.width / 2, py - textPainter.height / 2),
      );
    }
  }

  void _drawStriker(Canvas canvas, double s, double scale) {
    if (striker.x == 0 && striker.y == 0) return;

    final sx = striker.x * scale + 28;
    final sy = striker.y * scale + 28;
    final r = GameConfig.strikerRadius * scale;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(sx + 2, sy + 2), r, shadowPaint);

    // Gold body
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.goldLight, AppColors.gold, AppColors.strikerBorder],
        center: const Alignment(-0.3, -0.4),
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(sx, sy), radius: r));
    canvas.drawCircle(Offset(sx, sy), r, bodyPaint);

    // Border
    final borderPaint = Paint()
      ..color = AppColors.strikerBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(sx, sy), r, borderPaint);

    // Inner rings
    final innerPaint = Paint()
      ..color = AppColors.strikerBorder.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(sx, sy), r * 0.7, innerPaint);
    canvas.drawCircle(Offset(sx, sy), r * 0.4, innerPaint);

    // Center dot
    canvas.drawCircle(
        Offset(sx, sy), r * 0.12, Paint()..color = AppColors.strikerBorder);

    // Shine
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sx - r * 0.3, sy - r * 0.3), r * 0.2, shinePaint);
  }

  @override
  bool shouldRepaint(CarromBoardPainter oldDelegate) => true;
}

class PieceData {
  final double x, y;
  final String type; // 'black', 'white', 'queen'
  final bool active;
  final int id;

  PieceData({
    required this.x,
    required this.y,
    required this.type,
    this.active = true,
    required this.id,
  });

  PieceData copyWith({double? x, double? y, bool? active}) {
    return PieceData(
      x: x ?? this.x,
      y: y ?? this.y,
      type: type,
      active: active ?? this.active,
      id: id,
    );
  }
}

class StrikerData {
  final double x, y;
  StrikerData({required this.x, required this.y});
  static StrikerData zero() => StrikerData(x: 0, y: 0);
}