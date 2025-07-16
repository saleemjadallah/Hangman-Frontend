import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/game_enums.dart';
import 'scoring_provider.dart';
import 'leaderboard_provider.dart';

class GameStats {
  final int totalGamesPlayed;
  final int totalWins;
  final int currentStreak;
  final int bestStreak;
  final int perfectGames;
  final int speedWins; // under 30 seconds
  final int closeCallWins; // 1 guess remaining
  final int extremeWins;
  final int lossStreak;
  final Set<String> lettersGuessedInCurrentGame;
  final bool hasGuessedAllLetters;
  final bool hasWonWithoutVowels;
  final DateTime? lastPlayedAt;

  const GameStats({
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.perfectGames = 0,
    this.speedWins = 0,
    this.closeCallWins = 0,
    this.extremeWins = 0,
    this.lossStreak = 0,
    this.lettersGuessedInCurrentGame = const {},
    this.hasGuessedAllLetters = false,
    this.hasWonWithoutVowels = false,
    this.lastPlayedAt,
  });

  GameStats copyWith({
    int? totalGamesPlayed,
    int? totalWins,
    int? currentStreak,
    int? bestStreak,
    int? perfectGames,
    int? speedWins,
    int? closeCallWins,
    int? extremeWins,
    int? lossStreak,
    Set<String>? lettersGuessedInCurrentGame,
    bool? hasGuessedAllLetters,
    bool? hasWonWithoutVowels,
    DateTime? lastPlayedAt,
  }) {
    return GameStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalWins: totalWins ?? this.totalWins,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      perfectGames: perfectGames ?? this.perfectGames,
      speedWins: speedWins ?? this.speedWins,
      closeCallWins: closeCallWins ?? this.closeCallWins,
      extremeWins: extremeWins ?? this.extremeWins,
      lossStreak: lossStreak ?? this.lossStreak,
      lettersGuessedInCurrentGame: lettersGuessedInCurrentGame ?? this.lettersGuessedInCurrentGame,
      hasGuessedAllLetters: hasGuessedAllLetters ?? this.hasGuessedAllLetters,
      hasWonWithoutVowels: hasWonWithoutVowels ?? this.hasWonWithoutVowels,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalGamesPlayed': totalGamesPlayed,
    'totalWins': totalWins,
    'currentStreak': currentStreak,
    'bestStreak': bestStreak,
    'perfectGames': perfectGames,
    'speedWins': speedWins,
    'closeCallWins': closeCallWins,
    'extremeWins': extremeWins,
    'lossStreak': lossStreak,
    'lastPlayedAt': lastPlayedAt?.toIso8601String(),
  };

  factory GameStats.fromJson(Map<String, dynamic> json) => GameStats(
    totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
    totalWins: json['totalWins'] ?? 0,
    currentStreak: json['currentStreak'] ?? 0,
    bestStreak: json['bestStreak'] ?? 0,
    perfectGames: json['perfectGames'] ?? 0,
    speedWins: json['speedWins'] ?? 0,
    closeCallWins: json['closeCallWins'] ?? 0,
    extremeWins: json['extremeWins'] ?? 0,
    lossStreak: json['lossStreak'] ?? 0,
    lastPlayedAt: json['lastPlayedAt'] != null ? DateTime.parse(json['lastPlayedAt']) : null,
  );
}

class AchievementState {
  final Map<String, Achievement> achievements;
  final GameStats gameStats;
  final List<Achievement> recentlyUnlocked;
  final bool isLoading;

  const AchievementState({
    required this.achievements,
    required this.gameStats,
    this.recentlyUnlocked = const [],
    this.isLoading = false,
  });

  factory AchievementState.initial() => AchievementState(
    achievements: Map.fromEntries(
      Achievements.allAchievements.map((a) => MapEntry(a.id, a))
    ),
    gameStats: const GameStats(),
  );

