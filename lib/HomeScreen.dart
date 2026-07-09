import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'GameScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _contentController;
  late Animation<double> _contentAnim;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentAnim = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutBack,
    );
    _contentController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (_, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  sin(_bgController.value * 2 * pi) * 0.3,
                  cos(_bgController.value * 2 * pi) * 0.3,
                ),
                radius: 1.5,
                colors: const [
                  Color(0xFF3D1A00),
                  Color(0xFF1A0A00),
                  Color(0xFF0D0500),
                ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _contentAnim,
            builder: (_, __) {
              return Opacity(
                opacity: _contentAnim.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.8 + _contentAnim.value * 0.2,
                  child: _buildContent(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildLogo(),
            const SizedBox(height: 24),
            _buildBoardPreview(),
            const SizedBox(height: 24),
            _buildPlayButton(),
            const SizedBox(height: 20),
            _buildSecondaryButtons(),
            const SizedBox(height: 20),
            _buildRules(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFE44D), Color(0xFFFFD700), Color(0xFFB8860B)],
          ).createShader(bounds),
          child: Text(
            'CARROM KING',
            style: GoogleFonts.cinzel(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '♟  The Classic Board Experience  ♟',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildBoardPreview() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (_, __) {
        return Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CustomPaint(painter: _HomeBoardPainter(_bgController.value)),
        );
      },
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const GameScreen(),
            transitionsBuilder: (_, anim, __, child) {
              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                    ),
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_esports_rounded,
              color: Colors.black87,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'PLAY NOW',
              style: GoogleFonts.cinzel(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButtons() {
    return Row(
      children: [
        _secondaryBtn(Icons.emoji_events_outlined, '2 PLAYER', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GameScreen()),
          );
        }),
        const SizedBox(width: 12),
        _secondaryBtn(Icons.info_outline, 'RULES', () {
          _showRulesDialog();
        }),
      ],
    );
  }

  Widget _secondaryBtn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFFFD700), size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFD700),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRules() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Text(
            'HOW TO PLAY',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _ruleItem('🎯', 'Drag aim line to set direction'),
          _ruleItem('⚡', 'Set power with the slider'),
          _ruleItem('♟', 'Tap FLICK to shoot striker'),
          _ruleItem('♛', 'Pot Queen + cover = 3 pts'),
          _ruleItem('⚫', 'Own coins = 1pt each'),
        ],
      ),
    );
  }

  Widget _ruleItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showRulesDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2D1500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3)),
        ),
        title: Text(
          'Game Rules',
          style: GoogleFonts.cinzel(color: const Color(0xFFFFD700)),
        ),
        content: Text(
          '• Each player takes turns flicking the striker\n'
          '• Pot your own color coins (Black=P1, White=P2)\n'
          '• Queen (red) = 3 points, must be covered\n'
          '• Potting opponent\'s coin = 1pt penalty\n'
          '• Potting striker = scratch, opponent +1pt\n'
          '• First to 25 points wins!',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            height: 1.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'GOT IT',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBoardPainter extends CustomPainter {
  final double anim;

  _HomeBoardPainter(this.anim);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final s = size.width;

    // Board background
    final boardPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFFD4A055), const Color(0xFF8B5E2A)],
      ).createShader(Rect.fromLTWH(0, 0, s, s));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s, s),
        const Radius.circular(16),
      ),
      boardPaint,
    );

    const m = 18.0;

    // Surface
    canvas.drawRect(
      Rect.fromLTWH(m, m, s - m * 2, s - m * 2),
      Paint()..color = const Color(0xFFBF8C35),
    );

    // Diagonals
    final lp = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1;
    canvas.drawLine(Offset(m, m), center, lp);
    canvas.drawLine(Offset(s - m, m), center, lp);
    canvas.drawLine(Offset(s - m, s - m), center, lp);
    canvas.drawLine(Offset(m, s - m), center, lp);

    // Circles
    canvas.drawCircle(
      center,
      s * 0.14,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Pockets
    for (final corner in [
      Offset(m, m),
      Offset(s - m, m),
      Offset(s - m, s - m),
      Offset(m, s - m),
    ]) {
      canvas.drawCircle(corner, 13, Paint()..color = const Color(0xFF0D0500));
      canvas.drawCircle(
        corner,
        13,
        Paint()
          ..color = const Color(0xFF3D1F00)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Rotating pieces
    const r = 42.0;
    final pieceTypes = [
      'black',
      'white',
      'black',
      'white',
      'black',
      'white',
      'queen',
    ];
    for (int i = 0; i < pieceTypes.length; i++) {
      final angle =
          (i / (pieceTypes.length - 1)) * 2 * pi + anim * 2 * pi * 0.5;
      final px = center.dx + cos(angle) * r;
      final py = center.dy + sin(angle) * r;
      Color c;
      switch (pieceTypes[i]) {
        case 'queen':
          c = const Color(0xFFCC0000);
          break;
        case 'white':
          c = const Color(0xFFF5F0E8);
          break;
        default:
          c = const Color(0xFF1A1A1A);
      }
      canvas.drawCircle(Offset(px, py), 9, Paint()..color = c);
      canvas.drawCircle(
        Offset(px, py),
        9,
        Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // Center queen
    canvas.drawCircle(center, 11, Paint()..color = const Color(0xFFCC0000));
    canvas.drawCircle(
      center,
      11,
      Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_HomeBoardPainter old) => old.anim != anim;
}
