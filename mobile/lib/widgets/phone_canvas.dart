import 'package:flutter/material.dart';

/// Keeps splash/onboarding at a real phone aspect on Windows/desktop,
/// matching the Triply mockup poster instead of stretching across a wide window.
class PhoneCanvas extends StatelessWidget {
  const PhoneCanvas({super.key, required this.child});

  final Widget child;

  static const _phoneSize = Size(390, 844);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.width < 560 || size.height < 800) {
      return child;
    }

    return ColoredBox(
      color: const Color(0xFFF3EBDF),
      child: Center(
        child: Container(
          width: _phoneSize.width,
          height: _phoneSize.height,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(44),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF14343A).withValues(alpha: 0.22),
                blurRadius: 48,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: _phoneSize,
                padding: const EdgeInsets.only(top: 10, bottom: 12),
                viewPadding: const EdgeInsets.only(top: 10, bottom: 12),
                viewInsets: EdgeInsets.zero,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
