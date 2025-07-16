import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/timer_provider.dart';
import '../../../shared/widgets/glass_container.dart';

class HangmanTimer extends ConsumerStatefulWidget {
  const HangmanTimer({super.key});

  @override
  ConsumerState<HangmanTimer> createState() => _HangmanTimerState();
}

class _HangmanTimerState extends ConsumerState<HangmanTimer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(timerProvider);

    // Trigger animations based on timer state
    ref.listen(timerProvider, (previous, current) {
      if (current.isCritical && !_shakeController.isAnimating) {
        _shakeController.repeat(reverse: true);
        _pulseController.repeat(reverse: true);
      } else if (current.isWarning && !current.isCritical && !_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
        _shakeController.stop();
      } else if (!current.isWarning && !current.isCritical) {
        _pulseController.stop();
        _shakeController.stop();
      }
    });

    if (timer.timerState == TimerState.idle) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_shakeAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            timer.isCritical ? _shakeAnimation.value : 0,
            0,
          ),
          child: Transform.scale(
            scale: timer.isWarning ? _pulseAnimation.value : 1.0,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glassmorphic background
                  GlassContainer(
                    borderRadius: BorderRadius.circular(50),
                    gradient: LinearGradient(
                      colors: _getGradientColors(timer),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getGradientColors(timer)[0].withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Circular progress indicator
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: timer.progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(timer),
                      ),
                    ),
                  ),

                  // Timer text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          '${timer.remainingSeconds}',
                          key: ValueKey(timer.remainingSeconds),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        'seconds',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),

                  // Warning pulse effect
                  if (timer.isCritical)
                    IgnorePointer(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red.withOpacity(
                              0.5 * _pulseAnimation.value,
                            ),
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Color> _getGradientColors(TimerModel timer) {
    if (timer.isCritical) {
      return [const Color(0xFFF44336), const Color(0xFFE91E63)];
    } else if (timer.isWarning) {
      return [const Color(0xFFFF9800), const Color(0xFFFFC107)];
    } else {
      return [const Color(0xFF4CAF50), const Color(0xFF8BC34A)];
    }
  }

  Color _getProgressColor(TimerModel timer) {
    if (timer.isCritical) {
      return Colors.red;
    } else if (timer.isWarning) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}