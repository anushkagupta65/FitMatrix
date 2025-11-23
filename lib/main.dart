// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_app/src/presentation/screens/splash_screen.dart';
import 'package:health_app/src/provider/metrics_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(metricsNotifierProvider.notifier).ensureLoaded();

    return ScreenUtilInit(
      designSize: Size(360, 840),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 0.85),
          child: MaterialApp(
            title: 'FitMatrix',
            debugShowCheckedModeBanner: false,

            // Light Theme
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.teal,
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF8F9FD),
              cardColor: Colors.white,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
            ),

            // Dark Theme
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.teal,
              useMaterial3: true,
              scaffoldBackgroundColor: const Color.fromARGB(255, 17, 17, 17),
              cardColor: const Color(0xFF1E1E1E),
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.dark,
                surface: const Color(0xFF1E1E1E),
              ),
            ),
            themeMode: ThemeMode.system,

            home: SplashScreen(),
          ),
        );
      },
    );
  }
}
