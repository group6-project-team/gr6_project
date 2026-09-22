import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import 'paper_plane_mark.dart';

class AuthLook {
  static const cream = Color(0xFFF8F3EA);
  static const ink = Color(0xFF1B4F58);
  static const muted = Color(0xFF6E8582);
  static const fieldHint = Color(0xFFA9B8B5);
  static const button = Color(0xFF0C4A52);
  static const label = Color(0xFF4A6A68);

  static const title = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 42,
    height: 1,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w600,
    color: Color(0xFF0E5860),
  );

  static const headline = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 26,
    height: 1.15,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1B4F58),
  );

  static const subtitle = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 14.5,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: muted,
  );

  static const fieldLabel = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 16.5,
    fontWeight: FontWeight.w800,
    color: label,
  );

  static void pending(BuildContext context, String action) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: button,
        content: Text('$action waits for Backend auth.'),
      ),
    );
  }
}

class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key, this.planeSize = 46});

  final double planeSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PaperPlaneMark(size: planeSize, color: AppTheme.introTeal),
        const SizedBox(height: 8),
        const Text('Triply', style: AuthLook.title),
      ],
    );
  }
}

class AuthSkyBackdrop extends StatelessWidget {
  const AuthSkyBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Color(0xFFF6F1E8)),
        Image(
          image: AssetImage('assets/intro/login_sky.png'),
          fit: BoxFit.cover,
          alignment: Alignment(0, -0.85),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x00F6F1E8),
                Color(0xB3F6F1E8),
                Color(0xE6F6F1E8),
              ],
              stops: [0.12, 0.34, 0.58],
            ),
          ),
        ),
      ],
    );
  }
}

class AuthLabeledField extends StatelessWidget {
  const AuthLabeledField({
    super.key,
    required this.fieldKey,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
  });

  final Key fieldKey;
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Text(label, style: AuthLook.fieldLabel),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AuthLook.ink.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextFormField(
            key: fieldKey,
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            validator: validator,
            onFieldSubmitted: onSubmitted,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AuthLook.ink,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AuthLook.fieldHint,
              ),
              prefixIcon: Icon(icon, color: AuthLook.muted, size: 22),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              border: _border(Colors.transparent),
              enabledBorder: _border(Colors.transparent),
              focusedBorder: _border(AppTheme.introTeal.withValues(alpha: 0.35)),
              errorBorder: _border(const Color(0xFFB42318).withValues(alpha: 0.4)),
              focusedErrorBorder: _border(const Color(0xFFB42318)),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: BorderSide(color: color),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AuthLook.button,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AuthLook.button.withValues(alpha: 0.45),
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class AuthSoftButton extends StatelessWidget {
  const AuthSoftButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AuthLook.ink.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AuthLook.ink,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class GoogleContinueButton extends StatelessWidget {
  const GoogleContinueButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const _g = '''
<svg viewBox="0 0 24 24">
  <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
  <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
  <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
  <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AuthLook.ink.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AuthLook.ink,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.string(_g, width: 20, height: 20),
              const SizedBox(width: 10),
              const Text('Continue with Google'),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text.rich(
          TextSpan(
            text: prompt,
            style: AuthLook.subtitle,
            children: [
              TextSpan(
                text: action,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.introTeal,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
