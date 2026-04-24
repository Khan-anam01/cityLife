import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/navigation/app_routes.dart';

// ── Onboarding Page Model ─────────────────────────────
class _OnboardPage {
  final String title;
  final String subtitle;
  final String emoji;
  final Color accent;
  final Color bg;

  const _OnboardPage({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.accent,
    required this.bg,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _bgController;
  late AnimationController _contentController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  int _currentPage = 0;

  static const List<_OnboardPage> _pages = [
    _OnboardPage(
      title: 'Your City,\nAt Your Fingertips',
      subtitle:
          'Access hospitals, schools, restaurants and every essential service across your city — instantly.',
      emoji: '🏙️',
      accent: AppColors.accent,
      bg: Color(0xFF0A2540),
    ),
    _OnboardPage(
      title: 'Stay Connected\nTo Your Community',
      subtitle:
          'Share updates, join local conversations, discover events happening near you right now.',
      emoji: '🤝',
      accent: AppColors.amber,
      bg: Color(0xFF1A1A2E),
    ),
    _OnboardPage(
      title: 'Navigate &\nReport Issues',
      subtitle:
          'Find your way around with integrated maps, and help improve your city by reporting issues directly.',
      emoji: '🗺️',
      accent: AppColors.lavender,
      bg: Color(0xFF0D2137),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));
    _contentController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _contentController.reset();
    _contentController.forward();
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go(AppRoutes.login);
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        color: page.bg,
        child: Stack(
          children: [
            // ── Decorative blobs ─────────────────────
            Positioned(
              top: -80,
              right: -60,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: page.accent.withOpacity(0.12),
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.35,
              left: -80,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: page.accent.withOpacity(0.08),
                ),
              ),
            ),

            // ── Main Content ─────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      child: TextButton(
                        onPressed: _complete,
                        child: Text(
                          'Skip',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Page view
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return _buildPage(_pages[index]);
                      },
                    ),
                  ),

                  // Bottom controls
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.xxl,
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
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: i == _currentPage ? 28 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: i == _currentPage
                                    ? page.accent
                                    : Colors.white.withOpacity(0.25),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // CTA Button
                        GestureDetector(
                          onTap: _next,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: AppSpacing.buttonHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: page.accent,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.buttonRadius,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: page.accent.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _currentPage == _pages.length - 1
                                    ? 'Get Started'
                                    : 'Continue',
                                style: AppTypography.buttonText.copyWith(
                                  color: _currentPage == 0
                                      ? AppColors.primary
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Login prompt
                        const SizedBox(height: AppSpacing.base),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go(AppRoutes.login),
                              child: Text(
                                'Sign In',
                                style: AppTypography.labelMedium.copyWith(
                                  color: page.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardPage page) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji illustration
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: page.accent.withOpacity(0.15),
                  border: Border.all(
                    color: page.accent.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    page.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Title
              Text(
                page.title,
                style: AppTypography.displayMedium.copyWith(
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Subtitle
              Text(
                page.subtitle,
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.65),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
