import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final AuthService _authService = AuthService();
  final TextEditingController _masterPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _hasMasterPassword = false;
  bool _isBiometricAvailable = false;
  bool _showMasterPasswordInput = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAuthMethods();
  }

  @override
  void dispose() {
    _masterPasswordController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthMethods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hasMasterPassword = await _authService.hasMasterPassword();
      final isBiometricAvailable = await _authService.isBiometricAvailable();

      setState(() {
        _hasMasterPassword = hasMasterPassword;
        _isBiometricAvailable = isBiometricAvailable;
        _isLoading = false;
      });

      // If no authentication methods are available, show setup dialog
      if (!hasMasterPassword && !isBiometricAvailable) {
        _showSetupDialog();
      } else if (isBiometricAvailable && !_showMasterPasswordInput) {
        // Try biometric authentication first
        _authenticateWithBiometric();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to check authentication methods: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _authenticateWithBiometric() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _authService.authenticateWithBiometrics();
      
      if (result.success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _error = result.error;
          _showMasterPasswordInput = _hasMasterPassword;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Biometric authentication failed: $e';
        _showMasterPasswordInput = _hasMasterPassword;
        _isLoading = false;
      });
    }
  }

  Future<void> _authenticateWithMasterPassword() async {
    if (_masterPasswordController.text.isEmpty) {
      setState(() {
        _error = 'Please enter your master password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _authService.authenticateWithMasterPassword(
        _masterPasswordController.text,
      );

      if (result.success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _error = result.error ?? 'Invalid master password';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Master password authentication failed: $e';
        _isLoading = false;
      });
    }
  }

  void _showSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SetupMasterPasswordDialog(),
    ).then((result) {
      if (result == true) {
        _checkAuthMethods();
      } else {
        Navigator.of(context).pop(false);
      }
    });
  }

  void _switchToMasterPassword() {
    setState(() {
      _showMasterPasswordInput = true;
      _error = null;
    });
  }

  void _switchToBiometric() {
    setState(() {
      _showMasterPasswordInput = false;
      _error = null;
    });
    _authenticateWithBiometric();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Authentication Required'),
      content: _buildContent(),
      actions: _buildActions(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Authenticating...'),
        ],
      );
    }

    if (_showMasterPasswordInput) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter your master password to access your passwords.'),
          const SizedBox(height: 16),
          TextField(
            controller: _masterPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Master Password',
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
            onSubmitted: (_) => _authenticateWithMasterPassword(),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.fingerprint,
          size: 64,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        const Text('Use biometric authentication or device passcode to access your passwords.'),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildActions() {
    if (_isLoading) {
      return [];
    }

    final actions = <Widget>[
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('Cancel'),
      ),
    ];

    if (_showMasterPasswordInput) {
      actions.addAll([
        if (_isBiometricAvailable)
          TextButton(
            onPressed: _switchToBiometric,
            child: const Text('Use Biometric'),
          ),
        ElevatedButton(
          onPressed: _authenticateWithMasterPassword,
          child: const Text('Authenticate'),
        ),
      ]);
    } else {
      actions.addAll([
        if (_hasMasterPassword)
          TextButton(
            onPressed: _switchToMasterPassword,
            child: const Text('Use Master Password'),
          ),
        ElevatedButton(
          onPressed: _authenticateWithBiometric,
          child: const Text('Try Again'),
        ),
      ]);
    }

    return actions;
  }
}

class SetupMasterPasswordDialog extends StatefulWidget {
  const SetupMasterPasswordDialog({super.key});

  @override
  State<SetupMasterPasswordDialog> createState() => _SetupMasterPasswordDialogState();
}

class _SetupMasterPasswordDialogState extends State<SetupMasterPasswordDialog> {
  final AuthService _authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _setupMasterPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty) {
      setState(() {
        _error = 'Please enter a master password';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _error = 'Master password must be at least 6 characters';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _error = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await _authService.setMasterPassword(password);
      
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _error = 'Failed to set master password';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to set master password: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Setup Master Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'No authentication method is available. Please set up a master password to secure your passwords.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Master Password',
              border: OutlineInputBorder(),
              hintText: 'At least 6 characters',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
            onSubmitted: (_) => _setupMasterPassword(),
          ),
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _setupMasterPassword,
          child: const Text('Setup'),
        ),
      ],
    );
  }
}
