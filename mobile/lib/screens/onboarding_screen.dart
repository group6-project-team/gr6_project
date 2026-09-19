import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../services/trip_api.dart';
import '../theme/app_theme.dart';
import '../widgets/onboarding_wave_clipper.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.api});

  final TripApi api;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    this.showActions = false,
  });

  final String image;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final bool showActions;
}

const _pages = [
  _OnboardingPage(
    image: 'assets/intro/onboard_wave_discover.png',
    title: 'Discover\nNew Places',
    subtitle: 'Explore stunning destinations around the world.',
    buttonLabel: 'Next',
  ),
  _OnboardingPage(
    image: 'assets/intro/onboard_wave_plan.png',
    title: 'Plan Your\nPerfect Trip',
    subtitle:
        'Get a personalized itinerary based on your budget, days and interests.',
    buttonLabel: 'Next',
  ),
  _OnboardingPage(
    image: 'assets/intro/onboard_travel.png',
    title: 'Travel Your Way',
    subtitle: "Tell us what you love,\nwe'll handle the rest.",
    buttonLabel: 'Get Started',
    showActions: true,
  ),
];

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, _, _) => LoginScreen(api: widget.api),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _next() {
    if (_index >= _pages.length - 1) {
      _goToLogin();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F3EC),
        body: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, index) {
                return _OnboardingBody(page: _pages[index]);
              },
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  key: const Key('onboarding-skip'),
                  onPressed: _goToLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(color: Color(0x66000000), blurRadius: 8),
                      ],
                    ),
                  ),
                  child: const Text('Skip'),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SmoothPageIndicator(
                        controller: _controller,
                        count: _pages.length,
                        effect: WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 8,
                          activeDotColor: AppTheme.introTeal,
                          dotColor: const Color(0xFFD5DDDA),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 220,
                        height: 52,
                        child: FilledButton(
                          key: Key('onboarding-next-$_index'),
                          onPressed: _next,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.introTeal,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: Text(_pages[_index].buttonLabel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingBody extends StatelessWidget {
  const _OnboardingBody({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height * 0.56,
          width: double.infinity,
          child: ClipPath(
            clipper: const OnboardingWaveClipper(),
            child: Image.asset(
              page.image,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _FloralWash(),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 4, 32, 110),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 40,
                        height: 1.12,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.brandInk,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 42,
                      height: 1.5,
                      decoration: BoxDecoration(
                        color: AppTheme.introTeal.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      page.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 17.5,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.brandSoft,
                        letterSpacing: 0.12,
                      ),
                    ),
                    if (page.showActions) ...[
                      const SizedBox(height: 22),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ActionIcon(
                            icon: Icons.location_on_outlined,
                            label: 'Budget',
                          ),
                          _ActionIcon(
                            icon: Icons.calendar_month_outlined,
                            label: 'Days',
                          ),
                          _ActionIcon(
                            icon: Icons.settings_outlined,
                            label: 'Interests',
                          ),
                        ],
                      ),
                    ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FloralWash extends StatelessWidget {
  const _FloralWash();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/intro/onboard_floral_wash.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        ColoredBox(color: const Color(0xFFF7F3EC).withValues(alpha: 0.62)),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.introTeal.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.introTeal.withValues(alpha: 0.1),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(icon, size: 26, color: AppTheme.introTeal),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 14,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            color: AppTheme.introTeal,
          ),
        ),
      ],
    );
  }
}
