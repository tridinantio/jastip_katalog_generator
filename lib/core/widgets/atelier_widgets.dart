import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AtelierHeading extends StatelessWidget {
  const AtelierHeading({
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });
  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.rust,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.4,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          ?trailing,
        ],
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 8),
        Text(
          subtitle!,
          style: const TextStyle(
            color: AppTheme.muted,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    ],
  );
}

class AtelierEmptyState extends StatelessWidget {
  const AtelierEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 132,
              height: 116,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: -.14,
                    child: Container(
                      width: 82,
                      height: 92,
                      decoration: BoxDecoration(
                        color: AppTheme.cream,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: .12,
                    child: Container(
                      width: 82,
                      height: 92,
                      decoration: BoxDecoration(
                        color: AppTheme.sage,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.paper, width: 3),
                      ),
                      child: Icon(icon, size: 36, color: AppTheme.forest),
                    ),
                  ),
                  const Positioned(
                    right: 9,
                    top: 5,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 22,
                      color: AppTheme.rust,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.muted,
                height: 1.6,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Decorative latitude lines drawn locally; never intercepts interactions.
class JourneyGlobe extends StatelessWidget {
  const JourneyGlobe({this.color = AppTheme.sage, this.size = 130, super.key});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(size: Size.square(size), painter: _GlobePainter(color)),
  );
}

class _GlobePainter extends CustomPainter {
  const _GlobePainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawOval(rect, paint);
    for (final factor in [.35, .7]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: rect.center,
          width: rect.width * factor,
          height: rect.height,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: rect.center,
          width: rect.width,
          height: rect.height * factor,
        ),
        paint,
      );
    }
    canvas.drawLine(
      Offset(2, size.height / 2),
      Offset(size.width - 2, size.height / 2),
      paint,
    );
    canvas.drawLine(
      Offset(size.width / 2, 2),
      Offset(size.width / 2, size.height - 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(_GlobePainter oldDelegate) => oldDelegate.color != color;
}

class TicketDivider extends StatelessWidget {
  const TicketDivider({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        (constraints.maxWidth / 10).floor(),
        (_) => const SizedBox(
          width: 4,
          height: 1,
          child: ColoredBox(color: Color(0xFF648174)),
        ),
      ),
    ),
  );
}
