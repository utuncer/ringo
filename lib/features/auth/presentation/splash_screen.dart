import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Auth state is handled by the router redirect, so we just need to wait a bit
    // and then let the router take over.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // The router redirect will kick in once the auth state is determined.
        // If we are here, it means we might need to trigger a refresh or just wait.
        // Actually, with Riverpod watching auth state in the router, it should happen automatically.
        // But for the initial load, we might want to manually push if nothing happens.
        // However, let's just rely on the router redirect for now.
        // If the user is not logged in, they should go to login.
        // If logged in, go to home.

        // For now, force navigation to login if not redirected (just for testing flow)
        // context.go('/login');
        // BETTER: Let the router redirect handle it.
        // But we need to make sure the router knows we are done "splashing".
        // Since we are using a Stream in the router, it updates automatically.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Icon(Icons.rocket_launch, size: 80, color: AppColors.primary),
            const SizedBox(height: 20),
            const Text(
              'Ringo',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppColors.accentHighlight),
          ],
        ),
      ),
    );
  }
}
