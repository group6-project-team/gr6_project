import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/trip_api.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_fields.dart';
import '../widgets/paper_plane_mark.dart';
import 'main_shell.dart';
import 'signup_screen.dart';

/// Visual-only login. No Backend call, no stored credentials.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.api});

  final TripApi api;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _continueToPlanner() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, _, _) => MainShell(api: widget.api),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openSignUp() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => SignupScreen(api: widget.api),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3EFE6),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/intro/login_sky.png',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.35),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00FFFFFF),
                    Color(0x66FFF8EF),
                    Color(0xCCFFF6EC),
                  ],
                  stops: [0.28, 0.52, 1],
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final topGap = constraints.maxHeight >= 720
                      ? 96.0
                      : constraints.maxHeight >= 640
                          ? 48.0
                          : 12.0;
                  final titleSize = constraints.maxHeight >= 640 ? 58.0 : 46.0;
                  final welcomeSize = constraints.maxHeight >= 640 ? 34.0 : 28.0;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 0, 26, 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
                      child: Column(
                        children: [
                          SizedBox(height: topGap),
                          PaperPlaneMark(
                            size: constraints.maxHeight >= 640 ? 78 : 62,
                            color: AppTheme.introTeal,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Triply',
                            style: TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontSize: titleSize,
                              height: 1,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.introTeal,
                              shadows: const [
                                Shadow(color: Color(0x99FFFFFF), blurRadius: 18),
                              ],
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight >= 640 ? 28 : 16),
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontSize: welcomeSize,
                              height: 1.05,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.brandInk,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sign in to continue your journey',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontSize: 17,
                              height: 1.35,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.brandSoft,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Email address',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.brandInk,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          AuthPillField(
                            controller: _email,
                            hint: 'you@example.com',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Password',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.brandInk,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          AuthPillField(
                            controller: _password,
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
                            obscure: true,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.introTeal,
                                textStyle: const TextStyle(
                                  fontFamily: 'PlayfairDisplay',
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('Forgot Password?'),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: FilledButton(
                              key: const Key('login-submit'),
                              onPressed: _continueToPlanner,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.introTeal,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: const StadiumBorder(),
                                textStyle: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              child: const Text('Login'),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: OutlinedButton(
                              key: const Key('login-google'),
                              onPressed: _continueToPlanner,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.brandInk,
                                backgroundColor: Colors.white.withValues(alpha: 0.9),
                                side: const BorderSide(color: AppTheme.introTeal, width: 1.3),
                                shape: const StadiumBorder(),
                                textStyle: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GoogleMark(),
                                  SizedBox(width: 10),
                                  Text('Continue with Google'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  fontFamily: 'PlayfairDisplay',
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.brandSoft,
                                ),
                              ),
                              GestureDetector(
                                onTap: _openSignUp,
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontFamily: 'PlayfairDisplay',
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.introTeal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}