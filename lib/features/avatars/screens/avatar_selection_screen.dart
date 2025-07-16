import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/models/avatar_model.dart';
import '../../../core/theme/app_theme.dart';

class AvatarSelectionScreen extends StatefulWidget {
  const AvatarSelectionScreen({super.key});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  String selectedAvatarId = 'stick_figure';
  int playerWins = 55; // TODO: Get from user data

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animations = List.generate(
      AvatarData.avatars.length,
      (index) => CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.1,
          0.5 + index * 0.1,
          curve: Curves.elasticOut,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAvatarCard(Avatar avatar, int index) {
    final isUnlocked = playerWins >= avatar.unlocksAtWins;
    final isSelected = selectedAvatarId == avatar.id;

    return ScaleTransition(
      scale: _animations[index],
      child: GestureDetector(
        onTap: isUnlocked
            ? () {
                setState(() {
                  selectedAvatarId = avatar.id;
                });
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(8),
          child: GlassContainer(
            opacity: isUnlocked ? 0.3 : 0.1,
            borderColor: isSelected
                ? AppTheme.primaryGradientStart
                : isUnlocked
                    ? AppTheme.glassBorder
                    : Colors.red.withOpacity(0.3),
            borderWidth: isSelected ? 3 : 1,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isUnlocked
                                ? avatar.gradientColors
                                : [Colors.grey, Colors.grey.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          avatar.icon,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        avatar.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        avatar.description,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (!isUnlocked) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${avatar.unlocksAtWins} wins',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isUnlocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.lock,
                          color: Colors.white54,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGradientStart,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Choose Your Victim'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, selectedAvatarId);
              },
              child: const Text(
                'DONE',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              GlassContainer(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Wins: $playerWins',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: AvatarData.avatars.length,
                  itemBuilder: (context, index) {
                    return _buildAvatarCard(AvatarData.avatars[index], index);
                  },
                ),
              ),
              GlassContainer(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Win more games to unlock new avatars',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}