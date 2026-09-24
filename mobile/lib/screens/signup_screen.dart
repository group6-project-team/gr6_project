import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/auth_api_exception.dart';
import '../services/auth_api.dart';
import '../widgets/auth_hill_clipper.dart';
import '../widgets/auth_look.dart';
import '../widgets/auth_validators.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.authApi});

  final AuthApi authApi;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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
      final session = await widget.authApi.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        confirmPassword: _confirm.text,
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AuthLook.cream,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: height * 0.36,
              child: Image.asset(
                'assets/intro/onboard_travel.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0.28, 0.52),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: height * 0.76,
              child: ClipPath(
                clipper: const AuthHillClipper(),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/intro/onboard_travel.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                    Image.asset(
                      'assets/intro/onboard_floral_wash.png',
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.55),
                    ),
                    const ColoredBox(color: Color(0xD9F8F3EA)),
                    ListView(
                      padding: const EdgeInsets.fromLTRB(30, 48, 30, 28),
                      children: [
                        const AuthBrand(planeSize: 36),
                        const SizedBox(height: 16),
                        const Text(
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: AuthLook.headline,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Join us and start exploring',
                          textAlign: TextAlign.center,
                          style: AuthLook.subtitle,
                        ),
                        const SizedBox(height: 22),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              AuthLabeledField(
                                fieldKey: const Key('signup-name'),
                                label: 'Name',
                                hint: 'Enter your name',
                                icon: Icons.person_outline_rounded,
                                controller: _name,
                                textInputAction: TextInputAction.next,
                                validator: AuthValidators.name,
                              ),
                              const SizedBox(height: 14),
                              AuthLabeledField(
                                fieldKey: const Key('signup-email'),
                                label: 'Email address',
                                hint: 'you@example.com',
                                icon: Icons.alternate_email_rounded,
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: AuthValidators.email,
                              ),
                              const SizedBox(height: 14),
                              AuthLabeledField(
                                fieldKey: const Key('signup-password'),
                                label: 'Password',
                                hint: 'Create a password',
                                icon: Icons.lock_outline_rounded,
                                controller: _password,
                                obscure: true,
                                textInputAction: TextInputAction.next,
                                validator: AuthValidators.password,
                              ),
                              const SizedBox(height: 14),
                              AuthLabeledField(
                                fieldKey: const Key('signup-confirm'),
                                label: 'Confirm Password',
                                hint: 'Confirm your password',
                                icon: Icons.lock_outline_rounded,
                                controller: _confirm,
                                obscure: true,
                                textInputAction: TextInputAction.done,
                                validator: (value) =>
                                    AuthValidators.confirmPassword(
                                  value,
                                  _password.text,
                                ),
                                onSubmitted: (_) => _submit(),
                              ),
                              const SizedBox(height: 22),
                            if (_error != null) ...[
                              Text(
                                key: const Key('signup-error'),
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
                              key: const Key('signup-submit'),
                              label: _submitting ? 'Creating account…' : 'Create Account',
                              onPressed: _submitting ? null : _submit,
                            ),
                              const SizedBox(height: 16),
                              AuthFooterLink(
                                key: const Key('signup-open-login'),
                                prompt: 'Already have an account? ',
                                action: 'Login',
                                onTap: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  key: const Key('signup-back'),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
