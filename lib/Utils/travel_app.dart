import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // Controllers
  late final AnimationController _bgController;
  late final AnimationController _planeController;
  late final AnimationController _cardsController;
  late final AnimationController _formController;
  late final AnimationController _pathController;
  late final AnimationController _floatController;

  // Animations
  late final Animation<double> _planePath;
  late final Animation<double> _formSlide;
  late final Animation<double> _formFade;
  late final Animation<double> _pathDraw;
  late final Animation<double> _floatAnim;
  late final Animation<double> _card1Fade;
  late final Animation<double> _card2Fade;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();

    _pathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pathDraw = CurvedAnimation(parent: _pathController, curve: Curves.easeInOut);

    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _planePath = CurvedAnimation(parent: _planeController, curve: Curves.easeInOut);

    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _card1Fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardsController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _card2Fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardsController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _formSlide = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOut),
    );
    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Sequence the entrance animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _pathController.forward();
      _planeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      _cardsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _planeController.dispose();
    _cardsController.dispose();
    _formController.dispose();
    _pathController.dispose();
    _floatController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        children: [
          _buildBackground(size),
          AnimatedBuilder(
            animation: _pathDraw,
            builder: (_, _) => CustomPaint(
              size: size,
              painter: FlightPathPainter(_pathDraw.value),
            ),
          ),
          AnimatedBuilder(
            animation: _planePath,
            builder: (_, child) {
              final t = _planePath.value;
              final pos = _getPlanePosition(size, t);
              final angle = _getPlaneAngle(size, t);
              return Positioned(
                left: pos.dx - 16,
                top: pos.dy - 10,
                child: Transform.rotate(
                  angle: angle,
                  child: Opacity(
                    opacity: t < 0.05 ? t / 0.05 : (t > 0.95 ? (1 - t) / 0.05 : 1),
                    child: child,
                  ),
                ),
              );
            },
            child: const Icon(Icons.airplanemode_active, color: Color(0xFFFFD166), size: 32),
          ),
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (_, _) {
              return Stack(
                children: [
                  // Card 1 – top left
                  Positioned(
                    top: size.height * 0.12 + _floatAnim.value * 0.5,
                    left: 24,
                    child: FadeTransition(
                      opacity: _card1Fade,
                      child: _buildDestinationCard(
                        '🗼', 'Paris', 'France', const Color(0xFF7B9EA8),
                      ),
                    ),
                  ),
                  // Card 2 – top right
                  Positioned(
                    top: size.height * 0.08 - _floatAnim.value * 0.5,
                    right: 24,
                    child: FadeTransition(
                      opacity: _card2Fade,
                      child: _buildDestinationCard(
                        '🏯', 'Kyoto', 'Japan', const Color(0xFF8E6B7A),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: _formController,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, _formSlide.value),
                child: Opacity(opacity: _formFade.value, child: child),
              ),
              child: _buildFormPanel(size),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D1B2A), // deep navy
            Color(0xFF1A3A5C), // ocean blue
            Color(0xFF2E5F7A), // teal horizon
            Color(0xFF1A2D3D), // dark base
          ],
          stops: [0.0, 0.35, 0.65, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Stars
          ...List.generate(40, (i) {
            final r = Random(i * 137 + 7);
            return Positioned(
              top: r.nextDouble() * size.height * 0.55,
              left: r.nextDouble() * size.width,
              child: Container(
                width: r.nextDouble() * 2.5 + 0.5,
                height: r.nextDouble() * 2.5 + 0.5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(r.nextDouble() * 0.6 + 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          // Horizon glow
          Positioned(
            bottom: size.height * 0.38,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x22FF6B6B),
                    Color(0x44FFD166),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Silhouette landscape
          Positioned(
            bottom: size.height * 0.33,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(size.width, 90),
              painter: LandscapePainter(),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDestinationCard(
      String emoji, String city, String country, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(city,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3)),
              Text(country,
                  style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 10,
                      fontWeight:FontWeight.w500,
                      letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildFormPanel(Size size) {
    return Container(
      width: size.width,
      constraints: BoxConstraints(maxHeight: size.height * 0.68),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F2437),
            Color(0xFF081726),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          28, 20, 28, MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Brand mark
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFFD166)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flight_takeoff_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                 Text(
                  'WANDERLUST',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tagline
            RichText(
              text: TextSpan(
                style: TextStyle(height: 1.2),
                children: [
                  TextSpan(
                    text: 'Your next\n',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  TextSpan(
                    text: 'adventure',
                    style: GoogleFonts.poppins(
                      color: Color(0xFFFFD166),
                      fontSize: 34,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' awaits.',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Email Field
            _buildTextField(
              controller: _emailCtrl,
              hint: 'Email address',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),

            // Password Field
            _buildTextField(
              controller: _passCtrl,
              hint: 'Password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscurePass,
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscurePass = !_obscurePass),
                child: Icon(
                  _obscurePass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white38,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Remember me + Forgot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _rememberMe
                              ? const Color(0xFFFF6B6B)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _rememberMe
                                ? const Color(0xFFFF6B6B)
                                : Colors.white38,
                            width: 1.5,
                          ),
                        ),
                        child: _rememberMe
                            ? const Icon(Icons.check, size: 13, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Forgot password?',
                  style: const TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sign In Button
            _buildSignInButton(),
            const SizedBox(height: 18),

            // Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'or continue with',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
              ],
            ),
            const SizedBox(height: 18),

            // Social Buttons
            Row(
              children: [
                Expanded(child: _buildSocialButton('G', 'Google', const Color(0xFF4285F4))),
                const SizedBox(width: 12),
                Expanded(child: _buildSocialButton('f', 'Facebook', const Color(0xFF1877F2))),
                const SizedBox(width: 12),
                Expanded(child: _buildSocialButton('⌘', 'Apple', const Color(0xFFCCCCCC))),
              ],
            ),
            const SizedBox(height: 22),

            // Sign Up
            Center(
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Don't have an account?  ",
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                        color: Color(0xFFFFD166),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 15,fontWeight:FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8C42)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign In',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, String name, Color color) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.09), width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: label == '⌘' ? 18 : 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ── Plane Path Helpers ────────────────────
  Offset _getPlanePosition(Size size, double t) {
    // Bezier curve from bottom-left to top-right
    const p0 = Offset(0.15, 0.70);
    const p1 = Offset(0.30, 0.10);
    const p2 = Offset(0.70, 0.25);
    const p3 = Offset(0.88, 0.52);

    final x = _cubic(p0.dx, p1.dx, p2.dx, p3.dx, t);
    final y = _cubic(p0.dy, p1.dy, p2.dy, p3.dy, t);
    return Offset(x * size.width, y * size.height);
  }

  double _getPlaneAngle(Size size, double t) {
    final dt = 0.01;
    final t2 = (t + dt).clamp(0.0, 1.0);
    final p1 = _getPlanePosition(size, t);
    final p2 = _getPlanePosition(size, t2);
    return atan2(p2.dy - p1.dy, p2.dx - p1.dx);
  }

  double _cubic(double p0, double p1, double p2, double p3, double t) {
    return pow(1 - t, 3) * p0 +
        3 * pow(1 - t, 2) * t * p1 +
        3 * (1 - t) * t * t * p2 +
        t * t * t * p3;
  }
}

// ─────────────────────────────────────────────
//  FLIGHT PATH PAINTER
// ─────────────────────────────────────────────
class FlightPathPainter extends CustomPainter {
  final double progress;
  FlightPathPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.70);
    path.cubicTo(
      size.width * 0.30, size.height * 0.10,
      size.width * 0.70, size.height * 0.25,
      size.width * 0.88, size.height * 0.52,
    );

    final pathMetrics = path.computeMetrics().first;
    final extractPath =
    pathMetrics.extractPath(0, pathMetrics.length * progress);

    // Glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD166).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(extractPath, glowPaint);

    // Dashed trail
    final dashPaint = Paint()
      ..color = const Color(0xFFFFD166).withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    _drawDashedPath(canvas, extractPath, dashPaint, 8, 6);

    // Origin dot
    if (progress > 0.02) {
      canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.70),
        5,
        Paint()..color = const Color(0xFFFF6B6B),
      );
      canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.70),
        9,
        Paint()
          ..color = const Color(0xFFFF6B6B).withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawDashedPath(
      Canvas canvas, Path path, Paint paint, double dash, double gap) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(FlightPathPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────
//  LANDSCAPE SILHOUETTE PAINTER
// ─────────────────────────────────────────────
class LandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0A1820)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    // Mountains
    path.lineTo(0, size.height * 0.6);
    path.lineTo(size.width * 0.05, size.height * 0.3);
    path.lineTo(size.width * 0.12, size.height * 0.55);
    path.lineTo(size.width * 0.18, size.height * 0.15); // tall peak
    path.lineTo(size.width * 0.25, size.height * 0.50);
    path.lineTo(size.width * 0.32, size.height * 0.35);
    path.lineTo(size.width * 0.40, size.height * 0.60);
    path.lineTo(size.width * 0.48, size.height * 0.20); // another peak
    path.lineTo(size.width * 0.56, size.height * 0.55);
    path.lineTo(size.width * 0.64, size.height * 0.40);
    path.lineTo(size.width * 0.72, size.height * 0.65);
    path.lineTo(size.width * 0.80, size.height * 0.30);
    path.lineTo(size.width * 0.88, size.height * 0.58);
    path.lineTo(size.width * 0.95, size.height * 0.42);
    path.lineTo(size.width, size.height * 0.60);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Snow caps
    final snowPaint = Paint()
      ..color = const Color(0xFF1E3A50).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    void drawSnowCap(double tipX, double tipY, double width) {
      final snowPath = Path();
      snowPath.moveTo(tipX, tipY);
      snowPath.lineTo(tipX - width, tipY + width * 1.2);
      snowPath.lineTo(tipX + width, tipY + width * 1.2);
      snowPath.close();
      canvas.drawPath(snowPath, snowPaint);
    }

    drawSnowCap(size.width * 0.18, size.height * 0.15, size.width * 0.025);
    drawSnowCap(size.width * 0.48, size.height * 0.20, size.width * 0.025);
    drawSnowCap(size.width * 0.80, size.height * 0.30, size.width * 0.02);
  }

  @override
  bool shouldRepaint(LandscapePainter _) => false;
}