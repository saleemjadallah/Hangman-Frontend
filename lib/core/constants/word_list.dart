import 'dart:math';
import '../../shared/models/game_enums.dart';

class WordList {
  static final Map<GameDifficulty, List<String>> wordsByDifficulty = {
    GameDifficulty.easy: [
      'CAT', 'DOG', 'RUN', 'FUN', 'SUN', 'HAT', 'BAT', 'RED', 'BIG', 'HOT',
      'CUP', 'BED', 'PEN', 'BOX', 'BAG', 'EGG', 'LEG', 'ARM', 'EYE', 'EAR',
      'JAR', 'KEY', 'MAP', 'NET', 'OWL', 'PIG', 'RAT', 'TOY', 'VAN', 'WEB',
      'YES', 'ZOO', 'ANT', 'BEE', 'COW', 'DAY', 'FOX', 'GUM', 'ICE', 'JOB',
    ],
    GameDifficulty.medium: [
      'HAPPY', 'FUNNY', 'QUICK', 'ZEBRA', 'PHONE', 'MUSIC', 'PIZZA', 'BEACH',
      'CLOUD', 'DREAM', 'EARTH', 'FRUIT', 'GRAPE', 'HEART', 'LIGHT', 'MONEY',
      'NIGHT', 'OCEAN', 'PLANT', 'QUEEN', 'RIVER', 'STONE', 'TIGER', 'UNDER',
      'VOICE', 'WATER', 'YOUNG', 'ABOUT', 'BREAD', 'CHAIR', 'DANCE', 'EAGLE',
      'FIELD', 'GHOST', 'HOUSE', 'IMAGE', 'JELLY', 'KNIFE', 'LEMON', 'MOUSE',
    ],
    GameDifficulty.hard: [
      'FLUTTER', 'WIDGET', 'CODING', 'FUTURE', 'GALAXY', 'JUNGLE', 'KNIGHT',
      'LUXURY', 'OXYGEN', 'PUZZLE', 'RHYTHM', 'SPHINX', 'VORTEX', 'WIZARD',
      'YELLOW', 'ZODIAC', 'BEACON', 'CRYSTAL', 'DRAGON', 'ENIGMA', 'FALCON',
      'GLITCH', 'HYBRID', 'ISLAND', 'JACKAL', 'KERNEL', 'LEGEND', 'MARVEL',
      'NEBULA', 'ORACLE', 'PALACE', 'QUARTZ', 'RIDDLE', 'SHADOW', 'TEMPLE',
    ],
    GameDifficulty.extreme: [
      'ALGORITHM', 'BUTTERFLY', 'CHOCOLATE', 'DEMOCRACY', 'EVOLUTION',
      'FREQUENCY', 'GYMNASIUM', 'HIBERNATE', 'IGNORANCE', 'JELLYFISH',
      'KNOWLEDGE', 'LABYRINTH', 'MACHINERY', 'NIGHTMARE', 'ORCHESTRA',
      'PARACHUTE', 'QUARANTINE', 'RASPBERRY', 'SCULPTURE', 'TELEPHONE',
      'UMBRELLA', 'VALENTINE', 'WATERFALL', 'XYLOPHONE', 'YESTERDAY',
      'ADVENTURE', 'BEAUTIFUL', 'CHALLENGE', 'DANGEROUS', 'EDUCATION',
      'FRAMEWORK', 'GENERATOR', 'HAMBURGER', 'IMPORTANT', 'JACKKNIFE',
    ],
  };

  static String getRandomWord(GameDifficulty difficulty) {
    final words = wordsByDifficulty[difficulty] ?? wordsByDifficulty[GameDifficulty.medium]!;
    final random = Random();
    return words[random.nextInt(words.length)];
  }

  static List<String> getWordsForDifficulty(GameDifficulty difficulty) {
    return wordsByDifficulty[difficulty] ?? [];
  }
}