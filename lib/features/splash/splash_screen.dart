import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '../../routes/app_routes.dart';
import '../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    // Rotation animation for loading indicator
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    // Check Firebase Auth state for persistent login
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

    // Double check with both Firebase Auth and SharedPreferences
    final isLoggedIn =
        user != null && (prefs.getBool(AppConstants.isLoggedInKey) ?? false);

    if (!mounted) return;

    // Navigate to appropriate screen
    // If user is logged in, go directly to home (maintaining previous state)
    // Otherwise, show welcome screen
    Navigator.of(
      context,
    ).pushReplacementNamed(isLoggedIn ? AppRoutes.home : AppRoutes.welcome);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Joy SVG Logo
            SvgPicture.asset('lib/Resources/joy.svg', width: 180, height: 180),
            const SizedBox(height: 40),

            // App Name "Chatty"
            Text(
              'Chatty',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFEFD9B0),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 80),

            // Loading text with rotating Flutter icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rotating Flutter Logo
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: child,
                    );
                  },
                  child: const FlutterLogo(
                    size: 20,
                    style: FlutterLogoStyle.markOnly,
                  ),
                ),
                const SizedBox(width: 12),

                // Loading text
                Text(
                  'Loading...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEFD9B0),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
