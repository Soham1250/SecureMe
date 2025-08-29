import 'dart:math' as math;
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import '../models/password_generator_models.dart';

class PasswordGeneratorService {
  // Built-in wordlist (subset of common words for compactness)
  static const List<String> _wordlist = [
    'able', 'about', 'account', 'acid', 'across', 'act', 'addition', 'adjust', 'admit', 'adult',
    'after', 'again', 'against', 'age', 'agent', 'ago', 'agree', 'air', 'all', 'allow',
    'almost', 'alone', 'along', 'already', 'also', 'although', 'always', 'among', 'another', 'answer',
    'any', 'anyone', 'anything', 'appear', 'apple', 'apply', 'approach', 'area', 'argue', 'army',
    'around', 'arrive', 'article', 'artist', 'assume', 'attack', 'attempt', 'attend', 'attention', 'attract',
    'audience', 'author', 'authority', 'available', 'avoid', 'away', 'baby', 'back', 'bad', 'bag',
    'ball', 'bank', 'base', 'basic', 'battle', 'beat', 'beautiful', 'because', 'become', 'bed',
    'before', 'begin', 'behavior', 'behind', 'believe', 'benefit', 'best', 'better', 'between', 'beyond',
    'big', 'bill', 'billion', 'black', 'blood', 'blow', 'blue', 'board', 'body', 'book',
    'born', 'both', 'box', 'boy', 'break', 'bring', 'brother', 'budget', 'build', 'building',
    'business', 'buy', 'call', 'camera', 'campaign', 'cancer', 'candidate', 'capital', 'card', 'care',
    'career', 'carry', 'case', 'catch', 'cause', 'cell', 'center', 'central', 'century', 'certain',
    'certainly', 'chair', 'challenge', 'chance', 'change', 'character', 'charge', 'check', 'child', 'choice',
    'choose', 'church', 'citizen', 'city', 'civil', 'claim', 'class', 'clear', 'clearly', 'close',
    'coach', 'cold', 'collection', 'college', 'color', 'come', 'commercial', 'common', 'community', 'company',
    'compare', 'computer', 'concern', 'condition', 'conference', 'congress', 'consider', 'consumer', 'contain', 'continue',
    'control', 'cost', 'could', 'country', 'couple', 'course', 'court', 'cover', 'create', 'crime',
    'cultural', 'culture', 'current', 'customer', 'dark', 'data', 'daughter', 'deal', 'death', 'debate',
    'decade', 'decide', 'decision', 'deep', 'defense', 'degree', 'democrat', 'democratic', 'describe', 'design',
    'despite', 'detail', 'determine', 'develop', 'development', 'difference', 'different', 'difficult', 'dinner', 'direction',
    'director', 'discover', 'discuss', 'disease', 'doctor', 'door', 'down', 'draw', 'dream', 'drive',
    'drop', 'drug', 'during', 'each', 'early', 'east', 'easy', 'economic', 'economy', 'edge',
    'education', 'effect', 'effort', 'eight', 'either', 'election', 'else', 'employee', 'energy', 'enjoy',
    'enough', 'enter', 'entire', 'environment', 'especially', 'establish', 'even', 'evening', 'event', 'ever',
    'every', 'everybody', 'everyone', 'everything', 'evidence', 'exactly', 'example', 'executive', 'exist', 'expect',
    'experience', 'expert', 'explain', 'face', 'fact', 'factor', 'fail', 'fall', 'family', 'fast',
    'father', 'fear', 'federal', 'feel', 'feeling', 'field', 'fight', 'figure', 'fill', 'film',
    'final', 'finally', 'financial', 'find', 'fine', 'finger', 'finish', 'fire', 'firm', 'first',
    'fish', 'five', 'floor', 'focus', 'follow', 'food', 'foot', 'force', 'foreign', 'forget',
    'form', 'former', 'forward', 'four', 'free', 'friend', 'from', 'front', 'full', 'fund',
    'future', 'game', 'garden', 'general', 'generation', 'girl', 'give', 'glass', 'goal', 'good',
    'government', 'great', 'green', 'ground', 'group', 'grow', 'growth', 'guess', 'gun', 'guy',
    'hair', 'half', 'hand', 'hang', 'happen', 'happy', 'hard', 'have', 'head', 'health',
    'hear', 'heart', 'heat', 'heavy', 'help', 'here', 'herself', 'high', 'him', 'himself',
    'his', 'history', 'hit', 'hold', 'home', 'hope', 'hospital', 'hot', 'hotel', 'hour',
    'house', 'how', 'however', 'huge', 'human', 'hundred', 'husband', 'idea', 'identify', 'image',
    'imagine', 'impact', 'important', 'improve', 'include', 'including', 'increase', 'indeed', 'indicate', 'individual',
    'industry', 'information', 'inside', 'instead', 'institution', 'interest', 'interesting', 'international', 'interview', 'into',
    'investment', 'involve', 'issue', 'item', 'itself', 'job', 'join', 'just', 'keep', 'key',
    'kid', 'kill', 'kind', 'kitchen', 'know', 'knowledge', 'land', 'language', 'large', 'last',
    'late', 'later', 'laugh', 'law', 'lawyer', 'lay', 'lead', 'leader', 'learn', 'least',
    'leave', 'left', 'legal', 'less', 'let', 'letter', 'level', 'life', 'light', 'like',
    'line', 'list', 'listen', 'little', 'live', 'local', 'long', 'look', 'lose', 'loss',
    'lot', 'love', 'low', 'machine', 'magazine', 'main', 'maintain', 'major', 'make', 'man',
    'manage', 'management', 'manager', 'many', 'market', 'marriage', 'material', 'matter', 'may', 'maybe',
    'mean', 'measure', 'media', 'medical', 'meet', 'meeting', 'member', 'memory', 'mention', 'message',
    'method', 'middle', 'might', 'military', 'million', 'mind', 'minute', 'miss', 'mission', 'model',
    'modern', 'moment', 'money', 'month', 'more', 'morning', 'most', 'mother', 'mouth', 'move',
    'movement', 'movie', 'much', 'music', 'must', 'myself', 'name', 'nation', 'national', 'natural',
    'nature', 'near', 'nearly', 'necessary', 'need', 'network', 'never', 'new', 'news', 'newspaper',
    'next', 'nice', 'night', 'nine', 'none', 'nor', 'north', 'not', 'note', 'nothing',
    'notice', 'now', 'number', 'occur', 'of', 'off', 'offer', 'office', 'officer', 'official',
    'often', 'oil', 'old', 'once', 'one', 'only', 'onto', 'open', 'operation', 'opportunity',
    'option', 'or', 'order', 'organization', 'other', 'others', 'our', 'out', 'outside', 'over',
    'own', 'owner', 'page', 'pain', 'painting', 'paper', 'parent', 'part', 'participant', 'particular',
    'particularly', 'partner', 'party', 'pass', 'past', 'patient', 'pattern', 'pay', 'peace', 'people',
    'per', 'perform', 'performance', 'perhaps', 'period', 'person', 'personal', 'phone', 'physical', 'pick',
    'picture', 'piece', 'place', 'plan', 'plant', 'play', 'player', 'please', 'point', 'police',
    'policy', 'political', 'politics', 'poor', 'popular', 'population', 'position', 'positive', 'possible', 'power',
    'practice', 'prepare', 'present', 'president', 'pressure', 'pretty', 'prevent', 'price', 'private', 'probably',
    'problem', 'process', 'produce', 'product', 'production', 'professional', 'professor', 'program', 'project', 'property',
    'protect', 'prove', 'provide', 'public', 'pull', 'purpose', 'push', 'put', 'quality', 'question',
    'quickly', 'quite', 'race', 'radio', 'raise', 'range', 'rate', 'rather', 'reach', 'read',
    'ready', 'real', 'reality', 'realize', 'really', 'reason', 'receive', 'recent', 'recently', 'recognize',
    'record', 'red', 'reduce', 'reflect', 'region', 'relate', 'relationship', 'religious', 'remain', 'remember',
    'remove', 'report', 'represent', 'republican', 'require', 'research', 'resource', 'respond', 'response', 'responsibility',
    'rest', 'result', 'return', 'reveal', 'rich', 'right', 'rise', 'risk', 'road', 'rock',
    'role', 'room', 'rule', 'run', 'safe', 'same', 'save', 'say', 'scene', 'school',
    'science', 'scientist', 'score', 'sea', 'season', 'seat', 'second', 'section', 'security', 'see',
    'seek', 'seem', 'sell', 'send', 'senior', 'sense', 'series', 'serious', 'serve', 'service',
    'set', 'seven', 'several', 'sex', 'sexual', 'shake', 'share', 'she', 'shoot', 'short',
    'shot', 'should', 'shoulder', 'show', 'side', 'sign', 'significant', 'similar', 'simple', 'simply',
    'since', 'sing', 'single', 'sister', 'sit', 'site', 'situation', 'six', 'size', 'skill',
    'skin', 'small', 'smile', 'so', 'social', 'society', 'soldier', 'some', 'somebody', 'someone',
    'something', 'sometimes', 'son', 'song', 'soon', 'sort', 'sound', 'source', 'south', 'southern',
    'space', 'speak', 'special', 'specific', 'speech', 'spend', 'sport', 'spring', 'staff', 'stage',
    'stand', 'standard', 'star', 'start', 'state', 'statement', 'station', 'stay', 'step', 'still',
    'stock', 'stop', 'store', 'story', 'strategy', 'street', 'strong', 'structure', 'student', 'study',
    'stuff', 'style', 'subject', 'success', 'successful', 'such', 'suddenly', 'suffer', 'suggest', 'summer',
    'support', 'sure', 'surface', 'system', 'table', 'take', 'talk', 'task', 'tax', 'teach',
    'teacher', 'team', 'technology', 'television', 'tell', 'ten', 'tend', 'term', 'test', 'than',
    'thank', 'that', 'the', 'their', 'them', 'themselves', 'then', 'theory', 'there', 'these',
    'they', 'thing', 'think', 'third', 'this', 'those', 'though', 'thought', 'thousand', 'threat',
    'three', 'through', 'throughout', 'throw', 'thus', 'time', 'to', 'today', 'together', 'tonight',
    'too', 'top', 'total', 'tough', 'toward', 'town', 'trade', 'traditional', 'training', 'travel',
    'treat', 'treatment', 'tree', 'trial', 'trip', 'trouble', 'true', 'truth', 'try', 'turn',
    'two', 'type', 'under', 'understand', 'unit', 'until', 'up', 'upon', 'use', 'used',
    'user', 'usually', 'value', 'various', 'very', 'victim', 'view', 'violence', 'visit', 'voice',
    'vote', 'wait', 'walk', 'wall', 'want', 'war', 'watch', 'water', 'way', 'we',
    'weapon', 'wear', 'week', 'weight', 'well', 'west', 'western', 'what', 'whatever', 'when',
    'where', 'whether', 'which', 'while', 'white', 'who', 'whole', 'whom', 'whose', 'why',
    'wide', 'wife', 'will', 'win', 'wind', 'window', 'wish', 'with', 'within', 'without',
    'woman', 'wonder', 'word', 'work', 'worker', 'world', 'worry', 'would', 'write', 'writer',
    'wrong', 'yard', 'yeah', 'year', 'yes', 'yet', 'you', 'young', 'your', 'yourself'
  ];

