import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../Appconstant/app_colors.dart';


class LoginScreen1 extends StatefulWidget {
  const LoginScreen1({super.key});

  @override
  State<LoginScreen1> createState() => _LoginScreen1State();
}
class _LoginScreen1State extends State<LoginScreen1> with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _floatController;
  late AnimationController _buttonController;
  late Animation<Offset> _headerSlide;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _formSlide;
  late Animation<double> _formOpacity;
  late Animation<double> _buttonScale;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );
    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.5),
      ),
    );
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _formOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.3, 0.8),
      ),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    _buttonController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    _buttonController.forward().then((_) => _buttonController.reverse());
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          // Green top wave area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (_, _) => CustomPaint(
                size: Size(size.width, size.height * 0.42),
                painter: _WavePainter(_floatController.value),
              ),
            ),
          ),

          // Floating produce on header
          ...List.generate(6, (i) {
            final emojis = ['🥦', '🍎', '🥕', '🍋', '🥑', '🍓'];
            final positions = [
              Offset(0.08, 0.06),
              Offset(0.85, 0.03),
              Offset(0.92, 0.16),
              Offset(0.05, 0.22),
              Offset(0.78, 0.25),
              Offset(0.5, 0.02),
            ];
            return AnimatedBuilder(
              animation: _floatController,
              builder: (_, _) {
                final floatY =
                    math.sin(_floatController.value * math.pi + i * 1.2) * 6;
                return Positioned(
                  left: positions[i].dx * size.width,
                  top: positions[i].dy * size.height * 0.42 + floatY,
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      emojis[i],
                      style: TextStyle(fontSize: 16 + (i % 3) * 4.0),
                    ),
                  ),
                );
              },
            );
          }),

          // Scrollable content
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height),
              child: Column(
                children: [
                  // Header area
                  SizedBox(
                    height: size.height * 0.38,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: FadeTransition(
                        opacity: _headerOpacity,
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.forestGreen.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    '🛒',
                                    style: TextStyle(fontSize: 38),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Welcome back!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Sign in to your FreshCart account',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // White form card
                  SlideTransition(
                    position: _formSlide,
                    child: FadeTransition(
                      opacity: _formOpacity,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.forestGreen.withValues(
                                alpha: 0.12,
                              ),
                              blurRadius: 40,
                              offset: const Offset(0, -8),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Social login buttons
                            Row(
                              children: [
                                Expanded(
                                  child: SocialButton(
                                    emoji: '🔍',
                                    label: 'Google',
                                    onTap: () {},
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SocialButton(
                                    emoji: '🍎',
                                    label: 'Apple',
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: AppColors.lightGrey,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  child: Text(
                                    'or continue with email',
                                    style: TextStyle(
                                      color: AppColors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: AppColors.lightGrey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Email field
                            _buildLabel('Email address'),
                            const SizedBox(height: 8),
                            FancyTextField(
                              key: const Key('emailField'),
                              controller: _emailController,
                              focusNode: _emailFocus,
                              hint: 'you@example.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              accentColor: AppColors.forestGreen,
                            ),
                            const SizedBox(height: 20),
                            // Password field
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildLabel('Password'),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      'Forgot password?',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.limeGreen,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            FancyTextField(
                              key: const Key('passwordField'),
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscurePassword,
                              accentColor: AppColors.forestGreen,
                              suffix: GestureDetector(
                                onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Remember me
                            GestureDetector(
                              key: const Key('rememberMe'),
                              onTap: () =>
                                  setState(() => _rememberMe = !_rememberMe),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: _rememberMe
                                          ? AppColors.forestGreen
                                          : AppColors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: _rememberMe
                                            ? AppColors.forestGreen
                                            : AppColors.lightGrey,
                                        width: 2,
                                      ),
                                    ),
                                    child: _rememberMe
                                        ? const Icon(
                                            Icons.check_rounded,
                                            color: AppColors.white,
                                            size: 14,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Keep me signed in',
                                    style: TextStyle(
                                      color: AppColors.charcoal.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            // Login button
                            AnimatedBuilder(
                              animation: _buttonScale,
                              builder: (_, _) => Transform.scale(
                                scale: _buttonScale.value,
                                child: GestureDetector(
                                  key: const Key('loginButton'),
                                  onTap: _handleLogin,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: double.infinity,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.forestGreen,
                                          AppColors.limeGreen,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.forestGreen
                                              .withValues(alpha: 0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: AppColors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: AppColors.white,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Sign up link
                  Padding(
                    padding: EdgeInsets.only(top: 24, bottom: bottomPad + 24),
                    child: SlideTransition(
                      position: _formSlide,
                      child: FadeTransition(
                        opacity: _formOpacity,
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: AppColors.charcoal.withValues(alpha: 0.5),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'Sign up free 🌿',
                                    style: TextStyle(
                                      color: AppColors.forestGreen,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.charcoal,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }
}

class FancyTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Color accentColor;
  final Widget? suffix;

  const FancyTextField({super.key,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.accentColor,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  State<FancyTextField> createState() => FancyTextFieldState();
}
class FancyTextFieldState extends State<FancyTextField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() => _isFocused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _isFocused ? AppColors.cream : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? widget.accentColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: widget.accentColor.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.obscure,
        keyboardType: widget.keyboardType,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.charcoal,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: AppColors.grey.withValues(alpha: 0.7),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              widget.icon,
              color: _isFocused ? widget.accentColor : AppColors.grey,
              size: 20,
            ),
          ),
          suffixIcon: widget.suffix != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: widget.suffix,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
class SocialButton extends StatefulWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const SocialButton({super.key,
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  State<SocialButton> createState() => SocialButtonState();
}
class SocialButtonState extends State<SocialButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()
          ..scaleByDouble(
            _pressed ? 0.96 : 1.0, // x
            _pressed ? 0.96 : 1.0, // y
            1.0, // z
            1.0, // w
          ),
        height: 52,
        decoration: BoxDecoration(
          color: _pressed ? AppColors.softCream : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _pressed
                ? AppColors.forestGreen.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _WavePainter extends CustomPainter {
  final double animValue;

  _WavePainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Main green background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Decorative blobs
    final blobPaint = Paint()
      ..color = const Color(0xFF52B788).withValues(alpha: 0.18);
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.15),
      size.width * 0.35,
      blobPaint,
    );

    final blobPaint2 = Paint()
      ..color = const Color(0xFF74C69D).withValues(alpha: 0.12);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.7),
      size.width * 0.28,
      blobPaint2,
    );

    // Wave bottom edge
    final wavePaint = Paint()
      ..color = const Color(0xFFFEFAE0)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.75);

    final waveHeight = 18.0;
    final waveOffset = animValue * math.pi * 2;

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          size.height * 0.75 +
          waveHeight *
              math.sin((x / size.width * 2 * math.pi) + waveOffset) *
              0.5 +
          waveHeight *
              math.sin((x / size.width * 4 * math.pi) + waveOffset * 1.3) *
              0.3;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.animValue != animValue;
}
