import 'package:flutter/material.dart';

/// Bottom edge of the onboarding hero: photo hangs down in the center,
/// cream content waves up on the sides — same curve as the Triply mockup.
class OnboardingWaveClipper extends CustomClipper<Path> {
  const OnboardingWaveClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 78);
    path.cubicTo(
      size.width * 0.82,
      size.height - 70,
      size.width * 0.70,
      size.height - 10,
      size.width * 0.50,
      size.height - 4,
    );
    path.cubicTo(
      size.width * 0.30,
      size.height + 4,
      size.width * 0.16,
      size.height - 72,
      0,
      size.height - 82,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
