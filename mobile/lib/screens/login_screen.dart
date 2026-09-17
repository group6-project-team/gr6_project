import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/trip_api.dart';
import '../theme/app_theme.dart';
import '../widgets/paper_plane_mark.dart';
import 'main_shell.dart';

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
              alignment: Alignment.topCenter,
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
                      child: Column(
                        children: [
                          const SizedBox(height: 18),
                          const PaperPlaneMark(
                            size: 72,
                            color: AppTheme.introTeal,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Triply',
                            style: TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontSize: 48,
                              height: 1,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.introTeal,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A3D45),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Sign in to continue your journey',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6A7C79),
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Email address',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4F6B68),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _PillField(
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
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4F6B68),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _PillField(
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
                                visualDensity: VisualDensity.compact,
                                textStyle: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('Forgot Password?'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton(
                              key: const Key('login-submit'),
                              onPressed: _continueToPlanner,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.introTeal,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                                textStyle: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('Login'),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: OutlinedButton(
                              key: const Key('login-google'),
                              onPressed: _continueToPlanner,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1A3D45),
                                backgroundColor: Colors.white.withValues(alpha: 0.82),
                                side: BorderSide(
                                  color: AppTheme.introTeal.withValues(alpha: 0.45),
                                ),
                                shape: const StadiumBorder(),
                                textStyle: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _GoogleMark(),
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
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13.5,
                                  color: Color(0xFF5E726E),
                                ),
                              ),
                              GestureDetector(
                                onTap: _continueToPlanner,
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
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

class _PillField extends StatelessWidget {
  const _PillField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      cursorColor: AppTheme.introTeal,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 15,
        color: Color(0xFF1A3D45),
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.introTeal, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.88),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          color: AppTheme.muted.withValues(alpha: 0.75),
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: AppTheme.introTeal.withValues(alpha: 0.38)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          borderSide: BorderSide(color: AppTheme.introTeal, width: 1.4),
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  static const _svg = '''
<svg viewBox="0 0 24 24">
  <path fill="#4285F4" d="M23.5 12.3c0-.8-.1-1.6-.2-2.3H12v4.4h6.5c-.3 1.5-1.1 2.7-2.4 3.5v2.9h3.8c2.3-2.1 3.6-5.2 3.6-8.5z"/>
  <path fill="#34A853" d="M12 24c3.2 0 5.9-1.1 7.9-2.9l-3.8-2.9c-1.1.7-2.5 1.2-4.1 1.2-3.1 0-5.8-2.1-6.7-5H1.3v3c2 4 6.1 6.6 10.7 6.6z"/>
  <path fill="#FBBC05" d="M5.3 14.4c-.2-.7-.4-1.4-.4-2.4s.1-1.7.4-2.4V6.6H1.3C.5 8.3 0 10.1 0 12s.5 3.7 1.3 5.4l4-3z"/>
  <path fill="#EA4335" d="M12 4.8c1.8 0 3.3.6 4.6 1.8l3.4-3.4C17.9 1.1 15.2 0 12 0 7.4 0 3.3 2.6 1.3 6.6l4 3c.9-2.9 3.6-4.8 6.7-4.8z"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_svg, width: 18, height: 18);
  }
}
