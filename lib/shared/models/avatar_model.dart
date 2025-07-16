import 'package:flutter/material.dart';

class Avatar {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final int unlocksAtWins;
  final bool isPremium;
  final String deathAnimation;

  const Avatar({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.unlocksAtWins,
    this.isPremium = false,
    required this.deathAnimation,
  });
}

class AvatarData {
  static const List<Avatar> avatars = [
    Avatar(
      id: 'stick_figure',
      name: 'Classic Stick Figure',
      description: 'The timeless victim',
      icon: Icons.accessibility_new,
      gradientColors: [Colors.grey, Colors.blueGrey],
      unlocksAtWins: 0,
      deathAnimation: 'classic',
    ),
    Avatar(
      id: 'robot',
      name: 'Robot',
      description: 'Mechanical misfortune',
      icon: Icons.android,
      gradientColors: [Colors.blue, Colors.cyan],
      unlocksAtWins: 10,
      deathAnimation: 'shutdown',
    ),
    Avatar(
      id: 'zombie',
      name: 'Zombie',
      description: 'Already dead inside',
      icon: Icons.coronavirus,
      gradientColors: [Colors.green, Colors.lightGreen],
      unlocksAtWins: 25,
      deathAnimation: 'decay',
    ),
    Avatar(
      id: 'ninja',
      name: 'Ninja',
      description: 'Silent but still dies',
      icon: Icons.sports_martial_arts,
      gradientColors: [Colors.black, Colors.grey],
      unlocksAtWins: 50,
      deathAnimation: 'vanish',
    ),
    Avatar(
      id: 'alien',
      name: 'Alien',
      description: 'Out of this world failure',
      icon: Icons.pest_control,
      gradientColors: [Colors.purple, Colors.deepPurple],
      unlocksAtWins: 100,
      deathAnimation: 'abduction',
    ),
    Avatar(
      id: 'pirate',
      name: 'Pirate',
      description: 'Walk the plank',
      icon: Icons.sailing,
      gradientColors: [Colors.brown, Colors.orange],
      unlocksAtWins: 75,
      deathAnimation: 'plank',
    ),
    Avatar(
      id: 'wizard',
      name: 'Wizard',
      description: 'Magic won\'t save you',
      icon: Icons.auto_fix_high,
      gradientColors: [Colors.indigo, Colors.deepPurple],
      unlocksAtWins: 150,
      deathAnimation: 'disappear',
    ),
    Avatar(
      id: 'knight',
      name: 'Knight',
      description: 'Armor is useless here',
      icon: Icons.shield,
      gradientColors: [Colors.blueGrey, Colors.grey],
      unlocksAtWins: 200,
      deathAnimation: 'collapse',
    ),
  ];
}