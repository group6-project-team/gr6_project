import 'package:flutter/material.dart';

/// White signup sheet: sides sit low, center rises in a rounded wave peak
/// so the paper plane can sit on the hill like the Triply mockup.
class AuthHillClipper extends CustomClipper<Path> {
  const AuthHillClipper();

  @override
  Path getClip(Size size) {
    final peakDrop = size.height < 420 ? 64.0 : 86.0;
    final path = Path()
      ..moveTo(0, peakDrop)
      ..cubicTo(
        size.width * 0.12,
        peakDrop,
        size.width * 0.22,
        peakDrop * 0.92,
        size.width * 0.30,
        peakDrop * 0.55,
      )
      ..cubicTo(
        size.width * 0.38,
        peakDrop * 0.08,
        size.width * 0.44,
        0,
        size.width * 0.50,
        0,
      )
      ..cubicTo(
        size.width * 0.56,
        0,
        size.width * 0.62,
        peakDrop * 0.08,
        size.width * 0.70,
        peakDrop * 0.55,
      )
      ..cubicTo(
        size.width * 0.78,
        peakDrop * 0.92,
        size.width * 0.88,
        peakDrop,
        size.width,
        peakDrop,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
