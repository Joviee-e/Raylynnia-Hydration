import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WaterWaveProgress extends StatefulWidget {
  const WaterWaveProgress({
    required this.percentage,
    required this.goalMl,
    required this.totalIntakeMl,
    super.key,
  });

  final double percentage;
  final int goalMl;
  final int totalIntakeMl;

  @override
  State<WaterWaveProgress> createState() => _WaterWaveProgressState();
}

class _WaterWaveProgressState extends State<WaterWaveProgress> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = min(MediaQuery.sizeOf(context).width * 0.7, 300.0);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.surfaceContainerHigh,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x052C3437),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset(0, 0),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Ring Track
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
                  width: 10,
                ),
              ),
            ),
          ),
          
          // Fluid wave filling up
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(size, size),
                    painter: WavePainter(
                      percentage: widget.percentage,
                      wavePhase: _animationController.value * 2 * pi,
                    ),
                  );
                },
              ),
            ),
          ),

          // Glass overlay content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.percentage.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                      fontSize: 60,
                      height: 1,
                    ),
                  ),
                  Text(
                    '%',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w300,
                      color: AppColors.onSurface,
                      fontSize: 24,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'DAILY FLUX',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  WavePainter({
    required this.percentage,
    required this.wavePhase,
  });

  final double percentage;
  final double wavePhase;

  @override
  void paint(Canvas canvas, Size size) {
    // Correct the height relative to percentage
    final double fillY = size.height * (1.0 - (percentage / 100.0).clamp(0.0, 1.0));
    
    final paint1 = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x7FACBBE6),
          Color(0xBAC5E8F8),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x3FACBBE6),
          Color(0x66C5E8F8),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path1 = Path();
    final path2 = Path();

    path1.moveTo(0, size.height);
    path1.lineTo(0, fillY);

    path2.moveTo(0, size.height);
    path2.lineTo(0, fillY);

    // Wave parameters
    final double waveAmplitude = percentage > 0 && percentage < 100 ? 6.0 : 0.0;
    final double waveFrequency = size.width;

    for (double x = 0; x <= size.width; x++) {
      final double y1 = fillY + waveAmplitude * sin((2 * pi * x / waveFrequency) + wavePhase);
      path1.lineTo(x, y1);

      final double y2 = fillY + waveAmplitude * sin((2 * pi * x / waveFrequency) - wavePhase + pi / 2);
      path2.lineTo(x, y2);
    }

    path1.lineTo(size.width, size.height);
    path1.close();

    path2.lineTo(size.width, size.height);
    path2.close();

    // Draw background wave layer first
    canvas.drawPath(path2, paint2);
    // Draw foreground wave layer
    canvas.drawPath(path1, paint1);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.wavePhase != wavePhase;
  }
}
