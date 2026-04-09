import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:movie_app/core/styles/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!context.mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final seenOnboarding = false;

    if (!context.mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, 'main');
    } else if (!seenOnboarding) {
      Navigator.pushReplacementNamed(context, 'onboarding');
    } else {
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Center(
            child: Image.asset('assets/images/splash.png', width: 160)
                .animate()
                .fadeIn(duration: 1500.ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 1500.ms,
                  curve: Curves.easeOutBack,
                ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset('assets/images/route_logo.png', width: 200),
                const SizedBox(height: 10),
                Image.asset(
                  'assets/images/Supervised by Mohamed Nabil.png',
                  width: 150,
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 1500.ms)
                .slideX(begin: -1.5, curve: Curves.easeOutBack),
          ),
        ],
      ),
    );
  }
}