  AchievementState copyWith({
    Map<String, Achievement>? achievements,
    GameStats? gameStats,
    List<Achievement>? recentlyUnlocked,
    bool? isLoading,
  }) {
    return AchievementState(
      achievements: achievements ?? this.achievements,
      gameStats: gameStats ?? this.gameStats,
      recentlyUnlocked: recentlyUnlocked ?? this.recentlyUnlocked,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get totalUnlocked => achievements.values.where((a) => a.isUnlocked).length;
  int get totalAchievements => achievements.length;
  double get completionPercentage => totalAchievements > 0 ? (totalUnlocked / totalAchievements) * 100 : 0;

  List<Achievement> get unlockedAchievements => 
    achievements.values.where((a) => a.isUnlocked).toList()
      ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));

  List<Achievement> get lockedAchievements => 
    achievements.values.where((a) => !a.isUnlocked && !a.isSecret).toList();

  List<Achievement> getByCategory(AchievementCategory category) =>
    achievements.values.where((a) => a.category == category && (!a.isSecret || a.isUnlocked)).toList();
}

class AchievementNotifier extends StateNotifier<AchievementState> {
  AchievementNotifier() : super(AchievementState.initial()) {
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load game stats
      final statsJson = prefs.getString('game_stats');
      final gameStats = statsJson != null 
        ? GameStats.fromJson(jsonDecode(statsJson))
        : const GameStats();

      // Load achievement progress
      final achievementsJson = prefs.getString('achievements') ?? '{}';
      final savedProgress = jsonDecode(achievementsJson) as Map<String, dynamic>;

      // Update achievements with saved progress
      final updatedAchievements = <String, Achievement>{};
      for (final achievement in Achievements.allAchievements) {
        if (savedProgress.containsKey(achievement.id)) {
          updatedAchievements[achievement.id] = Achievement.fromPredefined(
            achievement,
            savedProgress[achievement.id],
          );
        } else {
          updatedAchievements[achievement.id] = achievement;
        }
      }

      state = state.copyWith(
        achievements: updatedAchievements,
        gameStats: gameStats,
        isLoading: false,
      );

      // Update progress for progression achievements
      _updateProgressionAchievements();
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save game stats
    await prefs.setString('game_stats', jsonEncode(state.gameStats.toJson()));

    // Save achievement progress
    final achievementData = <String, dynamic>{};
    for (final achievement in state.achievements.values) {
      achievementData[achievement.id] = achievement.toJson();
    }
    await prefs.setString('achievements', jsonEncode(achievementData));
  }

  void _updateProgressionAchievements() {
    final achievements = Map<String, Achievement>.from(state.achievements);
    
    // Update progress for progression achievements
    achievements['word_master'] = achievements['word_master']!.copyWith(
      progress: state.gameStats.totalWins / achievements['word_master']!.requiredValue,
    );
    
    achievements['streak_master'] = achievements['streak_master']!.copyWith(
      progress: state.gameStats.bestStreak / achievements['streak_master']!.requiredValue,
    );

    state = state.copyWith(achievements: achievements);
  }

