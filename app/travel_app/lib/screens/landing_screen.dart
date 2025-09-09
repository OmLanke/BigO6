import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
              theme.colorScheme.tertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // App Logo and Title
                Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.location_on,
                        size: 60,
                        color: theme.colorScheme.primary,
                      ),
                    ).animate().scale(
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    ),

                    const SizedBox(height: 24),

                    Text(
                          'Tour Raksha',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: 0.5, end: 0),

                    const SizedBox(height: 12),

                    Text(
                          'Your companion for safe travels',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideY(begin: 0.5, end: 0),
                  ],
                ),

                const Spacer(flex: 2),

                // Features List
                Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildFeatureItem(
                            Icons.location_on,
                            'Real-time Location Tracking',
                            'Stay connected with live location updates',
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureItem(
                            Icons.security,
                            'Safety Alerts',
                            'Receive alerts about safety conditions',
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureItem(
                            Icons.map,
                            'Interactive Safety Map',
                            'Explore areas with safety indicators',
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const Spacer(flex: 2),

                // Action Buttons
                Column(
                  children: [
                    SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => context.go('/onboarding'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 800.ms)
                        .slideY(begin: 0.5, end: 0),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: Text(
                        'Continue as Guest',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
