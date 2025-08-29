import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_entry.dart';
import '../services/password_storage_service.dart';
import '../services/password_generator_service.dart';
import '../widgets/password_generator_dialog.dart';

class AddEditPasswordScreen extends StatefulWidget {
  final PasswordEntry? password;

  const AddEditPasswordScreen({super.key, this.password});

  @override
  State<AddEditPasswordScreen> createState() => _AddEditPasswordScreenState();
}

class _AddEditPasswordScreenState extends State<AddEditPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final PasswordStorageService _storageService = PasswordStorageService();

  late final TextEditingController _titleController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _websiteController;
  late final TextEditingController _notesController;

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.password?.title ?? '');
    _usernameController = TextEditingController(text: widget.password?.username ?? '');
    _passwordController = TextEditingController(text: widget.password?.password ?? '');
    _websiteController = TextEditingController(text: widget.password?.website ?? '');
    _notesController = TextEditingController(text: widget.password?.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.password != null;

  String get _screenTitle => _isEditing ? 'Edit Password' : 'Add Password';

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final PasswordEntry entry;
      
      if (_isEditing) {
        entry = widget.password!.copyWith(
          title: _titleController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          website: _websiteController.text.trim().isEmpty 
              ? null 
              : _websiteController.text.trim(),
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
        );
        await _storageService.updatePassword(entry);
      } else {
        entry = PasswordEntry.create(
          title: _titleController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          website: _websiteController.text.trim().isEmpty 
              ? null 
              : _websiteController.text.trim(),
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
        );
        await _storageService.savePassword(entry);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing 
                ? 'Password updated successfully' 
                : 'Password saved successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save password: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePassword() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const PasswordGeneratorDialog(),
    );
    
    if (result != null) {
      _passwordController.text = result;
    }
  }

  Color _getPasswordStrengthColor(int strength) {
    if (strength < 30) return Colors.red;
    if (strength < 50) return Colors.orange;
    if (strength < 70) return Colors.yellow[700]!;
    if (strength < 90) return Colors.lightGreen;
    return Colors.green;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitle),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _savePassword,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., Gmail, Facebook',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username/Email *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Username/Email is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password *',
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_isPasswordVisible 
                          ? Icons.visibility_off 
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.auto_fix_high),
                      onPressed: _generatePassword,
                      tooltip: 'Advanced Generator',
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _passwordController.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password copied to clipboard')),
                        );
                      },
                      tooltip: 'Copy Password',
                    ),
                  ],
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {}); // Trigger rebuild for password strength indicator
              },
            ),
            const SizedBox(height: 8),
            // Password strength indicator
            if (_passwordController.text.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    'Strength: ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    PasswordGeneratorService.getStrengthDescription(
                      PasswordGeneratorService.calculateStrength(_passwordController.text)
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getPasswordStrengthColor(
                        PasswordGeneratorService.calculateStrength(_passwordController.text)
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: PasswordGeneratorService.calculateStrength(_passwordController.text) / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getPasswordStrengthColor(
                    PasswordGeneratorService.calculateStrength(_passwordController.text)
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website (Optional)',
                hintText: 'e.g., https://example.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Additional information',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password Tips',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('• Use at least 12 characters'),
                    const Text('• Include uppercase and lowercase letters'),
                    const Text('• Include numbers and symbols'),
                    const Text('• Avoid common words or patterns'),
                    const Text('• Use unique passwords for each account'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