  Future<List<Achievement>> checkAndUnlockAchievements({
    required bool isWin,
    required GameDifficulty difficulty,
    required int wrongGuesses,
    required int maxWrongGuesses,
    required int timeToComplete,
    required Set<String> guessedLetters,
    required String word,
    required int currentStreak,
    required int dailyGamesPlayed,
    String? playerId,
  }) async {
    final newlyUnlocked = <Achievement>[];
    final achievements = Map<String, Achievement>.from(state.achievements);
    var stats = state.gameStats;

    // Update game stats
    stats = stats.copyWith(
      totalGamesPlayed: stats.totalGamesPlayed + 1,
      totalWins: isWin ? stats.totalWins + 1 : stats.totalWins,
      currentStreak: isWin ? currentStreak : 0,
      bestStreak: currentStreak > stats.bestStreak ? currentStreak : stats.bestStreak,
      lossStreak: isWin ? 0 : stats.lossStreak + 1,
      lastPlayedAt: DateTime.now(),
    );

    if (isWin) {
      // Check for perfect game
      if (wrongGuesses == 0) {
        stats = stats.copyWith(perfectGames: stats.perfectGames + 1);
        newlyUnlocked.addAll(await _checkAndUnlock(['flawless_victory'], achievements));
      }

      // Check for speed win
      if (timeToComplete < 30) {
        stats = stats.copyWith(speedWins: stats.speedWins + 1);
        newlyUnlocked.addAll(await _checkAndUnlock(['speed_demon'], achievements));
      }

      // Check for close call
      if (maxWrongGuesses - wrongGuesses == 1) {
        stats = stats.copyWith(closeCallWins: stats.closeCallWins + 1);
        newlyUnlocked.addAll(await _checkAndUnlock(['last_second_save'], achievements));
      }

      // Check for extreme win
      if (difficulty == GameDifficulty.extreme) {
        stats = stats.copyWith(extremeWins: stats.extremeWins + 1);
        newlyUnlocked.addAll(await _checkAndUnlock(['extreme_champion'], achievements));
      }

      // Check for comeback
      if (wrongGuesses >= 5) {
        newlyUnlocked.addAll(await _checkAndUnlock(['comeback'], achievements));
      }

      // Check for first win
      if (stats.totalWins == 1) {
        newlyUnlocked.addAll(await _checkAndUnlock(['first_win'], achievements));
      }

      // Check for word master
      if (stats.totalWins >= 50) {
        newlyUnlocked.addAll(await _checkAndUnlock(['word_master'], achievements));
      }

      // Check for streak master
      if (currentStreak >= 10) {
        newlyUnlocked.addAll(await _checkAndUnlock(['streak_master'], achievements));
      }

      // Check for vowel hater
      const vowels = {'A', 'E', 'I', 'O', 'U'};
      if (!guessedLetters.any((letter) => vowels.contains(letter))) {
        newlyUnlocked.addAll(await _checkAndUnlock(['vowel_hater'], achievements));
      }
    } else {
      // Check for persistent loser
      if (stats.lossStreak >= 10) {
        newlyUnlocked.addAll(await _checkAndUnlock(['persistent_loser'], achievements));
      }
    }

    // Check for alphabet soup
    if (guessedLetters.length == 26) {
      newlyUnlocked.addAll(await _checkAndUnlock(['alphabet_soup'], achievements));
    }

    // Check for daily dedicated
    if (dailyGamesPlayed >= 15) {
      newlyUnlocked.addAll(await _checkAndUnlock(['daily_dedicated'], achievements));
    }

    // Check for night owl
    final hour = DateTime.now().hour;
    if (hour >= 2 && hour <= 4) {
      newlyUnlocked.addAll(await _checkAndUnlock(['night_owl'], achievements));
    }

    // Check for leaderboard legend (if player ID provided)
    if (playerId != null) {
      // This would need to be checked against leaderboard provider
      // For now, we'll skip this check
    }

    // Update state
    state = state.copyWith(
      achievements: achievements,
      gameStats: stats,
      recentlyUnlocked: newlyUnlocked,
    );

    // Save progress
    await _saveAchievements();

    // Update progression achievements
    _updateProgressionAchievements();

    return newlyUnlocked;
  }

  Future<List<Achievement>> _checkAndUnlock(List<String> achievementIds, Map<String, Achievement> achievements) async {
    final unlocked = <Achievement>[];
    
    for (final id in achievementIds) {
      final achievement = achievements[id];
      if (achievement != null && !achievement.isUnlocked) {
        achievements[id] = achievement.copyWith(unlockedAt: DateTime.now());
        unlocked.add(achievements[id]!);
      }
    }
    
    return unlocked;
  }

  void clearRecentlyUnlocked() {
    state = state.copyWith(recentlyUnlocked: []);
  }

  void trackLetterGuess(String letter) {
    final letters = Set<String>.from(state.gameStats.lettersGuessedInCurrentGame)..add(letter);
    state = state.copyWith(
      gameStats: state.gameStats.copyWith(
        lettersGuessedInCurrentGame: letters,
        hasGuessedAllLetters: letters.length == 26,
      ),
    );
  }

  void resetCurrentGameTracking() {
    state = state.copyWith(
      gameStats: state.gameStats.copyWith(
        lettersGuessedInCurrentGame: {},
        hasGuessedAllLetters: false,
        hasWonWithoutVowels: false,
      ),
    );
  }
}

final achievementProvider = StateNotifierProvider<AchievementNotifier, AchievementState>(
  (ref) => AchievementNotifier(),
);