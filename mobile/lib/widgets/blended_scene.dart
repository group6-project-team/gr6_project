import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/destination_art.dart';

/// Photo sitting inside a cream card with floral wash — matches the mockup
/// “image blended into the screen” look.
class BlendedScene extends StatelessWidget {
  const BlendedScene({
    super.key,
    required this.image,
    this.height = 210,
    this.overlay,
    this.alignment = const Alignment(0, -0.12),
    this.floral = true,
  });

  final String image;
  final double height;
  final Widget? overlay;
  final Alignment alignment;
  final bool floral;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xF7FFFDF8),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ink.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(image, fit: BoxFit.cover, alignment: alignment),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x14000000),
                              Color(0x00000000),
                              Color(0x9912343A),
                            ],
                            stops: [0, 0.48, 1],
                          ),
                        ),
                      ),
                      ?overlay,
                    ],
                  ),
                ),
              ),
              if (floral)
                IgnorePointer(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Opacity(
                      opacity: 0.55,
                      child: Image.asset(
                        DestinationArt.floral,
                        width: 160,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PolaroidPhoto extends StatelessWidget {
  const PolaroidPhoto({
    super.key,
    required this.image,
    required this.caption,
    this.width = 148,
    this.angle = 0,
  });

  final String image;
  final String caption;
  final double width;
  final double angle;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ink.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.asset(image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: const TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: AppTheme.brandInk,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );

    if (angle == 0) return card;
    return Transform.rotate(angle: angle, child: card);
  }
}
