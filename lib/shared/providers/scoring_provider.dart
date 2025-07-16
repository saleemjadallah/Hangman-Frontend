import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_enums.dart';

class GameResult {
  final int score;
  final GameDifficulty difficulty;
  final String playerName;
  final DateTime timestamp;
  final int timeToComplete;
  final bool isPerfectGame;
  final String wordGuessed;

  const GameResult({
    required this.score,
    required this.difficulty,
    required this.playerName,
    required this.timestamp,
    required this.timeToComplete,
    required this.isPerfectGame,
    required this.wordGuessed,
  });

  Map<String, dynamic> toJson() => {
        'score': score,
        'difficulty': difficulty.name,
        'playerName': playerName,
        'timestamp': timestamp.toIso8601String(),
        'timeToComplete': timeToComplete,
        'isPerfectGame': isPerfectGame,
        'wordGuessed': wordGuessed,
      };

  factory GameResult.fromJson(Map<String, dynamic> json) => GameResult(
        score: json['score'],
        difficulty: GameDifficulty.values.firstWhere(
          (e) => e.name == json['difficulty'],
        ),
        playerName: json['playerName'],
        timestamp: DateTime.parse(json['timestamp']),
        timeToComplete: json['timeToComplete'],
        isPerfectGame: json['isPerfectGame'],
        wordGuessed: json['wordGuessed'],
      );
}

class ScoringState {
  final int totalScore;
  final int gamesPlayed;
  final int dailyGamesPlayed;
  final List<GameResult> recentScores;
  final int currentStreak;
  final DateTime? lastPlayDate;

  const ScoringState({
    required this.totalScore,
    required this.gamesPlayed,
    required this.dailyGamesPlayed,
    required this.recentScores,
    required this.currentStreak,
    this.lastPlayDate,
  });

  factory ScoringState.initial() => const ScoringState(
        totalScore: 0,
        gamesPlayed: 0,
        dailyGamesPlayed: 0,
        recentScores: [],
        currentStreak: 0,
      );

  ScoringState copyWith({
    int? totalScore,
    int? gamesPlayed,
    int? dailyGamesPlayed,
    List<GameResult>? recentScores,
    int? currentStreak,
    DateTime? lastPlayDate,
  }) {
    return ScoringState(
      totalScore: totalScore ?? this.totalScore,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      dailyGamesPlayed: dailyGamesPlayed ?? this.dailyGamesPlayed,
      recentScores: recentScores ?? this.recentScores,
      currentStreak: currentStreak ?? this.currentStreak,
      lastPlayDate: lastPlayDate ?? this.lastPlayDate,
    );
  }

  int get gamesLeftToday => 15 - dailyGamesPlayed;
}

class ScoringNotifier extends StateNotifier<ScoringState> {
  ScoringNotifier() : super(ScoringState.initial()) {
    _loadState();
  }

  static const Map<GameDifficulty, double> _difficultyMultipliers = {
    GameDifficulty.easy: 1.0,
    GameDifficulty.medium: 2.0,
    GameDifficulty.hard: 3.0,
    GameDifficulty.extreme: 4.0,
  };

  static const Map<GameDifficulty, int> _basePoints = {
    GameDifficulty.easy: 100,
    GameDifficulty.medium: 150,
    GameDifficulty.hard: 200,
    GameDifficulty.extreme: 250,
  };

  static const Map<GameDifficulty, int> _completionBonus = {
    GameDifficulty.easy: 500,
    GameDifficulty.medium: 750,
    GameDifficulty.hard: 1000,
    GameDifficulty.extreme: 1500,
  };

  static const Map<GameDifficulty, int> _timeBonus = {
    GameDifficulty.easy: 50,
    GameDifficulty.medium: 75,
    GameDifficulty.hard: 100,
    GameDifficulty.extreme: 150,
  };

  static const Map<GameDifficulty, int> _wrongPenalty = {
    GameDifficulty.easy: 25,
    GameDifficulty.medium: 50,
    GameDifficulty.hard: 100,
    GameDifficulty.extreme: 150,
  };

  static const Map<GameDifficulty, int> _perfectBonus = {
    GameDifficulty.easy: 1000,
    GameDifficulty.medium: 2000,
    GameDifficulty.hard: 3000,
    GameDifficulty.extreme: 5000,
  };

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final totalScore = prefs.getInt('total_score') ?? 0;
    final gamesPlayed = prefs.getInt('games_played') ?? 0;
    final currentStreak = prefs.getInt('current_streak') ?? 0;
    
