import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/theme.dart';

class SOSTimerDialog extends StatefulWidget {
  final VoidCallback onTimeout;
  final VoidCallback onDismiss;

  const SOSTimerDialog({
    super.key,
    required this.onTimeout,
    required this.onDismiss,
  });

  @override
  State<SOSTimerDialog> createState() => _SOSTimerDialogState();
}

class _SOSTimerDialogState extends State<SOSTimerDialog>
    with TickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();

    // Setup pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);

    // Start countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
      });

      if (_secondsRemaining <= 0) {
        _timer.cancel();
        widget.onTimeout();
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emergency Icon with pulse animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.dangerTone,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dangerTone.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Title
            const Text(
              'Emergency SOS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.dangerTone,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            const Text(
              'Your SOS alert will be sent to authorities in:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Countdown display
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.dangerTone.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.dangerTone, width: 4),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _secondsRemaining.toString(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dangerTone,
                      ),
                    ),
                    const Text(
                      'seconds',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.dangerTone,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _timer.cancel();
                      widget.onDismiss();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'I\'m Safe',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _timer.cancel();
                      widget.onTimeout();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dangerTone,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Send SOS Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress indicator
            LinearProgressIndicator(
              value: _secondsRemaining / 60,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _secondsRemaining > 20
                    ? AppColors.cautionTone
                    : AppColors.dangerTone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
