// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import 'package:google_fonts/google_fonts.dart';

class HistoryChart extends StatefulWidget {
  final List<double> history;
  final Color accentColor;

  const HistoryChart({
    super.key,
    required this.history,
    this.accentColor = Colors.teal,
  });

  @override
  State<HistoryChart> createState() => _HistoryChartState();
}

class _HistoryChartState extends State<HistoryChart> {
  String formatVal(double v) {
    if ((v - v.round()).abs() < 0.001) {
      return v.toStringAsFixed(0);
    }
    return v.toStringAsFixed(1);
  }

  void _updateSelectionFromTouch(
    FlTouchEvent event,
    LineTouchResponse? response,
  ) {
    if (response == null ||
        response.lineBarSpots == null ||
        response.lineBarSpots!.isEmpty) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = widget.history;
    final accentColor = widget.accentColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // -- Responsive Design Constants --
    final cardBackgroundColor =
        isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final cardShadow =
        isDarkMode
            ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 24.r,
                offset: Offset(0, 12.h),
              ),
              BoxShadow(
                color: accentColor.withOpacity(0.1),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ]
            : [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 24.r,
                offset: Offset(0, 12.h),
              ),
              BoxShadow(
                color: accentColor.withOpacity(0.25),
                blurRadius: 16.r,
                offset: Offset(0, 6.h),
              ),
            ];

    if (history.isEmpty) {
      return Container(
        height: 180.h,
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: cardShadow,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
              size: 60.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'No history data available',
              style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.white38 : Colors.grey[600],
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add readings to see your trend',
              style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.white24 : Colors.grey[500],
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      );
    }

    // -- Data Calculation --
    final minY = history.reduce(min);
    final maxY = history.reduce(max);
    final average = history.reduce((a, b) => a + b) / history.length;
    final yRange = (maxY - minY).abs();
    final paddedMinY = minY - (yRange == 0 ? minY * 0.1 + 1 : yRange * 0.15);
    final paddedMaxY = maxY + (yRange == 0 ? minY * 0.1 + 1 : yRange * 0.15);

    int xLabelInterval;
    if (history.length <= 8) {
      xLabelInterval = 1;
    } else if (history.length <= 15) {
      xLabelInterval = 2;
    } else {
      xLabelInterval = (history.length / 4).ceil();
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: cardShadow,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stat Badges Row
              Padding(
                padding: EdgeInsets.only(bottom: 36.h),
                child: Row(
                  children: [
                    Expanded(
                      child: _ChartStatBadge(
                        label: 'MIN',
                        value: formatVal(minY),
                        color: Colors.blueGrey,
                        icon: Icons.arrow_downward_rounded,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _ChartStatBadge(
                        label: 'AVG',
                        value: formatVal(average),
                        color: accentColor,
                        isActive: true,
                        icon: Icons.auto_graph_rounded,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _ChartStatBadge(
                        label: 'MAX',
                        value: formatVal(maxY),
                        color: Colors.orangeAccent,
                        icon: Icons.arrow_upward_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              // The Chart
              SizedBox(
                height: 180.h,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      verticalInterval: max(
                        1,
                        (history.length / 5).floorToDouble(),
                      ),
                      horizontalInterval: yRange == 0 ? 1 : yRange / 4,
                      getDrawingHorizontalLine:
                          (_) => FlLine(
                            color:
                                isDarkMode
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.grey.withOpacity(0.12),
                            strokeWidth: 1,
                            dashArray: [10, 8],
                          ),
                      getDrawingVerticalLine:
                          (_) => FlLine(
                            color:
                                isDarkMode
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.grey.withOpacity(0.12),
                            strokeWidth: 1,
                          ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60.h,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value != value.toInt()) {
                              return const SizedBox.shrink();
                            }
                            final idx = value.toInt();
                            if (idx < 0 || idx >= history.length) {
                              return const SizedBox.shrink();
                            }

                            final showLabel =
                                idx == 0 ||
                                idx == history.length - 1 ||
                                idx == history.length ~/ 2 ||
                                idx % xLabelInterval == 0;

                            if (!showLabel) return const SizedBox.shrink();

                            final isLast = idx == history.length - 1;
                            final valString = formatVal(history[idx]);

                            return Padding(
                              padding: EdgeInsets.only(top: 6.h),
                              child: Column(
                                children: [
                                  Text(
                                    'T$idx',
                                    style: GoogleFonts.poppins(
                                      color:
                                          isLast
                                              ? accentColor
                                              : (isDarkMode
                                                  ? Colors.white38
                                                  : Colors.grey.shade500),
                                      fontSize: 11.sp,
                                      fontWeight:
                                          isLast
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    valString,
                                    style: GoogleFonts.poppins(
                                      color:
                                          isDarkMode
                                              ? Colors.white70
                                              : Colors.black87,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36.w,
                          interval: yRange == 0 ? 1 : yRange / 4,
                          getTitlesWidget: (value, meta) {
                            if (value == paddedMinY || value == paddedMaxY) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: Text(
                                formatVal(value),
                                style: GoogleFonts.poppins(
                                  color:
                                      isDarkMode
                                          ? Colors.white38
                                          : Colors.grey.shade500,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (history.length - 1).toDouble(),
                    minY: paddedMinY,
                    maxY: paddedMaxY,
                    lineTouchData: LineTouchData(
                      touchCallback: _updateSelectionFromTouch,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor:
                            isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                        tooltipRoundedRadius: 16.r,
                        tooltipPadding: EdgeInsets.all(14.w),
                        tooltipBorder: BorderSide(
                          color: isDarkMode ? Colors.white10 : Colors.black12,
                          width: 1,
                        ),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final idx = spot.x.toInt();
                            return LineTooltipItem(
                              '',
                              const TextStyle(),
                              children: [
                                TextSpan(
                                  text: 'T$idx\n',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color:
                                        isDarkMode
                                            ? Colors.white60
                                            : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: formatVal(spot.y),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                      handleBuiltInTouches: true,
                      getTouchedSpotIndicator: (barData, spotIndexes) {
                        return spotIndexes.map((i) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: accentColor,
                              strokeWidth: 2.5,
                              dashArray: [6, 6],
                            ),
                            FlDotData(
                              getDotPainter:
                                  (_, __, ___, ____) => FlDotCirclePainter(
                                    radius: 8.r,
                                    color:
                                        isDarkMode
                                            ? Colors.black87
                                            : Colors.white,
                                    strokeWidth: 4,
                                    strokeColor: accentColor,
                                  ),
                            ),
                          );
                        }).toList();
                      },
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          history.length,
                          (i) => FlSpot(i.toDouble(), history[i]),
                        ),
                        isCurved: true,
                        curveSmoothness: 0.35,
                        preventCurveOverShooting: true,
                        gradient: LinearGradient(
                          colors: [accentColor.withOpacity(0.6), accentColor],
                        ),
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, _, __, index) {
                            final y = spot.y;
                            final isMin = (y - minY).abs() < 0.0001;
                            final isMax = (y - maxY).abs() < 0.0001;

                            if (isMin) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: cardBackgroundColor,
                                strokeWidth: 2,
                                strokeColor: Colors.blueAccent,
                              );
                            }
                            if (isMax) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: cardBackgroundColor,
                                strokeWidth: 2,
                                strokeColor: Colors.redAccent,
                              );
                            }
                            return FlDotCirclePainter(
                              radius: 4,
                              color: cardBackgroundColor,
                              strokeWidth: 2,
                              strokeColor: accentColor.withOpacity(0.7),
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              accentColor.withOpacity(0.5),
                              accentColor.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartStatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isActive;
  final IconData? icon;

  const _ChartStatBadge({
    required this.label,
    required this.value,
    required this.color,
    this.isActive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color:
            isActive
                ? color.withOpacity(0.15)
                : (isDarkMode
                    ? Colors.white.withOpacity(0.04)
                    : Colors.grey.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color.withOpacity(0.4) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 10.sp,
                  color:
                      isActive
                          ? color
                          : (isDarkMode ? Colors.white38 : Colors.grey[600]),
                ),
                SizedBox(width: 6.w),
              ],
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      isActive
                          ? color
                          : (isDarkMode ? Colors.white38 : Colors.grey[600]),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
