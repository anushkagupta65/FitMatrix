// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_app/src/data/models/metric.dart';
import 'package:health_app/src/presentation/screens/details_screen.dart';

class MetricCard extends StatefulWidget {
  final Metric metric;
  final int index;

  const MetricCard({super.key, required this.metric, this.index = 0});

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Staggered entrance animation
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Adaptive Color Palette (same logic, just cleaned up)
  (Color, Color, Color) _getThemeColors(String status, bool isDark) {
    final s = status.toLowerCase();

    if (isDark) {
      return switch (s) {
        'normal' => (
          const Color(0xFF1B5E20).withOpacity(0.35),
          const Color(0xFF69F0AE),
          const Color(0xFFB9F6CA),
        ),
        'high' => (
          const Color(0xFFE65100).withOpacity(0.35),
          const Color(0xFFFFAB40),
          const Color(0xFFFFE0B2),
        ),
        'low' => (
          const Color(0xFFB71C1C).withOpacity(0.35),
          const Color(0xFFFF5252),
          const Color(0xFFFFCDD2),
        ),
        _ => (
          const Color(0xFF424242).withOpacity(0.35),
          const Color(0xFFE0E0E0),
          const Color(0xFFF5F5F5),
        ),
      };
    } else {
      return switch (s) {
        'normal' => (
          const Color(0xFFE8F5E9),
          const Color(0xFF4CAF50),
          const Color(0xFF1B5E20),
        ),
        'high' => (
          const Color(0xFFFFF3E0),
          const Color(0xFFFF9800),
          const Color(0xFFE65100),
        ),
        'low' => (
          const Color(0xFFFFEBEE),
          const Color(0xFFEF5350),
          const Color(0xFFB71C1C),
        ),
        _ => (
          const Color(0xFFF5F5F5),
          const Color(0xFF9E9E9E),
          const Color(0xFF424242),
        ),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final (bgColor, accentColor, textColor) = _getThemeColors(
      widget.metric.status,
      isDarkMode,
    );

    final displayHistory =
        widget.metric.history.isEmpty
            ? [10.0, 40.0, 30.0, 60.0, 50.0, 80.0, widget.metric.value]
            : widget.metric.history;

    final cardBackground = Theme.of(context).cardColor;
    final mainTextColor = isDarkMode ? Colors.white : const Color(0xFF2D3142);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, __, ___) => DetailScreen(metric: widget.metric),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 8.h),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.5 : 0.12),
                blurRadius: 24.r,
                offset: Offset(0, 10.h),
              ),
              BoxShadow(
                color: accentColor.withOpacity(isDarkMode ? 0.15 : 0.08),
                blurRadius: 16.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Background Sparkline
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SparkLinePainter(
                      data: displayHistory,
                      color: accentColor.withOpacity(isDarkMode ? 0.12 : 0.18),
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon Box
                      Container(
                        height: 50.w,
                        width: 50.w,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accentColor.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.metric.name[0].toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),

                      // Main Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.metric.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                                color: mainTextColor,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Normal Range: ${widget.metric.range}',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color:
                                    isDarkMode
                                        ? Colors.white70
                                        : Colors.black.withOpacity(0.75),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Value & Status Badge
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                widget.metric.value.toStringAsFixed(
                                  widget.metric.value % 1 == 0 ? 0 : 1,
                                ),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.sp,
                                  color: mainTextColor,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                widget.metric.unit,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: accentColor.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.metric.status.toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: textColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SparkLinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final bool isDarkMode;

  _SparkLinePainter({
    required this.data,
    required this.color,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2.r
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final fillPaint =
        Paint()
          ..color = color.withOpacity(isDarkMode ? 0.08 : 0.25)
          ..style = PaintingStyle.fill;

    final path = Path();
    final double widthStep = size.width / (data.length - 1);
    final double maxVal = data.reduce(max);
    final double minVal = data.reduce(min);
    final double heightRange = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    double normalize(double val) {
      return size.height * 0.75 -
          ((val - minVal) / heightRange) * (size.height * 0.55);
    }

    path.moveTo(0, normalize(data[0]));

    for (int i = 1; i < data.length; i++) {
      final x = i * widthStep;
      final y = normalize(data[i]);
      final prevX = (i - 1) * widthStep;
      final prevY = normalize(data[i - 1]);

      final cp1x = prevX + (x - prevX) * 0.5;
      final cp2x = prevX + (x - prevX) * 0.5;

      path.cubicTo(cp1x, prevY, cp2x, y, x, y);
    }

    // Fill area
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
