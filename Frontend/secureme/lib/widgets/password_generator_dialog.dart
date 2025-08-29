import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_generator_models.dart';
import '../services/password_generator_service.dart';

class PasswordGeneratorDialog extends StatefulWidget {
  const PasswordGeneratorDialog({super.key});

  @override
  State<PasswordGeneratorDialog> createState() =>
      _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  bool _isPassphrase = false;
  String _generatedPassword = '';
  int _passwordStrength = 0;

  // Random chars options
  int _length = 16;
  Set<CharClass> _selectedClasses = {
    CharClass.upper,
    CharClass.lower,
    CharClass.digit
  };
  bool _excludeAmbiguous = true;

  // Passphrase options
  int _wordCount = 5;
  bool _addDigit = true;
  bool _addSymbol = false;
  bool _capitalizeWords = true;
  String _separator = '-';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    try {
      String password;

      if (_isPassphrase) {
        final opts = PassphraseOptions(
          words: _wordCount,
          addDigit: _addDigit,
          addSymbol: _addSymbol,
          capitalizeWords: _capitalizeWords,
          separator: _separator,
        );
        password = PasswordGeneratorService.randomPassphrase(opts);
      } else {
        final opts = RandomCharsOptions(
          length: _length,
          classes: _selectedClasses,
          excludeAmbiguous: _excludeAmbiguous,
        );
        password = PasswordGeneratorService.randomPassword(opts);
      }

      setState(() {
        _generatedPassword = password;
        _passwordStrength =
            PasswordGeneratorService.calculateStrength(password);
      });
    } catch (e) {
      setState(() {
        _generatedPassword = 'Error generating password';
        _passwordStrength = 0;
      });
    }
  }

  void _applyPreset(String preset) {
    setState(() {
      switch (preset) {
        case 'balanced':
          _isPassphrase = false;
          _length = 20;
          _selectedClasses = {
            CharClass.upper,
            CharClass.lower,
            CharClass.digit
          };
          _excludeAmbiguous = true;
          break;
        case 'symbols':
          _isPassphrase = false;
          _length = 18;
          _selectedClasses = {
            CharClass.upper,
            CharClass.lower,
            CharClass.digit,
            CharClass.symbol
          };
          _excludeAmbiguous = true;
          break;
        case 'strong':
          _isPassphrase = false;
          _length = 24;
          _selectedClasses = {
            CharClass.upper,
            CharClass.lower,
            CharClass.digit,
            CharClass.symbol
          };
          _excludeAmbiguous = false;
          break;
        case 'passphrase':
          _isPassphrase = true;
          _wordCount = 6;
          _addDigit = true;
          _addSymbol = false;
          _capitalizeWords = true;
          _separator = '-';
          break;
        case 'simple_passphrase':
          _isPassphrase = true;
          _wordCount = 4;
          _addDigit = false;
          _addSymbol = false;
          _capitalizeWords = false;
          _separator = ' ';
          break;
      }
    });
    _generatePassword();
  }

  Color _getStrengthColor() {
    final colorScheme = Theme.of(context).colorScheme;
    if (_passwordStrength < 30) return colorScheme.error;
    if (_passwordStrength < 50) return Colors.orange;
    if (_passwordStrength < 70) return Colors.amber;
    if (_passwordStrength < 90) return Colors.lightGreen;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isVerySmallScreen = screenSize.width < 400;

    return Dialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      insetPadding: EdgeInsets.all(isSmallScreen ? 16 : 40),
      child: Container(
        width: isSmallScreen ? double.infinity : 500,
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.9,
          maxWidth: isSmallScreen ? screenSize.width - 32 : 500,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isVerySmallScreen ? 16 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.vpn_key,
                      size: isVerySmallScreen ? 24 : 28,
                      color: colorScheme.primary,
                    ),
                    SizedBox(width: isVerySmallScreen ? 8 : 12),
                    Expanded(
                      child: Text(
                        'Password Generator',
                        style: (isVerySmallScreen
                                ? theme.textTheme.titleLarge
                                : theme.textTheme.headlineSmall)
                            ?.copyWith(color: colorScheme.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Generated password display
                Card(
                  elevation: 1,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Password text
                        SelectableText(
                          _generatedPassword.isEmpty
                              ? 'Generating...'
                              : _generatedPassword,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: isVerySmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: _generatedPassword));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Password copied to clipboard'),
                                    backgroundColor: colorScheme.inverseSurface,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 20),
                              tooltip: 'Copy',
                            ),
                            IconButton(
                              onPressed: _generatePassword,
                              icon: const Icon(Icons.refresh, size: 20),
                              tooltip: 'Generate New',
                            ),
                          ],
                        ),

                        // Strength indicator
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Strength: ${PasswordGeneratorService.getStrengthDescription(_passwordStrength)}',
                              style: TextStyle(
                                color: _getStrengthColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('($_passwordStrength/100)'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _passwordStrength / 100,
                          backgroundColor: colorScheme.surfaceVariant,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_getStrengthColor()),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Type toggle
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      label: Text(isSmallScreen ? 'Random' : 'Random Characters'),
                      icon: const Icon(Icons.shuffle),
                    ),
                    const ButtonSegment(
                      value: true,
                      label: Text('Passphrase'),
                      icon: Icon(Icons.format_quote),
                    ),
                  ],
                  selected: {_isPassphrase},
                  onSelectionChanged: (Set<bool> selection) {
                    setState(() {
                      _isPassphrase = selection.first;
                    });
                    _generatePassword();
                  },
                ),
                const SizedBox(height: 24),

                // Options based on type
                if (!_isPassphrase) ..._buildRandomCharsOptions(theme, colorScheme, isVerySmallScreen)
                else ..._buildPassphraseOptions(theme, colorScheme, isVerySmallScreen),

                const SizedBox(height: 24),

                // Presets
                Text(
                  'Quick Presets',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPresetChip('Balanced (20)', 'balanced', colorScheme),
                    _buildPresetChip('With Symbols (18)', 'symbols', colorScheme),
                    _buildPresetChip('Strong (24)', 'strong', colorScheme),
                    _buildPresetChip('Passphrase (6)', 'passphrase', colorScheme),
                    _buildPresetChip('Simple Phrase (4)', 'simple_passphrase', colorScheme),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, _generatedPassword),
                      child: const Text('Use This Password'),
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

  List<Widget> _buildRandomCharsOptions(ThemeData theme, ColorScheme colorScheme, bool isVerySmallScreen) {
    return [
      // Length slider
      Text(
        'Length: $_length characters',
        style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onSurface),
      ),
      Slider(
        value: _length.toDouble(),
        min: 8,
        max: 64,
        divisions: 56,
        onChanged: (value) {
          setState(() {
            _length = value.round();
          });
          _generatePassword();
        },
      ),
      const SizedBox(height: 16),

      // Character classes
      Text(
        'Character Types',
        style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onSurface),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChip(
            label: const Text('A-Z'),
            selected: _selectedClasses.contains(CharClass.upper),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedClasses.add(CharClass.upper);
                } else {
                  _selectedClasses.remove(CharClass.upper);
                }
              });
              _generatePassword();
            },
          ),
          FilterChip(
            label: const Text('a-z'),
            selected: _selectedClasses.contains(CharClass.lower),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedClasses.add(CharClass.lower);
                } else {
                  _selectedClasses.remove(CharClass.lower);
                }
              });
              _generatePassword();
            },
          ),
          FilterChip(
            label: const Text('0-9'),
            selected: _selectedClasses.contains(CharClass.digit),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedClasses.add(CharClass.digit);
                } else {
                  _selectedClasses.remove(CharClass.digit);
                }
              });
              _generatePassword();
            },
          ),
          FilterChip(
            label: const Text('!@#'),
            selected: _selectedClasses.contains(CharClass.symbol),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedClasses.add(CharClass.symbol);
                } else {
                  _selectedClasses.remove(CharClass.symbol);
                }
              });
              _generatePassword();
            },
          ),
        ],
      ),
      const SizedBox(height: 16),

      // Options
      SwitchListTile(
        title: Text(
          isVerySmallScreen
              ? 'Exclude ambiguous (0,O,1,l,I)'
              : 'Exclude ambiguous characters (0, O, 1, l, I)',
          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
        value: _excludeAmbiguous,
        onChanged: (value) {
          setState(() {
            _excludeAmbiguous = value;
          });
          _generatePassword();
        },
      ),
    ];
  }

  List<Widget> _buildPassphraseOptions(ThemeData theme, ColorScheme colorScheme, bool isVerySmallScreen) {
    return [
      // Word count slider
      Text(
        'Words: $_wordCount',
        style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onSurface),
      ),
      Slider(
        value: _wordCount.toDouble(),
        min: 3,
        max: 10,
        divisions: 7,
        onChanged: (value) {
          setState(() {
            _wordCount = value.round();
          });
          _generatePassword();
        },
      ),
      const SizedBox(height: 16),

      // Options
      SwitchListTile(
        title: Text(
          'Add digit',
          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
        value: _addDigit,
        onChanged: (value) {
          setState(() {
            _addDigit = value;
          });
          _generatePassword();
        },
      ),
      SwitchListTile(
        title: Text(
          'Add symbol',
          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
        value: _addSymbol,
        onChanged: (value) {
          setState(() {
            _addSymbol = value;
          });
          _generatePassword();
        },
      ),
      SwitchListTile(
        title: Text(
          'Capitalize words',
          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
        value: _capitalizeWords,
        onChanged: (value) {
          setState(() {
            _capitalizeWords = value;
          });
          _generatePassword();
        },
      ),

      // Separator
      Row(
        children: [
          Text(
            'Separator:',
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _separator,
            items: const [
              DropdownMenuItem(value: '-', child: Text('Hyphen (-)')),
              DropdownMenuItem(value: '_', child: Text('Underscore (_)')),
              DropdownMenuItem(value: '.', child: Text('Period (.)')),
              DropdownMenuItem(value: ' ', child: Text('Space')),
            ],
            onChanged: (value) {
              setState(() {
                _separator = value ?? '-';
              });
              _generatePassword();
            },
          ),
        ],
      ),
    ];
  }

  Widget _buildPresetChip(String label, String preset, ColorScheme colorScheme) {
    return ActionChip(
      label: Text(label),
      onPressed: () => _applyPreset(preset),
      backgroundColor: colorScheme.secondaryContainer,
      labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
    );
  }
}
