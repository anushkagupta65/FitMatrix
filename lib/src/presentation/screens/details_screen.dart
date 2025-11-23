// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_app/src/data/models/metric.dart';
import 'package:health_app/src/provider/metrics_provider.dart';
import 'package:health_app/src/presentation/widgets/history_card.dart';
import 'package:health_app/src/presentation/screens/history_screen.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Metric metric;
  const DetailScreen({super.key, required this.metric});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _randomAddController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _randomAddController.dispose();
    super.dispose();
  }

  (Color, Color) _getThemeColors(String status, bool isDark) {
    if (isDark) {
      switch (status.toLowerCase()) {
        case 'normal':
          return (const Color(0xFF69F0AE), const Color(0xFF1B5E20));
        case 'high':
          return (const Color(0xFFFFAB40), const Color(0xFFE65100));
        case 'low':
          return (const Color(0xFFFF5252), const Color(0xFFB71C1C));
        default:
          return (const Color(0xFFE0E0E0), const Color(0xFF424242));
      }
    }

    switch (status.toLowerCase()) {
      case 'normal':
        return (const Color(0xFF4CAF50), const Color(0xFFE8F5E9));
      case 'high':
        return (const Color(0xFFFF9800), const Color(0xFFFFF3E0));
      case 'low':
        return (const Color(0xFFEF5350), const Color(0xFFFFEBEE));
      default:
        return (const Color(0xFF78909C), const Color(0xFFECEFF1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Watch latest version of this metric
    final metricLatest = ref.watch(
      metricsNotifierProvider.select(
        (list) => list.firstWhere(
          (m) => m.name == widget.metric.name,
          orElse: () => widget.metric,
        ),
      ),
    );

    final (accentColor, lightBgColor) = _getThemeColors(
      metricLatest.status,
      isDarkMode,
    );
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3142);
    final secondaryText = Colors.grey[500];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 24.h,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 16.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Header Gradient Section
            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accentColor, accentColor.withOpacity(0.5)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Big Icon
                    Hero(
                      tag: 'icon-${metricLatest.name}',
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2.w,
                          ),
                        ),
                        child: Text(
                          metricLatest.name[0],
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      metricLatest.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Normal Range: ${metricLatest.range}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Overlapping Card
            Transform.translate(
              offset: Offset(0, -20.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Hero(
                  tag: 'card-${metricLatest.name}',
                  child: Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(14),
                    color:
                        isDarkMode
                            ? const Color.fromARGB(255, 40, 40, 40)
                            : Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Value',
                                style: GoogleFonts.poppins(
                                  color: secondaryText,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    metricLatest.value.toStringAsFixed(
                                      metricLatest.value % 1 == 0 ? 0 : 1,
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                      height: 1.0,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 6.h),
                                    child: Text(
                                      metricLatest.unit,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode
                                      ? lightBgColor.withOpacity(0.25)
                                      : lightBgColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              metricLatest.status.toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Animated Content
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      Text(
                        'Analytics',
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      HistoryChart(
                        history: metricLatest.history,
                        accentColor: accentColor,
                      ),

                      SizedBox(height: 32.h),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => HistoryScreen(
                                      metricName: metricLatest.name,
                                    ),
                              ),
                            );
                          },
                          icon: Icon(Icons.history, size: 22.sp),
                          label: Text(
                            'View Full History',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor.withOpacity(0.15),
                            foregroundColor: accentColor,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: accentColor.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Text(
                        'Update Data',
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isDarkMode
                                    ? Colors.white10
                                    : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _randomAddController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                  color: textColor,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter new value...',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey[400],
                                    fontSize: 15.sp,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 8.h,
                                  ),
                                  suffixText: metricLatest.unit,
                                  suffixStyle: GoogleFonts.poppins(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final txt = _randomAddController.text.trim();
                                final parsed = double.tryParse(txt);
                                if (parsed == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.redAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      content: Text(
                                        'Please enter a valid number',
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                await ref
                                    .read(metricsNotifierProvider.notifier)
                                    .addReading(
                                      metricLatest.name,
                                      parsed,
                                      timestamp: DateTime.now(),
                                    );

                                _randomAddController.clear();
                                if (context.mounted) {
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor:
                                    isDarkMode &&
                                            accentColor.computeLuminance() > 0.5
                                        ? Colors.black
                                        : Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 24.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 60.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
