import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/atelier_widgets.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    required this.nextPage,
    this.duration = const Duration(milliseconds: 850),
    super.key,
  });

  final Widget nextPage;
  final Duration duration;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _openHome();
  }

  Future<void> _openHome() async {
    await Future<void>.delayed(widget.duration);
    if (!mounted) return;
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(builder: (_) => widget.nextPage),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.forest,
    body: SafeArea(
      child: Stack(
        children: [
          const Positioned(
            right: -100,
            top: -70,
            child: JourneyGlobe(size: 360, color: Color(0xFF365E4B)),
          ),
          const Positioned(
            left: -100,
            bottom: -90,
            child: JourneyGlobe(size: 280, color: Color(0xFF365E4B)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.paper,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 42,
                      color: AppTheme.forest,
                      semanticLabel: 'Jastip Katalog',
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Jastip Katalog',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall
                        ?.copyWith(color: AppTheme.paper),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'TEMUAN JAUH. TITIPAN DEKAT.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD8E5B7),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Container(
                    width: 32,
                    height: 2,
                    color: const Color(0xFFD8E5B7),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Siapkan katalog Anda',
                    style: TextStyle(fontSize: 12, color: Color(0xFFB8CABB)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
