import 'package:flutter/material.dart';

enum AchievementCategory {
  skill,
  humor,
  progression,
  special,
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String sarcasticUnlockMessage;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final IconData icon;
  final List<Color> gradientColors;
  final int requiredValue;
  final String badgeShape; // 'circle', 'hexagon', 'diamond', 'star'
  final bool isSecret;
  final DateTime? unlockedAt;
  final double progress;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.sarcasticUnlockMessage,
    required this.category,
    required this.rarity,
    required this.icon,
    required this.gradientColors,
    required this.requiredValue,
    this.badgeShape = 'circle',
    this.isSecret = false,
    this.unlockedAt,
    this.progress = 0.0,
  });

  bool get isUnlocked => unlockedAt != null;

  Achievement copyWith({
    DateTime? unlockedAt,
    double? progress,
  }) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      sarcasticUnlockMessage: sarcasticUnlockMessage,
      category: category,
      rarity: rarity,
      icon: icon,
      gradientColors: gradientColors,
      requiredValue: requiredValue,
      badgeShape: badgeShape,
      isSecret: isSecret,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'progress': progress,
  };

  static Achievement fromPredefined(Achievement achievement, Map<String, dynamic> json) {
    return achievement.copyWith(
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      progress: json['progress'] ?? 0.0,
    );
  }
}

// Predefined achievements
class Achievements {
  // Skill Achievements
  static final flawlessVictory = Achievement(
    id: 'flawless_victory',
    name: 'Flawless Victory',
    description: 'Win without a single wrong guess',
    sarcasticUnlockMessage: 'Perfect game? Must be beginner\'s luck. Don\'t let it go to your head.',
    category: AchievementCategory.skill,
    rarity: AchievementRarity.rare,
    icon: Icons.stars,
    gradientColors: [Colors.amber, Colors.orange],
    requiredValue: 1,
    badgeShape: 'star',
  );

  static final speedDemon = Achievement(
    id: 'speed_demon',
    name: 'Speed Demon',
    description: 'Win in under 30 seconds',
    sarcasticUnlockMessage: 'Slow down there, Flash. Some of us like to savor our victories.',
    category: AchievementCategory.skill,
    rarity: AchievementRarity.epic,
    icon: Icons.bolt,
    gradientColors: [Colors.blue, Colors.cyan],
    requiredValue: 1,
    badgeShape: 'diamond',
  );

  static final lastSecondSave = Achievement(
    id: 'last_second_save',
    name: 'Cutting It Close',
    description: 'Win with only 1 guess remaining',
    sarcasticUnlockMessage: 'Living dangerously, I see. Your heart surgeon must love you.',
    category: AchievementCategory.skill,
    rarity: AchievementRarity.common,
    icon: Icons.favorite,
    gradientColors: [Colors.red, Colors.pink],
    requiredValue: 1,
    badgeShape: 'circle',
  );

  static final wordMaster = Achievement(
    id: 'word_master',
    name: 'Word Master',
    description: 'Win 50 games',
    sarcasticUnlockMessage: 'Congratulations on having no social life. Your dedication is... concerning.',
    category: AchievementCategory.progression,
    rarity: AchievementRarity.epic,
    icon: Icons.military_tech,
    gradientColors: [Colors.purple, Colors.deepPurple],
    requiredValue: 50,
    badgeShape: 'hexagon',
  );

  // Humor Achievements
  static final alphabetSoup = Achievement(
    id: 'alphabet_soup',
    name: 'Alphabet Soup',
    description: 'Guess every letter in the alphabet in one game',
    sarcasticUnlockMessage: 'Someone didn\'t pay attention in kindergarten. A is for Awful strategy.',
    category: AchievementCategory.humor,
    rarity: AchievementRarity.rare,
    icon: Icons.abc,
    gradientColors: [Colors.green, Colors.teal],
    requiredValue: 1,
    badgeShape: 'circle',
  );

  static final persistentLoser = Achievement(
    id: 'persistent_loser',
    name: 'Persistent Loser',
    description: 'Lose 10 games in a row',
    sarcasticUnlockMessage: 'Your consistency is impressive. Consistently terrible, but impressive.',
    category: AchievementCategory.humor,
    rarity: AchievementRarity.common,
    icon: Icons.sentiment_very_dissatisfied,
    gradientColors: [Colors.grey, Colors.blueGrey],
    requiredValue: 10,
    badgeShape: 'circle',
  );

