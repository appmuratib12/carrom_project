import 'package:carrom_project/Utils/login_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../Appconstant/app_colors.dart';
import 'travel_app.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _floatController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  final List<OnboardingData> _pages = [
    OnboardingData(
      emoji: '🥦',
      emojiSecondary: ['🍎', '🥕', '🍋'],
      title: 'Farm-Fresh\nGroceries',
      subtitle: 'Handpicked produce delivered straight from local farms to your kitchen every single day.',
      gradient: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
      accentColor: Color(0xFF74C69D),
      illustrationEmoji: ['🥬', '🍅', '🥒', '🍊', '🫐', '🥑'],
    ),
    OnboardingData(
      emoji: '⚡',
      emojiSecondary: ['🛵', '📦', '🏠'],
      title: '30-Minute\nDelivery',
      subtitle: 'Order now, receive in 30 minutes. Real-time tracking so you always know where your order is.',
      gradient: [Color(0xFF1B4332), Color(0xFF40916C)],
      accentColor: Color(0xFFF4A261),
      illustrationEmoji: ['🛵', '📍', '⏱️', '🏠', '✅', '📦'],
    ),
    OnboardingData(
      emoji: '💸',
      emojiSecondary: ['🎁', '✨', '💚'],
      title: 'Best Deals\nEvery Day',
      subtitle: 'Save big with daily flash sales, exclusive member offers and loyalty rewards that add up fast.',
      gradient: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
      accentColor: Color(0xFF74C69D),
      illustrationEmoji: ['💚', '🎁', '🏷️', '⭐', '💎', '🎉'],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a, _) => LoginScreen1(),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (ctx, i) => _OnboardingPage(
              data: _pages[i],
              floatController: _floatController,
              isActive: i == _currentPage,
            ),
          ),

          // Bottom overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 28,
                right: 28,
                bottom: MediaQuery.of(context).padding.bottom + 36,
                top: 28,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _pages[_currentPage].gradient.last.withValues(alpha: 0.95),
                    _pages[_currentPage].gradient.last,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? _pages[_currentPage].accentColor
                              : AppColors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // CTA Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _pages[_currentPage].accentColor,
                          _pages[_currentPage].accentColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _pages[_currentPage].accentColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _nextPage,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _pages.length - 1
                                    ? 'Get Started'
                                    : 'Continue',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
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
                  if (_currentPage < _pages.length - 1) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (_, _, _) => const LoginScreen(),
                            transitionsBuilder: (_, a, _, child) =>
                                FadeTransition(opacity: a, child: child),
                            transitionDuration: const Duration(milliseconds: 400),
                          ),
                        );
                      },
                      child: Text(
                        'Skip for now',
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final AnimationController floatController;
  final bool isActive;

  const _OnboardingPage({
    required this.data,
    required this.floatController,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: data.gradient,
        ),
      ),
      child: Stack(
        children: [
          // Background decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: data.accentColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: data.accentColor.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.06),
                // Big illustration area
                SizedBox(
                  height: size.height * 0.42,
                  child: AnimatedBuilder(
                    animation: floatController,
                    builder: (_, _) {
                      final floatOffset = math.sin(floatController.value * math.pi) * 12;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glowing circle bg
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: data.accentColor.withValues(alpha: 0.12),
                              boxShadow: [
                                BoxShadow(
                                  color: data.accentColor.withValues(alpha: 0.2),
                                  blurRadius: 60,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          // Inner circle
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: data.accentColor.withValues(alpha: 0.15),
                            ),
                          ),
                          // Center main emoji
                          Transform.translate(
                            offset: Offset(0, floatOffset),
                            child: Text(
                              data.emoji,
                              style: const TextStyle(fontSize: 90),
                            ),
                          ),
                          // Orbiting emojis
                          ...List.generate(data.illustrationEmoji.length, (i) {
                            final angle = (i / data.illustrationEmoji.length) *
                                    math.pi * 2 +
                                floatController.value * math.pi * 0.5;
                            final r = 120.0 + math.sin(i * 1.5) * 15;
                            final x = r * math.cos(angle);
                            final y = r * math.sin(angle) * 0.6;
                            return Transform.translate(
                              offset: Offset(x, y),
                              child: Opacity(
                                opacity: 0.75,
                                child: Text(
                                  data.illustrationEmoji[i],
                                  style: const TextStyle(fontSize: 26),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Text content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          height: 1.15,
                          letterSpacing: -0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        data.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.white.withValues(alpha: 0.75),
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String emoji;
  final List<String> emojiSecondary;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final Color accentColor;
  final List<String> illustrationEmoji;

  const OnboardingData({
    required this.emoji,
    required this.emojiSecondary,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.accentColor,
    required this.illustrationEmoji,
  });
}
