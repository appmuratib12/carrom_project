import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _bgCircleController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _taglineController;

  // Animations
  late Animation<double> _bgCircleScale;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulse;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();

    // Background expanding circle
    _bgCircleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _bgCircleScale = CurvedAnimation(
      parent: _bgCircleController,
      curve: Curves.easeOutExpo,
    );

    // Logo entrance
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // App name text
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Tagline
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOutCubic),
    );

    // Floating particle orbs
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Pulse ring around logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: false);
    _pulse = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Sequence
    _bgCircleController.forward().then((_) {
      _logoController.forward().then((_) {
        _textController.forward().then((_) {
          _taglineController.forward();
        });
      });
    });
  }

  @override
  void dispose() {
    _bgCircleController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // warm cream
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ── Decorative background blobs ──────────────────
          _BackgroundBlobs(size: size),

          // ── Expanding circle burst ───────────────────────
          AnimatedBuilder(
            animation: _bgCircleScale,
            builder: (_, __) => Transform.scale(
              scale: _bgCircleScale.value,
              child: Container(
                width: size.width * 1.6,
                height: size.width * 1.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF56C569).withOpacity(0.18),
                      const Color(0xFFFFF8F0).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Floating fruit particles ─────────────────────
          _FloatingParticles(
            controller: _particleController,
            size: size,
          ),

          // ── Core content ─────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with pulse ring
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, child) => Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulse ring
                    Transform.scale(
                      scale: _pulse.value,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(
                              0.15 * (2 - _pulse.value),
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    child!,
                  ],
                ),
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: SlideTransition(
                    position: _logoSlide,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: _LogoBadge(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // App name
              FadeTransition(
                opacity: _textOpacity,
                child: SlideTransition(
                  position: _textSlide,
                  child: Column(
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Fresh',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                                letterSpacing: -1,
                              ),
                            ),
                            TextSpan(
                              text: 'Cart',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4CAF50),
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Tagline
              FadeTransition(
                opacity: _taglineOpacity,
                child: SlideTransition(
                  position: _taglineSlide,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      '🌿  Fresh Groceries, Delivered Fast',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF388E3C),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom loading dots ──────────────────────────
          Positioned(
            bottom: 60,
            child: FadeTransition(
              opacity: _taglineOpacity,
              child: const _LoadingDots(),
            ),
          ),

          // ── Bottom brand line ────────────────────────────
          Positioned(
            bottom: 28,
            child: FadeTransition(
              opacity: _taglineOpacity,
              child: const Text(
                'Farm to Doorstep',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Color(0xFFADADAD),
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOGO BADGE
// ─────────────────────────────────────────────
class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.45),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.2),
            blurRadius: 60,
            spreadRadius: 10,
            offset: Offset.zero,
          ),
        ],
      ),
      child: const Center(
        child: _LeafForkSpoonIcon(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SVG-STYLE ICON (drawn with CustomPaint)
// ─────────────────────────────────────────────
class _LeafForkSpoonIcon extends StatelessWidget {
  const _LeafForkSpoonIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: CustomPaint(painter: _IconPainter()),
    );
  }
}

class _IconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── Leaf bowl ────────────────────────────────────────
    final leafPath = Path();
    leafPath.moveTo(cx, cy + size.height * 0.28);
    leafPath.cubicTo(
      cx - size.width * 0.42, cy + size.height * 0.1,
      cx - size.width * 0.48, cy - size.height * 0.25,
      cx, cy - size.height * 0.1,
    );
    leafPath.cubicTo(
      cx + size.width * 0.48, cy - size.height * 0.25,
      cx + size.width * 0.42, cy + size.height * 0.1,
      cx, cy + size.height * 0.28,
    );
    leafPath.close();
    canvas.drawPath(leafPath, paint);

    // ── Left vein on leaf ────────────────────────────────
    final veinPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final veinPath = Path();
    veinPath.moveTo(cx, cy + size.height * 0.26);
    veinPath.cubicTo(
      cx - size.width * 0.14, cy + size.height * 0.05,
      cx - size.width * 0.2, cy - size.height * 0.05,
      cx - size.width * 0.12, cy - size.height * 0.08,
    );
    canvas.drawPath(veinPath, veinPaint);
    final veinPath2 = Path();
    veinPath2.moveTo(cx, cy + size.height * 0.26);
    veinPath2.cubicTo(
      cx + size.width * 0.14, cy + size.height * 0.05,
      cx + size.width * 0.2, cy - size.height * 0.05,
      cx + size.width * 0.12, cy - size.height * 0.08,
    );
    canvas.drawPath(veinPath2, veinPaint);

    // ── Spoon (left) ─────────────────────────────────────
    final spoonHead = Rect.fromCenter(
      center: Offset(cx - size.width * 0.17, cy - size.height * 0.28),
      width: size.width * 0.14,
      height: size.height * 0.18,
    );
    canvas.drawOval(spoonHead, paint);
    final spoonPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.065
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - size.width * 0.17, cy - size.height * 0.19),
      Offset(cx - size.width * 0.17, cy - size.height * 0.005),
      spoonPaint,
    );

    // ── Fork (right) ─────────────────────────────────────
    final forkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round;

    // handle
    canvas.drawLine(
      Offset(cx + size.width * 0.17, cy - size.height * 0.06),
      Offset(cx + size.width * 0.17, cy + size.height * 0.0),
      forkPaint,
    );
    // tines
    final tineOffsets = [-0.085, 0.0, 0.085];
    for (final dx in tineOffsets) {
      canvas.drawLine(
        Offset(cx + size.width * (0.17 + dx * 0.6), cy - size.height * 0.20),
        Offset(cx + size.width * (0.17 + dx * 0.6), cy - size.height * 0.06),
        forkPaint,
      );
    }
    // tine connector
    final connPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx + size.width * (0.17 - 0.085 * 0.6), cy - size.height * 0.11),
      Offset(cx + size.width * (0.17 + 0.085 * 0.6), cy - size.height * 0.11),
      connPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// FLOATING FRUIT EMOJI PARTICLES
// ─────────────────────────────────────────────
class _FloatingParticles extends StatelessWidget {
  final AnimationController controller;
  final Size size;
  static const _items = [
    '🍎', '🥦', '🍋', '🥕', '🍇', '🫐', '🥑', '🍓',
  ];

  const _FloatingParticles({required this.controller, required this.size});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Stack(
          children: List.generate(_items.length, (i) {
            final t = (controller.value + i / _items.length) % 1.0;
            final angle = (i / _items.length) * 2 * math.pi;
            final radius = size.width * 0.38 + math.sin(t * 2 * math.pi) * 18;
            final x = size.width / 2 + math.cos(angle + t * math.pi * 0.3) * radius;
            final y = size.height / 2 +
                math.sin(angle + t * math.pi * 0.3) * radius * 0.7 -
                40;
            final scale = 0.7 + 0.3 * math.sin(t * 2 * math.pi + i);
            final opacity = 0.25 + 0.35 * math.sin(t * math.pi + i * 0.5).abs();

            return Positioned(
              left: x - 14,
              top: y - 14,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: scale,
                  child: Text(
                    _items[i],
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// BACKGROUND BLOBS
// ─────────────────────────────────────────────
class _BackgroundBlobs extends StatelessWidget {
  final Size size;
  const _BackgroundBlobs({required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-right mint blob
        Positioned(
          top: -size.height * 0.08,
          right: -size.width * 0.15,
          child: Container(
            width: size.width * 0.6,
            height: size.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4CAF50).withOpacity(0.08),
            ),
          ),
        ),
        // Bottom-left peach blob
        Positioned(
          bottom: -size.height * 0.06,
          left: -size.width * 0.1,
          child: Container(
            width: size.width * 0.55,
            height: size.width * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF8A65).withOpacity(0.07),
            ),
          ),
        ),
        // Centre subtle yellow
        Positioned(
          top: size.height * 0.55,
          right: size.width * 0.1,
          child: Container(
            width: size.width * 0.3,
            height: size.width * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFDD835).withOpacity(0.06),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ANIMATED LOADING DOTS
// ─────────────────────────────────────────────
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = (_ctrl.value - delay).clamp(0.0, 1.0);
            final scale = 0.6 + 0.4 * math.sin(t * math.pi);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4CAF50).withOpacity(
                      0.4 + 0.6 * scale,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}