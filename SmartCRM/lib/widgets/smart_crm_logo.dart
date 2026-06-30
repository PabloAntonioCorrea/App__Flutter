import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_strings.dart';

class SmartCrmLogoIcon extends StatelessWidget {
  final double size;
  final bool forDarkBackground;

  const SmartCrmLogoIcon({
    super.key,
    required this.size,
    this.forDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final personColor = forDarkBackground ? AppColors.primary : Colors.white;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _Shield(size: size, forDarkBackground: forDarkBackground),
          Positioned.fill(
            child: Center(
              child: _PersonIcon(
                size: size * 0.56,
                color: personColor,
              ),
            ),
          ),
          Positioned(
            right: size * 0.1,
            bottom: size * 0.16,
            child: _LogoBarChart(size: size),
          ),
        ],
      ),
    );
  }
}

class _Shield extends StatelessWidget {
  final double size;
  final bool forDarkBackground;

  const _Shield({
    required this.size,
    required this.forDarkBackground,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      Icons.shield,
      size: size,
      color: Colors.white,
    );

    if (forDarkBackground) {
      return icon;
    }

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF7EC8F7),
          Color(0xFF3A7BC8),
        ],
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: icon,
    );
  }
}

class _PersonIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _PersonIcon({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PersonPainter(color: color),
    );
  }
}

class _PersonPainter extends CustomPainter {
  final Color color;

  _PersonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.08;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final headRadius = size.width * 0.18;
    final headCenter = Offset(size.width * 0.5, size.height * 0.3);
    canvas.drawCircle(headCenter, headRadius, paint);

    final shoulders = Path()
      ..moveTo(size.width * 0.16, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        size.width * 0.84,
        size.height * 0.8,
      );
    canvas.drawPath(shoulders, paint);
  }

  @override
  bool shouldRepaint(covariant _PersonPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _LogoBarChart extends StatelessWidget {
  final double size;

  const _LogoBarChart({required this.size});

  @override
  Widget build(BuildContext context) {
    const heights = [0.42, 0.68, 1.0];
    final maxHeight = size * 0.42;
    final barWidth = size * 0.085;
    final gap = size * 0.03;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : gap),
          child: Container(
            width: barWidth,
            height: maxHeight * heights[index],
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(barWidth * 0.22),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFB8F06A),
                  Color(0xFF4CAF50),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class SmartCrmLogo extends StatelessWidget {
  final double size;

  const SmartCrmLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SmartCrmLogoIcon(size: size),
        const SizedBox(height: 8),
        Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
