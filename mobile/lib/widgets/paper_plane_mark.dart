import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// White origami plane from the Triply splash mockup.
class PaperPlaneMark extends StatelessWidget {
  const PaperPlaneMark({
    super.key,
    this.size = 54,
    this.color = Colors.white,
  });

  final double size;
  final Color color;

  static const _svg = '''
<svg viewBox="0 0 64 64" fill="none">
  <path d="M8 30.5L58 12L34 54L29.5 35.5Z" fill="white" fill-opacity="0.16" stroke="white" stroke-width="2.6" stroke-linejoin="round"/>
  <path d="M58 12L29.5 35.5" stroke="white" stroke-width="2.6" stroke-linecap="round"/>
  <path d="M29.5 35.5L20 40.5" stroke="white" stroke-width="2.6" stroke-linecap="round"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
