import 'package:flutter/material.dart';
import '../services/storage_migration_service.dart';
import '../services/persistent_password_storage_service.dart';

class StorageMigrationDialog extends StatefulWidget {
  final VoidCallback onMigrationComplete;

  const StorageMigrationDialog({
    Key? key,
    required this.onMigrationComplete,
  }) : super(key: key);

  @override
  State<StorageMigrationDialog> createState() => _StorageMigrationDialogState();
}

class _StorageMigrationDialogState extends State<StorageMigrationDialog> {
  final _migrationService = StorageMigrationService();
  final _persistentStorage = PersistentPasswordStorageService();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  MigrationStatus? _migrationStatus;

  @override
  void initState() {
    super.initState();
    _loadMigrationStatus();
  }

  Future<void> _loadMigrationStatus() async {
    final status = await _migrationService.getMigrationStatus();
    setState(() {
      _migrationStatus = status;
    });
  }

  Future<void> _performMigration() async {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your master password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Request storage permissions first
      final hasPermission = await _persistentStorage.requestStoragePermissions();
      if (!hasPermission) {
        setState(() {
          _errorMessage = 'Storage permission is required for persistent password storage';
          _isLoading = false;
        });
        return;
      }

      // Perform migration
      final result = await _migrationService.migrateData(_passwordController.text);
      
      if (result.success) {
        // Clean up old storage
        await _migrationService.cleanupOldStorage();
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully migrated ${result.passwordsMigrated} passwords to persistent storage!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        widget.onMigrationComplete();
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Migration failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Migration failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.upgrade, color: Colors.blue),
          SizedBox(width: 8),
          Text('Storage Migration'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SecureMe now uses persistent storage that survives app uninstalls. '
              'Your passwords will be stored securely on your device and won\'t be lost when you uninstall the app.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            if (_migrationStatus?.hasOldData == true) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'We found existing passwords that need to be migrated to the new storage system.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'Enter your master password to migrate your data:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Master Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                errorText: _errorMessage,
              ),
              onSubmitted: (_) => _performMigration(),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Benefits of Persistent Storage:',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Passwords survive app uninstalls\n'
                    '• Military-grade AES-GCM encryption\n'
                    '• PBKDF2 key derivation (150,000 iterations)\n'
                    '• Local storage only (no cloud sync)',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _performMigration,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Migrate Data'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
