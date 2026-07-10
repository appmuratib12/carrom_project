import 'dart:math';

import 'app_colors.dart';


class Vec2 {
  double x, y;
  Vec2(this.x, this.y);
  Vec2 operator +(Vec2 o) => Vec2(x + o.x, y + o.y);
  Vec2 operator -(Vec2 o) => Vec2(x - o.x, y - o.y);
  Vec2 operator *(double s) => Vec2(x * s, y * s);
  double dot(Vec2 o) => x * o.x + y * o.y;
  double get length => sqrt(x * x + y * y);
  Vec2 get normalized => length > 0 ? Vec2(x / length, y / length) : Vec2(0, 0);
  Vec2 get copy => Vec2(x, y);
}

class PhysicsPiece {
  int id;
  String type;
  Vec2 pos;
  Vec2 vel;
  bool active;
  double radius;
  double friction;
  double restitution;

  PhysicsPiece({
    required this.id,
    required this.type,
    required this.pos,
    Vec2? vel,
    this.active = true,
  })  : vel = vel ?? Vec2(0, 0),
        radius = type == 'striker'
            ? GameConfig.strikerRadius
            : GameConfig.coinRadius,
        friction = type == 'striker'
            ? GameConfig.strikerFriction
            : GameConfig.coinFriction,
        restitution = GameConfig.restitution;
}

class PhysicsEngine {
  static const double worldMin = 0.0;
  static const double worldMax = GameConfig.worldSize;
  static const double wallRestitution = 0.65;
  static const double dt = 1 / 60.0;

  // FIX: Pockets sit AT the corners of the play surface (margin = 0.28 world units)
  // They must be reachable — pieces should fall IN before hitting the wall boundary
  static const double pocketMargin = 0.28;
  static const double pocketCatchRadius = 0.55; // generous catch zone
  static final List<Vec2> pockets = [
    Vec2(pocketMargin, pocketMargin),
    Vec2(worldMax - pocketMargin, pocketMargin),
    Vec2(worldMax - pocketMargin, worldMax - pocketMargin),
    Vec2(pocketMargin, worldMax - pocketMargin),
  ];

  List<PhysicsPiece> pieces;
  PhysicsPiece striker;
  Function(int pieceId, bool isStriker)? onPiecePotted;

  PhysicsEngine({required this.pieces, required this.striker});

  bool get anyMoving {
    if (striker.active && striker.vel.length > 0.02) return true;
    return pieces.any((p) => p.active && p.vel.length > 0.02);
  }

  void applyStrikerImpulse(double angle, double power) {
    final rad = angle * pi / 180;
    final speed = GameConfig.minStrikerImpulse +
        power * (GameConfig.maxStrikerImpulse - GameConfig.minStrikerImpulse);
    striker.vel = Vec2(cos(rad) * speed, sin(rad) * speed);
  }

  void step() {
    // Check pockets BEFORE wall bounce so fast pieces don't bounce away from pocket
    _checkPocketForPiece(striker, isStriker: true);
    for (final piece in pieces) {
      if (!piece.active) continue;
      _checkPocketForPiece(piece, isStriker: false);
    }

    // Update positions
    _updatePiece(striker);
    for (final piece in pieces) {
      if (!piece.active) continue;
      _updatePiece(piece);
    }

    // Check pockets again after movement (catches pieces that slid in slowly)
    _checkPocketForPiece(striker, isStriker: true);
    for (final piece in pieces) {
      if (!piece.active) continue;
      _checkPocketForPiece(piece, isStriker: false);
    }

    // Collisions: striker vs pieces
    for (final piece in pieces) {
      if (!piece.active) continue;
      _resolveCircleCollision(striker, piece);
    }

    // Piece vs piece collisions
    for (int i = 0; i < pieces.length; i++) {
      if (!pieces[i].active) continue;
      for (int j = i + 1; j < pieces.length; j++) {
        if (!pieces[j].active) continue;
        _resolveCircleCollision(pieces[i], pieces[j]);
      }
    }
  }

  void _updatePiece(PhysicsPiece piece) {
    if (!piece.active) return;
    if (piece.vel.length < 0.01) {
      piece.vel = Vec2(0, 0);
      return;
    }

    // Apply friction
    final frictionForce = piece.friction * dt;
    final speed = piece.vel.length;
    final newSpeed = (speed - frictionForce).clamp(0.0, double.infinity);
    piece.vel = piece.vel.normalized * newSpeed;

    // Move
    piece.pos = piece.pos + piece.vel * dt;

    // FIX: Wall boundaries — leave a gap at corners so pieces can enter pockets.
    // Near a corner pocket: skip wall bounce and let pocket detection handle it.
    final r = piece.radius;
    const wallMin = 0.28;
    const wallMax = GameConfig.worldSize - 0.28;
    const cornerZone = 0.8; // within this distance of corner, skip wall bounce

    final nearCorner = _isNearCorner(piece.pos, cornerZone);

    if (!nearCorner) {
      // Normal wall bounce
      if (piece.pos.x - r < wallMin) {
        piece.pos.x = wallMin + r;
        piece.vel.x = piece.vel.x.abs() * wallRestitution;
      } else if (piece.pos.x + r > wallMax) {
        piece.pos.x = wallMax - r;
        piece.vel.x = -piece.vel.x.abs() * wallRestitution;
      }

      if (piece.pos.y - r < wallMin) {
        piece.pos.y = wallMin + r;
        piece.vel.y = piece.vel.y.abs() * wallRestitution;
      } else if (piece.pos.y + r > wallMax) {
        piece.pos.y = wallMax - r;
        piece.vel.y = -piece.vel.y.abs() * wallRestitution;
      }
    } else {
      // Near corner: only bounce off the far wall sides, not into the pocket
      // Allow piece to slide into the pocket zone
      if (piece.pos.x < wallMin - r * 2 || piece.pos.x > wallMax + r * 2 ||
          piece.pos.y < wallMin - r * 2 || piece.pos.y > wallMax + r * 2) {
        // Piece completely out of bounds — hard clamp
        piece.pos.x = piece.pos.x.clamp(wallMin, wallMax);
        piece.pos.y = piece.pos.y.clamp(wallMin, wallMax);
        piece.vel = Vec2(0, 0);
      }
    }
  }

