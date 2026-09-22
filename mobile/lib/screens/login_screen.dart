import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/auth_api_exception.dart';
import '../models/auth_session.dart';
import '../services/auth_api.dart';
import '../widgets/auth_look.dart';
import '../widgets/auth_validators.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authApi});

  final AuthApi authApi;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final session = await widget.authApi.login(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(session);
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitting = false;
        _error = error.userMessage;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitting = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  Future<void> _openSignup() async {
    final session = await Navigator.of(context).push<AuthSession>(
      MaterialPageRoute(
        builder: (_) => SignupScreen(authApi: widget.authApi),
      ),
    );
    if (session != null && mounted) {
      Navigator.of(context).pop(session);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F1E8),
        body: Stack(
          children: [
            const AuthSkyBackdrop(),
            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6, top: 4),
                      child: IconButton(
                        key: const Key('login-back'),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        color: AuthLook.ink,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xCCFFFCF8),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(34, 36, 34, 24),
                      children: [
                        const AuthBrand(planeSize: 38),
                        const SizedBox(height: 22),
                        const Text(
                          'Welcome Back!',
                          textAlign: TextAlign.center,
                          style: AuthLook.headline,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to continue your journey',
                          textAlign: TextAlign.center,
                          style: AuthLook.subtitle,
                        ),
                        const SizedBox(height: 32),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              AuthLabeledField(
                                fieldKey: const Key('login-email'),
                                label: 'Email address',
                                hint: 'you@example.com',
                                icon: Icons.alternate_email_rounded,
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: AuthValidators.email,
                              ),
                              const SizedBox(height: 16),
                              AuthLabeledField(
                                fieldKey: const Key('login-password'),
                                label: 'Password',
                                hint: 'Enter your password',
                                icon: Icons.lock_outline_rounded,
                                controller: _password,
                                obscure: true,
                                textInputAction: TextInputAction.done,
                                validator: AuthValidators.password,
                                onSubmitted: (_) => _submit(),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  key: const Key('login-forgot'),
                                  onPressed: () =>
                                      AuthLook.pending(context, 'Forgot password'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AuthLook.muted,
                                    textStyle: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: const Text('Forgot Password?'),
                                ),
                              ),
                              if (_error != null) ...[
                                Text(
                                  key: const Key('login-error'),
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFB42318),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                              AuthPrimaryButton(
                                key: const Key('login-submit'),
                                label: _submitting ? 'Signing in…' : 'Log in',
                                onPressed: _submitting ? null : _submit,
                              ),
                              const SizedBox(height: 14),
                              GoogleContinueButton(
                                key: const Key('login-google'),
                                onPressed: () =>
                                    AuthLook.pending(context, 'Google sign-in'),
                              ),
                              const SizedBox(height: 22),
                              AuthFooterLink(
                                key: const Key('login-open-signup'),
                                prompt: "Don't have an account? ",
                                action: 'Sign up',
                                onTap: _submitting ? () {} : _openSignup,
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
          ],
        ),
      ),
    );
  }
}
