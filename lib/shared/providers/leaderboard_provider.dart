import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_enums.dart';
import 'scoring_provider.dart';

class LeaderboardEntry {
  final String playerId;
  final String playerName;
  final int score;
  final GameDifficulty difficulty;
  final DateTime timestamp;
  final bool isPerfectGame;
  final int timeToComplete;
  final String wordGuessed;

  const LeaderboardEntry({
    required this.playerId,
    required this.playerName,
    required this.score,
    required this.difficulty,
    required this.timestamp,
    required this.isPerfectGame,
    required this.timeToComplete,
    required this.wordGuessed,
  });

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'playerName': playerName,
        'score': score,
        'difficulty': difficulty.name,
        'timestamp': timestamp.toIso8601String(),
        'isPerfectGame': isPerfectGame,
        'timeToComplete': timeToComplete,
        'wordGuessed': wordGuessed,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        playerId: json['playerId'] ?? 'local',
        playerName: json['playerName'],
        score: json['score'],
        difficulty: GameDifficulty.values.firstWhere(
          (e) => e.name == json['difficulty'],
        ),
        timestamp: DateTime.parse(json['timestamp']),
        isPerfectGame: json['isPerfectGame'],
        timeToComplete: json['timeToComplete'],
        wordGuessed: json['wordGuessed'] ?? '',
      );

  factory LeaderboardEntry.fromGameResult(GameResult result, String playerId) => LeaderboardEntry(
        playerId: playerId,
        playerName: result.playerName,
        score: result.score,
        difficulty: result.difficulty,
        timestamp: result.timestamp,
        isPerfectGame: result.isPerfectGame,
        timeToComplete: result.timeToComplete,
        wordGuessed: result.wordGuessed,
      );
}

class LeaderboardState {
  final bool isLoading;
  final List<LeaderboardEntry> globalLeaderboard;
  final List<LeaderboardEntry> easyLeaderboard;
  final List<LeaderboardEntry> mediumLeaderboard;
  final List<LeaderboardEntry> hardLeaderboard;
  final List<LeaderboardEntry> extremeLeaderboard;
  final DateTime? lastUpdated;
  final String? error;

  const LeaderboardState({
    required this.isLoading,
    required this.globalLeaderboard,
    required this.easyLeaderboard,
    required this.mediumLeaderboard,
    required this.hardLeaderboard,
    required this.extremeLeaderboard,
    this.lastUpdated,
    this.error,
  });

  factory LeaderboardState.initial() => const LeaderboardState(
        isLoading: false,
        globalLeaderboard: [],
        easyLeaderboard: [],
        mediumLeaderboard: [],
        hardLeaderboard: [],
        extremeLeaderboard: [],
      );

  LeaderboardState copyWith({
    bool? isLoading,
    List<LeaderboardEntry>? globalLeaderboard,
    List<LeaderboardEntry>? easyLeaderboard,
    List<LeaderboardEntry>? mediumLeaderboard,
    List<LeaderboardEntry>? hardLeaderboard,
    List<LeaderboardEntry>? extremeLeaderboard,
    DateTime? lastUpdated,
    String? error,
  }) {
    return LeaderboardState(
      isLoading: isLoading ?? this.isLoading,
      globalLeaderboard: globalLeaderboard ?? this.globalLeaderboard,
      easyLeaderboard: easyLeaderboard ?? this.easyLeaderboard,
      mediumLeaderboard: mediumLeaderboard ?? this.mediumLeaderboard,
      hardLeaderboard: hardLeaderboard ?? this.hardLeaderboard,
      extremeLeaderboard: extremeLeaderboard ?? this.extremeLeaderboard,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      error: error ?? this.error,
    );
  }
}

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  LeaderboardNotifier() : super(LeaderboardState.initial()) {
    loadLeaderboards();
  }

  Future<void> loadLeaderboards() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final leaderboardJson = prefs.getStringList('leaderboard_entries') ?? [];

      // Parse all entries
      final allEntries = <LeaderboardEntry>[];
      for (final jsonStr in leaderboardJson) {
        try {
          final json = jsonDecode(jsonStr);
          allEntries.add(LeaderboardEntry.fromJson(json));
        } catch (e) {
          // Skip invalid entries
        }
      }

      // Sort by score (descending)
      allEntries.sort((a, b) => b.score.compareTo(a.score));

      // Create difficulty-specific leaderboards
      final easyEntries = allEntries
          .where((e) => e.difficulty == GameDifficulty.easy)
          .take(50)
          .toList();
      final mediumEntries = allEntries
          .where((e) => e.difficulty == GameDifficulty.medium)
          .take(50)
          .toList();
      final hardEntries = allEntries
          .where((e) => e.difficulty == GameDifficulty.hard)
          .take(50)
          .toList();
      final extremeEntries = allEntries
          .where((e) => e.difficulty == GameDifficulty.extreme)
          .take(50)
          .toList();

      state = state.copyWith(
        isLoading: false,
        globalLeaderboard: allEntries.take(100).toList(),
        easyLeaderboard: easyEntries,
        mediumLeaderboard: mediumEntries,
        hardLeaderboard: hardEntries,
        extremeLeaderboard: extremeEntries,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addEntry(GameResult result) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get player ID
    String playerId = prefs.getString('player_id') ?? '';
    if (playerId.isEmpty) {
      playerId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('player_id', playerId);
    }

    final entry = LeaderboardEntry.fromGameResult(result, playerId);

    // Get existing entries
    final leaderboardJson = prefs.getStringList('leaderboard_entries') ?? [];
    
    // Add new entry
    leaderboardJson.add(jsonEncode(entry.toJson()));

    // Save back to storage
    await prefs.setStringList('leaderboard_entries', leaderboardJson);

    // Reload leaderboards
    await loadLeaderboards();
  }

  int getPlayerRank(String playerId, {GameDifficulty? difficulty}) {
    final leaderboard = difficulty == null
        ? state.globalLeaderboard
        : _getLeaderboardByDifficulty(difficulty);

    for (int i = 0; i < leaderboard.length; i++) {
      if (leaderboard[i].playerId == playerId) {
        return i + 1;
      }
    }
    return -1;
  }

  List<LeaderboardEntry> _getLeaderboardByDifficulty(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return state.easyLeaderboard;
      case GameDifficulty.medium:
        return state.mediumLeaderboard;
      case GameDifficulty.hard:
        return state.hardLeaderboard;
      case GameDifficulty.extreme:
        return state.extremeLeaderboard;
    }
  }
}

final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, LeaderboardState>(
  (ref) => LeaderboardNotifier(),
);