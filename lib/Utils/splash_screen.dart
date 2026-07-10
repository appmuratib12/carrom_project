import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../Appconstant/app_colors.dart';
import 'onboarding_screen.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _exitController;

  late Animation<double> _bgScale;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _bgScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeOutCubic),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.4)),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));

    _exitScale = Tween<double>(begin: 1.0, end: 20.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _bgController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    await _exitController.forward();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const OnboardingScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.forestGreen,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _bgController,
          _logoController,
          _particleController,
          _textController,
          _exitController,
        ]),
        builder: (context, _) {
          return Stack(
            children: [
              // Background gradient blob
              Positioned.fill(
                child: CustomPaint(
                  painter: BlobPainter(
                    progress: _bgScale.value,
                    animValue: _particleController.value,
                  ),
                ),
              ),
              // Floating emoji particles
              ..._buildParticles(size),
              // Center content
              Center(
                child: Transform.scale(
                  scale: _exitController.isAnimating
                      ? _exitScale.value
                      : 1.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo circle
                      Opacity(
                        opacity: _exitController.isAnimating
                            ? (1.0 - _exitController.value / 20).clamp(0, 1)
                            : _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkGreen.withValues(alpha: 0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '🛒',
                                style: TextStyle(fontSize: 52),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // App name
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textOpacity,
                          child: Column(
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Fresh',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.white,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Cart',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.citrus,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Farm to your door 🌿',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.lightMint,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildParticles(Size size) {
    final emojis = ['🥦', '🍎', '🥕', '🍋', '🥑', '🍓', '🌽', '🍇'];
    final random = math.Random(42);
    return List.generate(12, (i) {
      final t = (_particleController.value + i / 12) % 1.0;
      final x = random.nextDouble() * size.width;
      final startY = size.height + 30;
      final endY = -30.0;
      final y = startY + (endY - startY) * t;
      final opacity = (math.sin(t * math.pi)).clamp(0.0, 1.0);
      final wobble = math.sin(t * math.pi * 4 + i) * 20;
      return Positioned(
        left: x + wobble,
        top: y,
        child: Opacity(
          opacity: opacity * 0.6,
          child: Text(
            emojis[i % emojis.length],
            style: const TextStyle(fontSize: 22),
          ),
        ),
      );
    });
  }
}

class BlobPainter extends CustomPainter {
  final double progress;
  final double animValue;

  BlobPainter({required this.progress, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1B4332),
          const Color(0xFF2D6A4F),
          const Color(0xFF40916C),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (progress == 0) return;

    // Top right blob
    _drawBlob(
      canvas,
      Offset(size.width * 0.85, size.height * 0.1),
      size.width * 0.45 * progress,
      const Color(0xFF52B788).withValues(alpha: 0.25),
      animValue,
    );

    // Bottom left blob
    _drawBlob(
      canvas,
      Offset(size.width * 0.1, size.height * 0.88),
      size.width * 0.5 * progress,
      const Color(0xFF40916C).withValues(alpha: 0.35),
      animValue + 0.5,
    );

    // Small accent blob
    _drawBlob(
      canvas,
      Offset(size.width * 0.15, size.height * 0.2),
      size.width * 0.2 * progress,
      const Color(0xFFF4A261).withValues(alpha: 0.15),
      animValue + 0.25,
    );
  }

  void _drawBlob(Canvas canvas, Offset center, double radius, Color color, double t) {
    final paint = Paint()..color = color;
    final path = Path();
    const points = 8;
    for (int i = 0; i <= points; i++) {
      final angle = (i / points) * math.pi * 2;
      final wobble = 1.0 + 0.15 * math.sin(angle * 3 + t * math.pi * 2);
      final r = radius * wobble;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BlobPainter old) =>
      old.progress != progress || old.animValue != animValue;
}
