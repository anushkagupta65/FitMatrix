// lib/src/screens/history_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import 'package:google_fonts/google_fonts.dart';
import 'package:health_app/src/data/models/metric.dart';
import 'package:health_app/src/provider/metrics_provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerWidget {
  final String metricName;

  const HistoryScreen({super.key, required this.metricName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(metricsNotifierProvider);
    final metric = metrics.firstWhere(
      (m) => m.name == metricName,
      orElse:
          () => Metric(
            name: metricName,
            value: 0,
            unit: '',
            status: 'unknown',
            range: '',
            history: [],
            timestamps: [], // Ensure timestamps exist
          ),
    );

    final readings = <DateTime>[];
    final values = <double>[];

    final now = DateTime.now();

    for (int i = 0; i < metric.history.length; i++) {
      final timestamp =
          metric.timestamps.length > i ? metric.timestamps[i] : now;
      readings.add(timestamp);
      values.add(metric.history[i]);
    }

    final sorted = List.generate(readings.length, (i) => i)
      ..sort((a, b) => readings[a].compareTo(readings[b]));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = _getAccentColor(metric.status);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          '${metric.name} History',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        toolbarHeight: 60.h,
      ),
      body:
          readings.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      size: 80.sp,
                      color: Colors.grey[500],
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'No history recorded yet',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Your readings will appear here once added',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount: sorted.length,
                itemBuilder: (context, idx) {
                  final i = sorted[idx];
                  final value = values[i];
                  final date = readings[i];

                  double prevValue;
                  if (idx == 0) {
                    final lower = _parseLowerRange(metric.range);
                    prevValue = lower ?? value;
                  } else {
                    prevValue = values[sorted[idx - 1]];
                  }

                  final trend =
                      value > prevValue
                          ? Trend.up
                          : value < prevValue
                          ? Trend.down
                          : Trend.same;

                  return Card(
                    margin: EdgeInsets.only(bottom: 14.h),
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      leading: CircleAvatar(
                        radius: 26.r,
                        backgroundColor: accentColor.withOpacity(0.15),
                        child: Text(
                          metric.name[0].toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      title: Text(
                        '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} ${metric.unit}',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: Text(
                          DateFormat('MMM dd, yyyy • h:mm a').format(date),
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      trailing: _buildTrendIcon(trend, accentColor),
                    ),
                  );
                },
              ),
    );
  }

  double? _parseLowerRange(String range) {
    if (range.isEmpty) return null;
    final match = RegExp(r'[-+]?\d*\.?\d+').firstMatch(range);
    if (match == null) return null;
    try {
      return double.parse(match.group(0)!);
    } catch (_) {
      return null;
    }
  }

  Color _getAccentColor(String status) {
    return switch (status.toLowerCase()) {
      'normal' => const Color(0xFF4CAF50),
      'high' => const Color(0xFFFF9800),
      'low' => const Color(0xFFEF5350),
      _ => Colors.grey,
    };
  }

  Widget _buildTrendIcon(Trend trend, Color color) {
    final isUp = trend == Trend.up;
    final isDown = trend == Trend.down;

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color:
            isUp
                ? Colors.red.withOpacity(0.12)
                : isDown
                ? Colors.green.withOpacity(0.12)
                : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isUp
                  ? Colors.red.withOpacity(0.2)
                  : isDown
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        isUp
            ? Icons.trending_up_rounded
            : isDown
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded,
        color:
            isUp
                ? Colors.redAccent
                : isDown
                ? Colors.green
                : Colors.grey[600],
        size: 26.sp,
      ),
    );
  }
}

enum Trend { up, down, same }