  bool _isNearCorner(Vec2 pos, double zone) {
    for (final pocket in pockets) {
      if ((pos - pocket).length < zone) return true;
    }
    return false;
  }

  void _resolveCircleCollision(PhysicsPiece a, PhysicsPiece b) {
    if (!a.active || !b.active) return;
    final diff = b.pos - a.pos;
    final dist = diff.length;
    final minDist = a.radius + b.radius;

    if (dist >= minDist || dist < 0.001) return;

    // Separate
    final normal = diff.normalized;
    final overlap = minDist - dist;
    a.pos = a.pos - normal * (overlap * 0.5);
    b.pos = b.pos + normal * (overlap * 0.5);

    // Exchange velocity along normal (elastic collision)
    final relVel = a.vel - b.vel;
    final velAlongNormal = relVel.dot(normal);
    if (velAlongNormal > 0) return; // already separating

    const e = 0.80;
    final j = -(1 + e) * velAlongNormal / 2;
    final impulse = normal * j;

    a.vel = a.vel - impulse;
    b.vel = b.vel + impulse;

    // Friction between pieces
    const pieceFriction = 0.02;
    final tangent = Vec2(-normal.y, normal.x);
    final velTangent = relVel.dot(tangent);
    final frictionImpulse = tangent * (-velTangent * pieceFriction);
    a.vel = a.vel + frictionImpulse;
    b.vel = b.vel - frictionImpulse;
  }

  void _checkPocketForPiece(PhysicsPiece piece, {required bool isStriker}) {
    if (!piece.active) return;
    for (final pocket in pockets) {
      final dist = (piece.pos - pocket).length;
      // Use generous catch radius so pieces visually enter the pocket hole
      if (dist < pocketCatchRadius) {
        piece.active = false;
        piece.vel = Vec2(0, 0);
        onPiecePotted?.call(piece.id, isStriker);
        return;
      }
    }
  }

  // Utility: initial positions for pieces
  static List<Vec2> getInitialPiecePositions() {
    const center = 5.0;
    const d = 0.5; // spacing between pieces
    return [
      // Center queen position (id=0, handled separately)
      Vec2(center, center),
      // Inner ring (6 pieces alternating)
      Vec2(center, center - d),
      Vec2(center + d * sin(60 * pi / 180), center - d * cos(60 * pi / 180)),
      Vec2(center + d * sin(60 * pi / 180), center + d * cos(60 * pi / 180)),
      Vec2(center, center + d),
      Vec2(center - d * sin(60 * pi / 180), center + d * cos(60 * pi / 180)),
      Vec2(center - d * sin(60 * pi / 180), center - d * cos(60 * pi / 180)),
      // Outer ring (12 pieces)
      Vec2(center, center - d * 2),
      Vec2(center + d * 2 * sin(30 * pi / 180), center - d * 2 * cos(30 * pi / 180)),
      Vec2(center + d * 2 * sin(60 * pi / 180), center - d * 2 * cos(60 * pi / 180)),
      Vec2(center + d * 2 * sin(90 * pi / 180), center - d * 2 * cos(90 * pi / 180)),
      Vec2(center + d * 2 * sin(120 * pi / 180), center - d * 2 * cos(120 * pi / 180)),
      Vec2(center + d * 2 * sin(150 * pi / 180), center - d * 2 * cos(150 * pi / 180)),
      Vec2(center, center + d * 2),
      Vec2(center - d * 2 * sin(30 * pi / 180), center + d * 2 * cos(30 * pi / 180)),
      Vec2(center - d * 2 * sin(60 * pi / 180), center + d * 2 * cos(60 * pi / 180)),
      Vec2(center - d * 2 * sin(90 * pi / 180), center + d * 2 * cos(90 * pi / 180)),
      Vec2(center - d * 2 * sin(120 * pi / 180), center + d * 2 * cos(120 * pi / 180)),
      Vec2(center - d * 2 * sin(150 * pi / 180), center + d * 2 * cos(150 * pi / 180)),
    ];
  }
}