  // Character class alphabets
  static const String _upperChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _lowerChars = 'abcdefghijklmnopqrstuvwxyz';
  static const String _digitChars = '0123456789';
  static const String _symbolChars = '!@#\$%^&*_-+=';
  static const String _ambiguousChars = '0O1lI';

  // Cryptographically secure uniform integer in [lo, hi] via rejection sampling
  static int uniformInt(int lo, int hi) {
    final range = hi - lo + 1;
    final limit = (0x100000000 ~/ range) * range;
    
    while (true) {
      final bytes = Uint8List(4);
      for (int i = 0; i < 4; i++) {
        bytes[i] = SecureRandom.fast.nextInt(256);
      }
      
      final x = (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
      if (x < limit) {
        return lo + (x % range);
      }
    }
  }

  // Unbiased character sampling from alphabet
  static String sampleChar(String alphabet) {
    final n = alphabet.length;
    final limit = (256 ~/ n) * n;
    
    while (true) {
      final b = SecureRandom.fast.nextInt(256);
      if (b < limit) {
        return alphabet[b % n];
      }
    }
  }

  // Build alphabet from character classes
  static String buildAlphabet(Set<CharClass> classes, bool excludeAmbiguous, String? allowedSet) {
    String alphabet = '';
    
    if (classes.contains(CharClass.upper)) alphabet += _upperChars;
    if (classes.contains(CharClass.lower)) alphabet += _lowerChars;
    if (classes.contains(CharClass.digit)) alphabet += _digitChars;
    if (classes.contains(CharClass.symbol)) alphabet += _symbolChars;

    if (excludeAmbiguous) {
      for (final char in _ambiguousChars.split('')) {
        alphabet = alphabet.replaceAll(char, '');
      }
    }

    if (allowedSet != null) {
      final allowed = allowedSet.split('').toSet();
      alphabet = alphabet.split('').where((c) => allowed.contains(c)).join('');
    }

    if (alphabet.length < 10) {
      throw ArgumentError('Alphabet too small (${alphabet.length} chars). Need at least 10.');
    }

    return alphabet;
  }

  // Clamp length according to policy
  static int clampLength(int length, PasswordPolicy? policy) {
    int result = length;
    if (policy?.minLen != null) result = math.max(result, policy!.minLen!);
    if (policy?.maxLen != null) result = math.min(result, policy!.maxLen!);
    return result;
  }

  // Check if password satisfies must-include requirements
  static bool mustIncludeSatisfied(String password, PasswordPolicy? policy) {
    if (policy?.mustInclude == null) return true;

    final counts = <CharClass, int>{
      CharClass.upper: RegExp(r'[A-Z]').allMatches(password).length,
      CharClass.lower: RegExp(r'[a-z]').allMatches(password).length,
      CharClass.digit: RegExp(r'[0-9]').allMatches(password).length,
      CharClass.symbol: RegExp(r'[!@#\$%^&*_\-+=]').allMatches(password).length,
    };

    for (final entry in policy!.mustInclude!.entries) {
      if (entry.value && (counts[entry.key] ?? 0) == 0) {
        return false;
      }
    }

    return true;
  }

  // Satisfy must-include by replacing random positions
  static void satisfyMustIncludeInPlace(List<String> pwdChars, PasswordPolicy policy, Map<CharClass, String> alphByClass) {
    final missing = <CharClass>[];
    
    // Detect missing classes
    final password = pwdChars.join('');
    final counts = <CharClass, int>{
      CharClass.upper: RegExp(r'[A-Z]').allMatches(password).length,
      CharClass.lower: RegExp(r'[a-z]').allMatches(password).length,
      CharClass.digit: RegExp(r'[0-9]').allMatches(password).length,
      CharClass.symbol: RegExp(r'[!@#\$%^&*_\-+=]').allMatches(password).length,
    };

    for (final entry in policy.mustInclude!.entries) {
      if (entry.value && (counts[entry.key] ?? 0) == 0) {
        missing.add(entry.key);
      }
    }

    // Replace random positions for each missing class
    for (final cls in missing) {
      final j = uniformInt(0, pwdChars.length - 1);
      pwdChars[j] = sampleChar(alphByClass[cls]!);
    }
  }

  // Generate random character password
  static String randomPassword(RandomCharsOptions opts) {
    final alphabet = buildAlphabet(opts.classes, opts.excludeAmbiguous, opts.policy?.allowedSet);
    final length = clampLength(opts.length, opts.policy);

    // Draw length chars uniformly
    final pwdChars = List.generate(length, (_) => sampleChar(alphabet));

    // Satisfy composition rules if needed
    if (opts.policy?.mustInclude != null && !mustIncludeSatisfied(pwdChars.join(''), opts.policy)) {
      final alphByClass = <CharClass, String>{
        CharClass.upper: buildAlphabet({CharClass.upper}, false, opts.policy?.allowedSet),
        CharClass.lower: buildAlphabet({CharClass.lower}, false, opts.policy?.allowedSet),
        CharClass.digit: buildAlphabet({CharClass.digit}, false, opts.policy?.allowedSet),
        CharClass.symbol: buildAlphabet({CharClass.symbol}, false, opts.policy?.allowedSet),
      };
      satisfyMustIncludeInPlace(pwdChars, opts.policy!, alphByClass);
    }

    return pwdChars.join('');
  }

  // Generate passphrase
  static String randomPassphrase(PassphraseOptions opts) {
    final wordCount = _wordlist.length;
    final words = <String>[];

    // Select random words
    for (int i = 0; i < opts.words; i++) {
      final idx = uniformInt(0, wordCount - 1);
      words.add(_wordlist[idx]);
    }

    String phrase = words.join(opts.separator);

    // Add digit at random position
    if (opts.addDigit) {
      final pos = uniformInt(0, phrase.length);
      final digit = uniformInt(0, 9).toString();
      phrase = phrase.substring(0, pos) + digit + phrase.substring(pos);
    }

    // Add symbol at random position
    if (opts.addSymbol) {
      final pos = uniformInt(0, phrase.length);
      final symbol = sampleChar(_symbolChars);
      phrase = phrase.substring(0, pos) + symbol + phrase.substring(pos);
    }

    return phrase;
  }

  // Calculate password strength score (0-100)
  static int calculateStrength(String password) {
    if (password.isEmpty) return 0;

    int score = 0;
    
    // Length scoring (0-40 points)
    if (password.length >= 8) score += 10;
    if (password.length >= 12) score += 10;
    if (password.length >= 16) score += 10;
    if (password.length >= 20) score += 10;

    // Character variety (0-40 points)
    if (RegExp(r'[a-z]').hasMatch(password)) score += 10;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 10;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 10;
    if (RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]').hasMatch(password)) score += 10;

    // Entropy bonus (0-20 points)
    final uniqueChars = password.split('').toSet().length;
    if (uniqueChars >= password.length * 0.7) score += 10;
    if (uniqueChars >= password.length * 0.9) score += 10;

    return math.min(score, 100);
  }

  // Get strength description
  static String getStrengthDescription(int score) {
    if (score < 30) return 'Very Weak';
    if (score < 50) return 'Weak';
    if (score < 70) return 'Fair';
    if (score < 90) return 'Good';
    return 'Excellent';
  }
}
