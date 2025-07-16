import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_enums.dart';

enum TimerState { idle, running, paused, expired }

class TimerModel {
  final int totalSeconds;
  final int remainingSeconds;
  final TimerState timerState;
  final GameDifficulty difficulty;
  final bool isWarning;
  final bool isCritical;

  const TimerModel({
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.timerState,
    required this.difficulty,
    this.isWarning = false,
    this.isCritical = false,
  });

  factory TimerModel.initial() => const TimerModel(
        totalSeconds: 0,
        remainingSeconds: 0,
        timerState: TimerState.idle,
        difficulty: GameDifficulty.medium,
      );

  TimerModel copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    TimerState? timerState,
    GameDifficulty? difficulty,
    bool? isWarning,
    bool? isCritical,
  }) {
    return TimerModel(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      timerState: timerState ?? this.timerState,
      difficulty: difficulty ?? this.difficulty,
      isWarning: isWarning ?? this.isWarning,
      isCritical: isCritical ?? this.isCritical,
    );
  }

  double get progress =>
      totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

  double get inverseProgress =>
      totalSeconds > 0 ? (totalSeconds - remainingSeconds) / totalSeconds : 0.0;
}

class TimerNotifier extends StateNotifier<TimerModel> {
  TimerNotifier(this.ref) : super(TimerModel.initial());

  final Ref ref;
  Timer? _timer;

  // Timer durations by difficulty
  static const Map<GameDifficulty, int> _durations = {
    GameDifficulty.easy: 15,
    GameDifficulty.medium: 10,
    GameDifficulty.hard: 6,
    GameDifficulty.extreme: 4,
  };

  void startTimer(GameDifficulty difficulty) {
    final duration = _durations[difficulty]!;
    state = state.copyWith(
      totalSeconds: duration,
      remainingSeconds: duration,
      timerState: TimerState.running,
      difficulty: difficulty,
      isWarning: false,
      isCritical: false,
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0 && state.timerState == TimerState.running) {
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
        );
        _checkWarningStates();
      } else if (state.remainingSeconds == 0) {
        _expireTimer();
      }
    });
  }

  void pauseTimer() {
    if (state.timerState == TimerState.running) {
      _timer?.cancel();
      state = state.copyWith(timerState: TimerState.paused);
    }
  }

  void resumeTimer() {
    if (state.timerState == TimerState.paused && state.remainingSeconds > 0) {
      state = state.copyWith(timerState: TimerState.running);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.remainingSeconds > 0 && state.timerState == TimerState.running) {
          state = state.copyWith(
            remainingSeconds: state.remainingSeconds - 1,
          );
          _checkWarningStates();
        } else if (state.remainingSeconds == 0) {
          _expireTimer();
        }
      });
    }
  }

  void resetTimer() {
    _timer?.cancel();
    state = TimerModel.initial();
  }

  void stopTimer() {
    _timer?.cancel();
    state = state.copyWith(timerState: TimerState.idle);
  }

  void _checkWarningStates() {
    final percentage = state.progress;

    if (percentage <= 0.25 && !state.isCritical) {
      state = state.copyWith(isCritical: true, isWarning: true);
      _triggerCriticalWarning();
    } else if (percentage <= 0.5 && !state.isWarning) {
      state = state.copyWith(isWarning: true);
      _triggerWarning();
    }
  }

  void _expireTimer() {
    _timer?.cancel();
    state = state.copyWith(timerState: TimerState.expired, remainingSeconds: 0);
    
    // Auto-select a random unguessed letter
    _autoSelectLetter();
  }

  void _autoSelectLetter() {
    // This will be connected to the game logic
    // For now, just mark as expired
  }

  void _triggerWarning() {
    // TODO: Play warning sound
  }

  void _triggerCriticalWarning() {
    // TODO: Play critical sound and haptic feedback
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerModel>(
  (ref) => TimerNotifier(ref),
);