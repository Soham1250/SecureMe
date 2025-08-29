enum CharClass {
  upper,
  lower,
  digit,
  symbol,
}

class PasswordPolicy {
  final int? minLen;
  final int? maxLen;
  final String? allowedSet;
  final Map<CharClass, bool>? mustInclude;

  const PasswordPolicy({
    this.minLen,
    this.maxLen,
    this.allowedSet,
    this.mustInclude,
  });
}

class RandomCharsOptions {
  final int length;
  final Set<CharClass> classes;
  final bool excludeAmbiguous;
  final PasswordPolicy? policy;

  const RandomCharsOptions({
    required this.length,
    required this.classes,
    this.excludeAmbiguous = true,
    this.policy,
  });

  RandomCharsOptions copyWith({
    int? length,
    Set<CharClass>? classes,
    bool? excludeAmbiguous,
    PasswordPolicy? policy,
  }) {
    return RandomCharsOptions(
      length: length ?? this.length,
      classes: classes ?? this.classes,
      excludeAmbiguous: excludeAmbiguous ?? this.excludeAmbiguous,
      policy: policy ?? this.policy,
    );
  }
}

class PassphraseOptions {
  final int words;
  final bool addDigit;
  final bool addSymbol;
  final bool capitalizeWords;
  final String separator;

  const PassphraseOptions({
    required this.words,
    this.addDigit = false,
    this.addSymbol = false,
    this.capitalizeWords = true,
    this.separator = '-',
  });

  PassphraseOptions copyWith({
    int? words,
    bool? addDigit,
    bool? addSymbol,
    bool? capitalizeWords,
    String? separator,
  }) {
    return PassphraseOptions(
      words: words ?? this.words,
      addDigit: addDigit ?? this.addDigit,
      addSymbol: addSymbol ?? this.addSymbol,
      capitalizeWords: capitalizeWords ?? this.capitalizeWords,
      separator: separator ?? this.separator,
    );
  }
}

// Preset configurations
class PasswordPresets {
  static RandomCharsOptions balancedPassword() {
    return const RandomCharsOptions(
      length: 20,
      classes: {CharClass.upper, CharClass.lower, CharClass.digit},
      excludeAmbiguous: true,
    );
  }

  static RandomCharsOptions symbolsLightPassword() {
    return const RandomCharsOptions(
      length: 18,
      classes: {CharClass.upper, CharClass.lower, CharClass.digit, CharClass.symbol},
      excludeAmbiguous: true,
    );
  }

  static RandomCharsOptions strongPassword() {
    return const RandomCharsOptions(
      length: 24,
      classes: {CharClass.upper, CharClass.lower, CharClass.digit, CharClass.symbol},
      excludeAmbiguous: false,
    );
  }

  static PassphraseOptions standardPassphrase() {
    return const PassphraseOptions(
      words: 6,
      addDigit: true,
      addSymbol: true,
      separator: '-',
    );
  }

  static PassphraseOptions simplePassphrase() {
    return const PassphraseOptions(
      words: 4,
      addDigit: false,
      addSymbol: false,
      separator: '-',
    );
  }
}
