import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/sarcastic_messages.dart';
import '../../../core/constants/word_list.dart';
import '../../../shared/models/game_enums.dart';
import '../../../shared/providers/timer_provider.dart';
import '../../../shared/providers/scoring_provider.dart';
import '../../../shared/providers/leaderboard_provider.dart';
import '../../../shared/providers/achievement_provider.dart';
import '../widgets/hangman_drawing.dart';
import '../widgets/timer_widget.dart';
import '../widgets/score_display.dart';
import '../../leaderboard/widgets/leaderboard_sheet.dart';
import '../../achievements/widgets/achievement_unlock_overlay.dart';
import '../../achievements/screens/achievement_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with TickerProviderStateMixin {
  final Set<String> guessedLetters = {};
  late String currentWord;
  int wrongGuesses = 0;
  int maxWrongGuesses = 6;
  String currentMessage = "Let's see how badly you'll do...";
  GameDifficulty currentDifficulty = GameDifficulty.medium;
  int currentScore = 0;
  int correctLettersCount = 0;
  DateTime? gameStartTime;
  
  late AnimationController _messageController;
  late AnimationController _letterRevealController;
  late Animation<double> _messageAnimation;
  late Animation<double> _letterRevealAnimation;
  
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Initialize with a default word
    currentWord = 'FLUTTER';
    
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _letterRevealController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _messageAnimation = CurvedAnimation(
      parent: _messageController,
      curve: Curves.elasticOut,
    );
    _letterRevealAnimation = CurvedAnimation(
      parent: _letterRevealController,
      curve: Curves.bounceOut,
    );
    
    _messageController.forward();
    
    // Get difficulty from route arguments if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is GameDifficulty) {
        setState(() {
          currentDifficulty = args;
          // Adjust max wrong guesses based on difficulty
          switch (currentDifficulty) {
            case GameDifficulty.easy:
              maxWrongGuesses = 8;
              break;
            case GameDifficulty.medium:
              maxWrongGuesses = 6;
              break;
            case GameDifficulty.hard:
            case GameDifficulty.extreme:
              maxWrongGuesses = 4;
              break;
          }
        });
        // Start timer with current difficulty
        ref.read(timerProvider.notifier).startTimer(currentDifficulty);
        gameStartTime = DateTime.now();
        // Reset achievement tracking for new game
        ref.read(achievementProvider.notifier).resetCurrentGameTracking();
        // Get random word for difficulty
        currentWord = WordList.getRandomWord(currentDifficulty);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _letterRevealController.dispose();
    super.dispose();
  }

  String get displayWord {
    return currentWord
        .split('')
        .map((letter) => guessedLetters.contains(letter) ? letter : '_')
        .join(' ');
  }

  bool get isGameWon {
    return currentWord.split('').every((letter) => guessedLetters.contains(letter));
  }

  bool get isGameLost {
    return wrongGuesses >= maxWrongGuesses;
  }
  
  int get remainingGuesses {
    return maxWrongGuesses - wrongGuesses;
  }

  void _updateMessage(String message) {
    setState(() {
      currentMessage = message;
    });
    _messageController.reset();
    _messageController.forward();
    HapticFeedback.lightImpact();
  }

  void makeGuess(String letter) {
    if (guessedLetters.contains(letter) || isGameWon || isGameLost) {
      return;
    }

    // Track letter for achievements
    ref.read(achievementProvider.notifier).trackLetterGuess(letter);

    setState(() {
      guessedLetters.add(letter);
      if (currentWord.contains(letter)) {
        // Count how many times this letter appears in the word
        final letterCount = currentWord.split('').where((l) => l == letter).length;
        correctLettersCount += letterCount;
        
        // Calculate score for this guess
        final scoring = ref.read(scoringProvider.notifier);
        final timer = ref.read(timerProvider);
        final partialScore = scoring.calculateScore(
          difficulty: currentDifficulty,
          correctLetters: correctLettersCount,
          wrongGuesses: wrongGuesses,
          timeRemaining: timer.remainingSeconds,
          isComplete: false,
          currentStreak: ref.read(scoringProvider).currentStreak,
        );
        setState(() {
          currentScore = partialScore;
        });
        
        _updateMessage(SarcasticMessages.correctGuesses[
          _random.nextInt(SarcasticMessages.correctGuesses.length)
        ]);
        _letterRevealController.reset();
        _letterRevealController.forward();
        HapticFeedback.mediumImpact();
      } else {
        wrongGuesses++;
        _updateMessage(SarcasticMessages.wrongGuesses[
          _random.nextInt(SarcasticMessages.wrongGuesses.length)
        ]);
        HapticFeedback.heavyImpact();
      }
    });

    if (isGameWon) {
      ref.read(timerProvider.notifier).stopTimer();
      
      // Calculate final score
      final timer = ref.read(timerProvider);
      final scoring = ref.read(scoringProvider.notifier);
      final finalScore = scoring.calculateScore(
        difficulty: currentDifficulty,
        correctLetters: correctLettersCount,
        wrongGuesses: wrongGuesses,
        timeRemaining: timer.remainingSeconds,
        isComplete: true,
        currentStreak: ref.read(scoringProvider).currentStreak,
      );
      setState(() {
        currentScore = finalScore;
      });
      
      // Submit score
      _submitScore(true, wrongGuesses == 0);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        _showGameEndDialog(
          'Victory!',
          SarcasticMessages.gameWon[
            _random.nextInt(SarcasticMessages.gameWon.length)
          ],
        );
      });
    } else if (isGameLost) {
      ref.read(timerProvider.notifier).stopTimer();
      
      // Submit score even for loss
      _submitScore(false, false);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        _showGameEndDialog(
          'Game Over!',
          '${SarcasticMessages.gameLost[_random.nextInt(SarcasticMessages.gameLost.length)]}\n\nThe word was: $currentWord',
        );
      });
    } else {
      // Reset timer for next guess
      ref.read(timerProvider.notifier).startTimer(currentDifficulty);
    }
  }
  
  void _submitScore(bool isWin, bool isPerfect) async {
    if (gameStartTime == null) return;
    
    final timeToComplete = DateTime.now().difference(gameStartTime!).inSeconds;
    final scoring = ref.read(scoringProvider.notifier);
    
    try {
      await scoring.submitScore(
        score: currentScore,
        difficulty: currentDifficulty,
        playerName: 'Player', // TODO: Get from user profile
        timeToComplete: timeToComplete,
        isPerfectGame: isPerfect,
        isWin: isWin,
        wordGuessed: currentWord,
      );
      
      // Add to leaderboard
      final result = GameResult(
        score: currentScore,
        difficulty: currentDifficulty,
        playerName: 'Player',
        timestamp: DateTime.now(),
        timeToComplete: timeToComplete,
        isPerfectGame: isPerfect,
        wordGuessed: currentWord,
      );
      await ref.read(leaderboardProvider.notifier).addEntry(result);
      
      // Check for achievements
      final prefs = await SharedPreferences.getInstance();
      final playerId = prefs.getString('player_id') ?? '';
      
      final unlockedAchievements = await ref.read(achievementProvider.notifier).checkAndUnlockAchievements(
        isWin: isWin,
        difficulty: currentDifficulty,
        wrongGuesses: wrongGuesses,
        maxWrongGuesses: maxWrongGuesses,
        timeToComplete: timeToComplete,
        guessedLetters: guessedLetters,
        word: currentWord,
        currentStreak: ref.read(scoringProvider).currentStreak,
        dailyGamesPlayed: ref.read(scoringProvider).dailyGamesPlayed,
        playerId: playerId.isNotEmpty ? playerId : null,
      );
      
      // Show achievement unlocks after a delay
      if (unlockedAchievements.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            AchievementUnlockOverlay.show(
              context: context,
              achievements: unlockedAchievements,
            );
          }
        });
      }
    } catch (e) {
      // Handle daily limit reached
      if (e.toString().contains('Daily game limit')) {
        _updateMessage('Daily limit reached! Come back tomorrow.');
      }
    }
  }

  void _showGameEndDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(
          parent: _messageController,
          curve: Curves.elasticOut,
        ),
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          content: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isGameWon 
                      ? Colors.greenAccent 
                      : Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                if (isGameWon) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Score: $currentScore',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _resetGame();
                      },
                      child: const Text('Play Again'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Stop timer before leaving
                        Future.microtask(() {
                          ref.read(timerProvider.notifier).stopTimer();
                        });
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetGame() {
    setState(() {
      guessedLetters.clear();
      wrongGuesses = 0;
      currentScore = 0;
      correctLettersCount = 0;
      currentWord = WordList.getRandomWord(currentDifficulty);
      currentMessage = "Another round? Glutton for punishment, I see...";
      gameStartTime = DateTime.now();
    });
    _messageController.forward();
    ref.read(timerProvider.notifier).startTimer(currentDifficulty);
    // Reset achievement tracking for new game
    ref.read(achievementProvider.notifier).resetCurrentGameTracking();
  }
  
  void _changeDifficulty() {
    // Delay timer stop to avoid lifecycle issues
    Future.microtask(() {
      ref.read(timerProvider.notifier).stopTimer();
    });
    Navigator.pushReplacementNamed(context, '/difficulty');
  }

  Widget _buildLetterButton(String letter) {
    final isGuessed = guessedLetters.contains(letter);
    final isCorrect = isGuessed && currentWord.contains(letter);
    final isWrong = isGuessed && !currentWord.contains(letter);

    return AnimatedScale(
      scale: isGuessed ? 0.85 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(10),
        opacity: isGuessed ? 0.1 : 0.3,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isGuessed ? null : () => makeGuess(letter),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: isCorrect
                    ? LinearGradient(
                        colors: [
                          Colors.greenAccent.withOpacity(0.3),
                          Colors.green.withOpacity(0.3),
                        ],
                      )
                    : isWrong
                        ? LinearGradient(
                            colors: [
                              Colors.redAccent.withOpacity(0.3),
                              Colors.red.withOpacity(0.3),
                            ],
                          )
                        : null,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isGuessed
                        ? (isCorrect ? Colors.greenAccent : Colors.redAccent)
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(timerProvider);
    
    // Handle timer expiration
    ref.listen(timerProvider, (previous, current) {
      if (current.timerState == TimerState.expired && 
          previous?.timerState == TimerState.running) {
        // Auto-select a random unguessed letter
        final allLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
        final unguessedLetters = allLetters
            .where((letter) => !guessedLetters.contains(letter))
            .toList();
        if (unguessedLetters.isNotEmpty && !isGameWon && !isGameLost) {
          final randomLetter = unguessedLetters[_random.nextInt(unguessedLetters.length)];
          _updateMessage('Time\'s up! I picked "$randomLetter" for you. How generous of me.');
          makeGuess(randomLetter);
        }
      }
    });
    
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWeb = constraints.maxWidth > 800;
              final isTablet = constraints.maxWidth > 600;
              
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 24.0 : 16.0,
                  vertical: isWeb ? 12.0 : 8.0,
                ),
                child: Column(
                  children: [
                    // Top info bar
                    _buildInfoBar(),
                    SizedBox(height: isWeb ? 12 : 8),
                    // Score display
                    if (currentScore > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Center(
                          child: ScoreDisplay(
                            currentScore: currentScore,
                            difficulty: currentDifficulty,
                          ),
                        ),
                      ),
                    // Sarcastic message
                    ScaleTransition(
                      scale: _messageAnimation,
                      child: GlassContainer(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: isWeb ? 10 : 8,
                        ),
                        child: Text(
                          currentMessage,
                          style: TextStyle(
                            fontSize: isWeb ? 16 : 14,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: isWeb ? 12 : 8),
                    // Hangman drawing area
                    Expanded(
                      flex: isWeb ? 5 : 4,
                      child: GlassContainer(
                        child: Center(
                          child: HangmanDrawing(
                            wrongGuesses: wrongGuesses,
                            maxWrongGuesses: maxWrongGuesses,
                            width: isWeb ? 180 : 160,
                            height: isWeb ? 220 : 200,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isWeb ? 16 : 12),
                    // Word display
                    ScaleTransition(
                      scale: _letterRevealAnimation,
                      child: Text(
                        displayWord,
                        style: TextStyle(
                          fontSize: isWeb ? 36 : 32,
                          letterSpacing: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: isWeb ? 20 : 16),
                    // Letter buttons
                    Expanded(
                      flex: isWeb ? 6 : 5,
                      child: Center(
                        child: _buildLetterKeyboard(
                          isWeb: isWeb,
                          isTablet: isTablet,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Top right buttons
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 16,
          child: Row(
            children: [
              _buildAchievementButton(),
              const SizedBox(width: 8),
              _buildLeaderboardButton(),
            ],
          ),
        ),
        // Game actions row
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          child: Row(
            children: [
              _buildActionButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back',
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.refresh,
                onPressed: () {
                  Future.microtask(() {
                    ref.read(timerProvider.notifier).stopTimer();
                  });
                  _resetGame();
                },
                tooltip: 'Retry',
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.tune,
                onPressed: () => _changeDifficulty(),
                tooltip: 'Difficulty',
              ),
            ],
          ),
        ),
        // Daily limit warning
        if (ref.watch(scoringProvider).dailyGamesPlayed >= 12)
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.5),
                ),
              ),
              child: Text(
                '${ref.watch(scoringProvider).gamesLeftToday} games left today',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(8),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        tooltip: tooltip,
        iconSize: 20,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
  
  Widget _buildAchievementButton() {
    final achievementState = ref.watch(achievementProvider);
    final hasNewUnlocks = achievementState.recentlyUnlocked.isNotEmpty;
    
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(8),
      gradient: hasNewUnlocks ? LinearGradient(
        colors: [
          Colors.amber.withOpacity(0.8),
          Colors.orange.withOpacity(0.8),
        ],
      ) : null,
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_events, color: Colors.white),
            onPressed: () {
              ref.read(achievementProvider.notifier).clearRecentlyUnlocked();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AchievementScreen(),
                ),
              );
            },
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          if (hasNewUnlocks)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildLeaderboardButton() {
    return GlassContainer(
      borderRadius: BorderRadius.circular(25),
      gradient: LinearGradient(
        colors: [
          AppTheme.primaryGradientStart.withOpacity(0.8),
          AppTheme.primaryGradientEnd.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLeaderboard(),
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.leaderboard,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Leaderboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showLeaderboard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LeaderboardSheet(),
    );
  }
  
  Color _getDifficultyColor(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return Colors.greenAccent;
      case GameDifficulty.medium:
        return Colors.orangeAccent;
      case GameDifficulty.hard:
        return Colors.redAccent;
      case GameDifficulty.extreme:
        return Colors.purpleAccent;
    }
  }
  
  Widget _buildInfoBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Difficulty and guesses info
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.speed,
                      size: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentDifficulty.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getDifficultyColor(currentDifficulty),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: Colors.white.withOpacity(0.3),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: remainingGuesses <= 2
                          ? Colors.redAccent
                          : Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lives: $remainingGuesses',
                      style: TextStyle(
                        fontSize: 14,
                        color: remainingGuesses <= 2
                            ? Colors.redAccent
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Timer
        const HangmanTimer(),
      ],
    );
  }
  
  Widget _buildLetterKeyboard({required bool isWeb, bool isTablet = false}) {
    final allLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isWeb ? 800 : 600,
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isWeb ? 9 : (isTablet ? 8 : 7),
          crossAxisSpacing: isWeb ? 10 : 8,
          mainAxisSpacing: isWeb ? 10 : 8,
          childAspectRatio: 1,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: allLetters.length,
        itemBuilder: (context, index) {
          return _buildLetterButton(allLetters[index]);
        },
      ),
    );
  }
}