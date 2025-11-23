// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added
import 'package:google_fonts/google_fonts.dart';
import 'package:health_app/src/provider/metrics_provider.dart';
import 'package:health_app/src/presentation/widgets/metric_card.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(metricsNotifierProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Dynamic Status Bar
    SystemChrome.setSystemUIOverlayStyle(
      isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      body: RefreshIndicator(
        color: Colors.teal,
        backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        onRefresh: () async {
          await ref.read(metricsNotifierProvider.notifier).ensureLoaded();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const _SliverHomeHeader(),

            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 6.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Vitals',
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            isDarkMode
                                ? Colors.white
                                : const Color.fromRGBO(45, 49, 66, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final metric = metrics[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: MetricCard(metric: metric, index: index),
                  );
                }, childCount: metrics.length),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 80.h)),
          ],
        ),
      ),
    );
  }
}

class _SliverHomeHeader extends StatelessWidget {
  const _SliverHomeHeader();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMM').format(now);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 164.h,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDarkMode
                      ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                      : [const Color(0xFF2E3A59), const Color(0xFF455A64)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting + Avatar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateStr.toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12.sp,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Hello, Alex',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 16.r,
                              offset: Offset(0, 6.h),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 28.r,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: const Color(0xFF2E3A59),
                            size: 32.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Summary Card
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10, width: 1),
                    ),
                    child: Row(
                      children: [
                        _buildSummaryItem('Health Score', '92', true),
                        _buildDivider(),
                        _buildSummaryItem('Alerts', '0', false),
                        _buildDivider(),
                        _buildSummaryItem('Trends', '+2.4%', true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40.h,
      color: Colors.white24,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
    );
  }

  Widget _buildSummaryItem(String label, String value, bool isGood) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
