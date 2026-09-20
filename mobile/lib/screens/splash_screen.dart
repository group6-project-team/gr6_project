import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/trip_api.dart';
import '../widgets/paper_plane_mark.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.api,
    this.displayDuration = const Duration(milliseconds: 7000),
  });

  final TripApi api;
  final Duration displayDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  Timer? _timer;
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _timer = Timer(widget.displayDuration, _openOnboarding);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(const AssetImage('assets/intro/splash_amalfi.png'), context);
    });
  }

  Future<void> _openOnboarding() async {
    if (!mounted || _opened) return;
    _opened = true;
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, _, _) => OnboardingScreen(api: widget.api),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        key: const Key('splash-screen'),
        backgroundColor: const Color(0xFF08141C),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/intro/splash_amalfi.png',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.08),
            ),
            FadeTransition(
              opacity: fade,
              child: const Align(
                alignment: Alignment(0, -0.22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PaperPlaneMark(size: 52),
                    SizedBox(height: 14),
                    Text(
                      'Triply',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 58,
                        height: 0.95,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Color(0x66000000), blurRadius: 12),
                        ],
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'More than trips...\nIt\'s a story.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 20,
                        height: 1.35,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Color(0x4D000000), blurRadius: 8),
                        ],
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
}
