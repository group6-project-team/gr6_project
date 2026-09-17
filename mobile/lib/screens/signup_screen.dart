import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/trip_api.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_fields.dart';
import '../widgets/paper_plane_mark.dart';
import 'main_shell.dart';

/// Visual-only sign up. No Backend call.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.api});

  final TripApi api;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _continueToPlanner() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, _, _) => MainShell(api: widget.api),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (_) => false,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 8, 26, 20),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.introTeal),
                      ),
                    ),
                    const PaperPlaneMark(size: 64, color: AppTheme.introTeal),
                    const SizedBox(height: 4),
                    const Text(
                      'Triply',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 48,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.introTeal,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 32,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.brandInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Join us and start exploring',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.brandSoft,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Email address',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
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
                    const SizedBox(height: 14),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brandInk,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AuthPillField(
                      controller: _password,
                      hint: 'Create a password',
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                    ),
                    const SizedBox(height: 14),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brandInk,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AuthPillField(
                      controller: _confirm,
                      hint: 'Confirm your password',
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: FilledButton(
                        onPressed: _continueToPlanner,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.introTeal,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        child: const Text('Create Account'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                          color: AppTheme.introTeal,
                        ),
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