  static final vowelHater = Achievement(
    id: 'vowel_hater',
    name: 'Vowel Hater',
    description: 'Win without guessing any vowels',
    sarcasticUnlockMessage: 'Who needs A, E, I, O, U when you have pure luck and stubbornness?',
    category: AchievementCategory.humor,
    rarity: AchievementRarity.legendary,
    icon: Icons.not_interested,
    gradientColors: [Colors.indigo, Colors.deepPurple],
    requiredValue: 1,
    badgeShape: 'star',
    isSecret: true,
  );

  // Progression Achievements
  static final firstWin = Achievement(
    id: 'first_win',
    name: 'Baby Steps',
    description: 'Win your first game',
    sarcasticUnlockMessage: 'Your first win! Frame it, because at this rate, it might be your last.',
    category: AchievementCategory.progression,
    rarity: AchievementRarity.common,
    icon: Icons.child_care,
    gradientColors: [Colors.lightGreen, Colors.green],
    requiredValue: 1,
    badgeShape: 'circle',
  );

  static final streakMaster = Achievement(
    id: 'streak_master',
    name: 'On Fire',
    description: 'Achieve a 10-game winning streak',
    sarcasticUnlockMessage: 'Ten in a row? Someone\'s been practicing. Get a hobby... oh wait.',
    category: AchievementCategory.progression,
    rarity: AchievementRarity.epic,
    icon: Icons.local_fire_department,
    gradientColors: [Colors.orange, Colors.red],
    requiredValue: 10,
    badgeShape: 'hexagon',
  );

  static final dailyDedicated = Achievement(
    id: 'daily_dedicated',
    name: 'Daily Dedicated',
    description: 'Play maximum games (15) in a single day',
    sarcasticUnlockMessage: 'You actually hit the daily limit. I\'m not sure if I should be impressed or concerned.',
    category: AchievementCategory.progression,
    rarity: AchievementRarity.rare,
    icon: Icons.calendar_today,
    gradientColors: [Colors.blue, Colors.indigo],
    requiredValue: 15,
    badgeShape: 'diamond',
  );

  // Special Achievements
  static final extremeChampion = Achievement(
    id: 'extreme_champion',
    name: 'Extreme Champion',
    description: 'Win on Extreme difficulty',
    sarcasticUnlockMessage: 'You beat Extreme mode. Your prize? Bragging rights and this shiny badge.',
    category: AchievementCategory.special,
    rarity: AchievementRarity.legendary,
    icon: Icons.emoji_events,
    gradientColors: [Colors.deepOrange, Colors.red],
    requiredValue: 1,
    badgeShape: 'star',
  );

  static final nightOwl = Achievement(
    id: 'night_owl',
    name: 'Night Owl',
    description: 'Play at 3 AM',
    sarcasticUnlockMessage: 'Playing at 3 AM? Insomnia or poor life choices? Both? Definitely both.',
    category: AchievementCategory.special,
    rarity: AchievementRarity.rare,
    icon: Icons.nightlight,
    gradientColors: [Colors.deepPurple, Colors.black],
    requiredValue: 1,
    badgeShape: 'diamond',
    isSecret: true,
  );

  static final comeback = Achievement(
    id: 'comeback',
    name: 'Comeback Kid',
    description: 'Win after having 5 wrong guesses',
    sarcasticUnlockMessage: 'From the brink of defeat to victory. Hollywood called, they want their script back.',
    category: AchievementCategory.special,
    rarity: AchievementRarity.rare,
    icon: Icons.trending_up,
    gradientColors: [Colors.teal, Colors.green],
    requiredValue: 1,
    badgeShape: 'hexagon',
  );

  static final leaderboardLegend = Achievement(
    id: 'leaderboard_legend',
    name: 'Leaderboard Legend',
    description: 'Reach #1 on any leaderboard',
    sarcasticUnlockMessage: 'King of the hill! Enjoy it while it lasts. Someone\'s coming for your crown.',
    category: AchievementCategory.special,
    rarity: AchievementRarity.legendary,
    icon: Icons.looks_one,
    gradientColors: [Colors.amber, Colors.yellow],
    requiredValue: 1,
    badgeShape: 'star',
  );

  // Get all achievements
  static List<Achievement> get allAchievements => [
    flawlessVictory,
    speedDemon,
    lastSecondSave,
    wordMaster,
    alphabetSoup,
    persistentLoser,
    vowelHater,
    firstWin,
    streakMaster,
    dailyDedicated,
    extremeChampion,
    nightOwl,
    comeback,
    leaderboardLegend,
  ];

  static List<Achievement> getByCategory(AchievementCategory category) {
    return allAchievements.where((a) => a.category == category).toList();
  }

  static Achievement? getById(String id) {
    try {
      return allAchievements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}