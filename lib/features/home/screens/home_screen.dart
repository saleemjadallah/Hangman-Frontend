import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../core/theme/app_theme.dart';
import '../../achievements/screens/achievement_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _buttonController;
  late Animation<double> _titleAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _titleAnimation = CurvedAnimation(
      parent: _titleController,
      curve: Curves.elasticOut,
    );
    _buttonAnimation = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutBack,
    );

    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Widget _buildMenuButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required int index,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.5, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _buttonController,
        curve: Interval(
          0.1 * index,
          0.4 + 0.1 * index,
          curve: Curves.easeOutBack,
        ),
      )),
      child: ScaleTransition(
        scale: _buttonAnimation,
        child: GlassContainer(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 28),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
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
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                ScaleTransition(
                  scale: _titleAnimation,
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 30,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              AppTheme.primaryGradientStart,
                              AppTheme.primaryGradientEnd,
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'SNARKY',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Text(
                          'HANGMAN',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                _buildMenuButton(
                  label: 'Single Player',
                  icon: Icons.person,
                  onPressed: () {
                    Navigator.pushNamed(context, '/difficulty');
                  },
                  index: 0,
                ),
                _buildMenuButton(
                  label: 'Multiplayer',
                  icon: Icons.people,
                  onPressed: () {
                    // TODO: Navigate to multiplayer
                  },
                  index: 1,
                ),
                _buildMenuButton(
                  label: 'Avatars',
                  icon: Icons.face,
                  onPressed: () {
                    Navigator.pushNamed(context, '/avatars');
                  },
                  index: 2,
                ),
                _buildMenuButton(
                  label: 'Achievements',
                  icon: Icons.emoji_events,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AchievementScreen(),
                      ),
                    );
                  },
                  index: 3,
                ),
                _buildMenuButton(
                  label: 'Settings',
                  icon: Icons.settings,
                  onPressed: () {
                    // TODO: Navigate to settings
                  },
                  index: 4,
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}