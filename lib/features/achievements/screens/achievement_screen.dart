import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/models/achievement.dart';
import '../../../shared/providers/achievement_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/achievement_badge.dart';

class AchievementScreen extends ConsumerStatefulWidget {
  const AchievementScreen({super.key});

  @override
  ConsumerState<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends ConsumerState<AchievementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Achievement? _selectedAchievement;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievementState = ref.watch(achievementProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(achievementState),
              const SizedBox(height: 20),
              // Progress Stats
              _buildProgressStats(achievementState),
              const SizedBox(height: 20),
              // Tab Bar
              _buildTabBar(),
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAchievementGrid(achievementState.achievements.values.toList()),
                    _buildAchievementGrid(achievementState.getByCategory(AchievementCategory.skill)),
                    _buildAchievementGrid(achievementState.getByCategory(AchievementCategory.humor)),
                    _buildAchievementGrid(achievementState.getByCategory(AchievementCategory.progression)),
                    _buildAchievementGrid(achievementState.getByCategory(AchievementCategory.special)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AchievementState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GlassContainer(
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.all(8),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Collect badges and show off your skills',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStats(AchievementState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.emoji_events,
                  value: '${state.totalUnlocked}',
                  label: 'Unlocked',
                  color: Colors.amber,
                ),
                _buildStatItem(
                  icon: Icons.trending_up,
                  value: '${state.completionPercentage.toStringAsFixed(0)}%',
                  label: 'Complete',
                  color: Colors.green,
                ),
                _buildStatItem(
                  icon: Icons.stars,
                  value: '${state.gameStats.totalWins}',
                  label: 'Total Wins',
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: state.completionPercentage / 100,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGradientStart,
                          AppTheme.primaryGradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGradientEnd.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ).animate().scaleX(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryGradientStart.withOpacity(0.3),
              AppTheme.primaryGradientEnd.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Skill'),
          Tab(text: 'Humor'),
          Tab(text: 'Progress'),
          Tab(text: 'Special'),
        ],
      ),
    );
  }

  Widget _buildAchievementGrid(List<Achievement> achievements) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return Column(
          children: [
            Expanded(
              child: AchievementBadge(
                achievement: achievement,
                size: 80,
                onTap: () => _showAchievementDetails(achievement),
              ).animate().scale(
                delay: Duration(milliseconds: index * 50),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.isSecret && !achievement.isUnlocked
                  ? '???'
                  : achievement.name,
              style: TextStyle(
                fontSize: 11,
                color: achievement.isUnlocked
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
                fontWeight: achievement.isUnlocked
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    setState(() {
      _selectedAchievement = achievement;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildAchievementDetailSheet(achievement),
    );
  }

  Widget _buildAchievementDetailSheet(Achievement achievement) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryGradientStart.withOpacity(0.9),
            AppTheme.primaryGradientEnd.withOpacity(0.9),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                // Achievement badge
                AchievementBadge(
                  achievement: achievement,
                  size: 120,
                  showProgress: true,
                ),
                const SizedBox(height: 24),
                // Achievement name
                Text(
                  achievement.isSecret && !achievement.isUnlocked
                      ? 'Secret Achievement'
                      : achievement.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Rarity
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRarityColor(achievement.rarity).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getRarityColor(achievement.rarity).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    achievement.rarity.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getRarityColor(achievement.rarity),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  achievement.isSecret && !achievement.isUnlocked
                      ? 'Complete the hidden objective to unlock this achievement'
                      : achievement.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (achievement.isUnlocked) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          achievement.sarcasticUnlockMessage,
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!achievement.isUnlocked && achievement.progress > 0) ...[
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Text(
                        'Progress: ${(achievement.progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: achievement.progress,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryGradientStart,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}