    // Check if it's a new day
    final lastPlayDateStr = prefs.getString('last_play_date');
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    
    int dailyGamesPlayed = 0;
    if (lastPlayDateStr == todayStr) {
      dailyGamesPlayed = prefs.getInt('daily_games_count') ?? 0;
    } else {
      // New day, reset daily counter
      await prefs.setInt('daily_games_count', 0);
      await prefs.setString('last_play_date', todayStr);
    }

    state = state.copyWith(
      totalScore: totalScore,
      gamesPlayed: gamesPlayed,
      dailyGamesPlayed: dailyGamesPlayed,
      currentStreak: currentStreak,
      lastPlayDate: lastPlayDateStr != null ? DateTime.parse(lastPlayDateStr) : null,
    );
  }

  int calculateScore({
    required GameDifficulty difficulty,
    required int correctLetters,
    required int wrongGuesses,
    required int timeRemaining,
    required bool isComplete,
    required int currentStreak,
  }) {
    final baseScore = _basePoints[difficulty]! * correctLetters;
    final completionBonus = isComplete ? _completionBonus[difficulty]! : 0;
    final timeBonusPoints = timeRemaining * _timeBonus[difficulty]!;
    final wrongPenalty = wrongGuesses * _wrongPenalty[difficulty]!;
    final perfectBonus = (wrongGuesses == 0 && isComplete) ? _perfectBonus[difficulty]! : 0;

    // Calculate streak multiplier
    double streakMultiplier = 1.0;
    if (currentStreak >= 11) {
      streakMultiplier = 1.5;
    } else if (currentStreak >= 6) {
      streakMultiplier = 1.25;
    } else if (currentStreak >= 2) {
      streakMultiplier = 1.1;
    }

    final subtotal = baseScore + completionBonus + timeBonusPoints + perfectBonus - wrongPenalty;
    final difficultyMultiplier = _difficultyMultipliers[difficulty]!;

    final finalScore = (subtotal * difficultyMultiplier * streakMultiplier).round();

    return finalScore > 0 ? finalScore : 0;
  }

  Future<bool> canPlayToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPlayDate = prefs.getString('last_play_date');
    final todayString = DateTime.now().toIso8601String().split('T')[0];

    if (lastPlayDate != todayString) {
      // New day, reset counter
      await prefs.setString('last_play_date', todayString);
      await prefs.setInt('daily_games_count', 0);
      state = state.copyWith(dailyGamesPlayed: 0);
      return true;
    }

    final dailyCount = prefs.getInt('daily_games_count') ?? 0;
    return dailyCount < 15;
  }

  Future<void> submitScore({
    required int score,
    required GameDifficulty difficulty,
    required String playerName,
    required int timeToComplete,
    required bool isPerfectGame,
    required bool isWin,
    required String wordGuessed,
  }) async {
    // Check daily game limit
    if (!await canPlayToday()) {
      throw Exception('Daily game limit reached (15 games)');
    }

    final prefs = await SharedPreferences.getInstance();
    
    // Update streak
    int newStreak = state.currentStreak;
    if (isWin) {
      newStreak++;
    } else {
      newStreak = 0;
    }

    final gameResult = GameResult(
      score: score,
      difficulty: difficulty,
      playerName: playerName.isEmpty ? 'Anonymous' : playerName,
      timestamp: DateTime.now(),
      timeToComplete: timeToComplete,
      isPerfectGame: isPerfectGame,
      wordGuessed: wordGuessed,
    );

    // Update state
    state = state.copyWith(
      totalScore: state.totalScore + score,
      gamesPlayed: state.gamesPlayed + 1,
      dailyGamesPlayed: state.dailyGamesPlayed + 1,
      recentScores: [gameResult, ...state.recentScores.take(9)],
      currentStreak: newStreak,
    );

    // Save to local storage
    await prefs.setInt('total_score', state.totalScore);
    await prefs.setInt('games_played', state.gamesPlayed);
    await prefs.setInt('daily_games_count', state.dailyGamesPlayed);
    await prefs.setInt('current_streak', state.currentStreak);
    
    // Save to leaderboard
    await _saveToLeaderboard(gameResult);
  }

  Future<void> _saveToLeaderboard(GameResult result) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing leaderboard
    final leaderboardJson = prefs.getStringList('leaderboard') ?? [];
    
    // Add new result
    leaderboardJson.add(result.toJson().toString());
    
    // Keep only top 100 scores
    if (leaderboardJson.length > 100) {
      // TODO: Sort and keep only top 100
      leaderboardJson.removeRange(100, leaderboardJson.length);
    }
    
    await prefs.setStringList('leaderboard', leaderboardJson);
  }
}

final scoringProvider = StateNotifierProvider<ScoringNotifier, ScoringState>(
  (ref) => ScoringNotifier(),
);