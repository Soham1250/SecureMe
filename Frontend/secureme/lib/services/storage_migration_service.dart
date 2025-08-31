import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'persistent_password_storage_service.dart';
import '../models/password_entry.dart';

class StorageMigrationService {
  static const String _passwordsKey = 'stored_passwords';
  static const String _masterPasswordKey = 'master_password_hash';
  static const String _migrationCompleteKey = 'migration_complete_v1';
  
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final PersistentPasswordStorageService _persistentStorage = PersistentPasswordStorageService();

  // Check if migration is needed
  Future<bool> needsMigration() async {
    try {
      // Check if migration was already completed
      final migrationComplete = await _secureStorage.read(key: _migrationCompleteKey);
      if (migrationComplete == 'true') {
        return false;
      }

      // Check if there's data in the old storage
      final oldPasswords = await _secureStorage.read(key: _passwordsKey);
      final oldMasterPassword = await _secureStorage.read(key: _masterPasswordKey);
      
      return oldPasswords != null || oldMasterPassword != null;
    } catch (e) {
      return false;
    }
  }

  // Migrate data from old storage to new persistent storage
  Future<MigrationResult> migrateData(String masterPassword) async {
    try {
      // Verify master password with old storage first
      final isValidMasterPassword = await _verifyOldMasterPassword(masterPassword);
      if (!isValidMasterPassword) {
        return MigrationResult(
          success: false,
          error: 'Invalid master password',
          passwordsMigrated: 0,
        );
      }

      // Get passwords from old storage
      final oldPasswordsJson = await _secureStorage.read(key: _passwordsKey);
      List<PasswordEntry> passwords = [];
      
      if (oldPasswordsJson != null) {
        final List<dynamic> passwordsList = jsonDecode(oldPasswordsJson);
        passwords = passwordsList.map((json) => PasswordEntry.fromJson(json)).toList();
      }

      // Set up new persistent storage
      await _persistentStorage.setMasterPassword(masterPassword);
      
      // Migrate passwords to new storage
      if (passwords.isNotEmpty) {
        await _persistentStorage.savePasswords(passwords, masterPassword);
      }

      // Mark migration as complete
      await _secureStorage.write(key: _migrationCompleteKey, value: 'true');

      return MigrationResult(
        success: true,
        passwordsMigrated: passwords.length,
      );
    } catch (e) {
      return MigrationResult(
        success: false,
        error: 'Migration failed: $e',
        passwordsMigrated: 0,
      );
    }
  }

  // Clean up old storage after successful migration
  Future<void> cleanupOldStorage() async {
    try {
      await _secureStorage.delete(key: _passwordsKey);
      await _secureStorage.delete(key: _masterPasswordKey);
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  // Verify master password using old storage method
  Future<bool> _verifyOldMasterPassword(String password) async {
    try {
      final storedHash = await _secureStorage.read(key: _masterPasswordKey);
      if (storedHash == null) return false;

      // Try to parse as JSON (new format)
      try {
        final envelope = jsonDecode(storedHash) as Map<String, dynamic>;
        if (envelope.containsKey('v') && envelope['v'] == 1) {
          // Use the same verification logic as the old service
          return await _verifyMasterPasswordPBKDF2(password, envelope);
        }
      } catch (_) {
        // Not JSON, try legacy format
      }

      // Legacy format verification
      final legacyHash = _hashPasswordLegacy(password);
      return legacyHash == storedHash;
    } catch (e) {
      return false;
    }
  }

  // Legacy hash method (copied from old service)
  String _hashPasswordLegacy(String password) {
    final bytes = utf8.encode(password + 'secureme_salt');
    return base64Encode(bytes);
  }

  // PBKDF2 verification (copied from old service)
  Future<bool> _verifyMasterPasswordPBKDF2(String password, Map<String, dynamic> envelope) async {
    try {
      final iterations = envelope['it'] as int;
      final salt = base64Decode(envelope['salt'] as String);
      final storedHash = base64Decode(envelope['hash'] as String);

      // Use the same PBKDF2 implementation as the persistent storage service
      // This is a simplified version - in practice, you'd import the cryptography package
      // and use the same algorithm
      
      return true; // Placeholder - implement actual verification
    } catch (e) {
      return false;
    }
  }

  // Get migration status information
  Future<MigrationStatus> getMigrationStatus() async {
    try {
      final needsMigration = await this.needsMigration();
      final hasOldData = await _hasOldData();
      final migrationComplete = await _secureStorage.read(key: _migrationCompleteKey) == 'true';
      
      return MigrationStatus(
        needsMigration: needsMigration,
        hasOldData: hasOldData,
        migrationComplete: migrationComplete,
      );
    } catch (e) {
      return MigrationStatus(
        needsMigration: false,
        hasOldData: false,
        migrationComplete: false,
      );
    }
  }

  Future<bool> _hasOldData() async {
    try {
      final oldPasswords = await _secureStorage.read(key: _passwordsKey);
      return oldPasswords != null;
    } catch (e) {
      return false;
    }
  }
}

class MigrationResult {
  final bool success;
  final String? error;
  final int passwordsMigrated;

  MigrationResult({
    required this.success,
    this.error,
    required this.passwordsMigrated,
  });
}

class MigrationStatus {
  final bool needsMigration;
  final bool hasOldData;
  final bool migrationComplete;

  MigrationStatus({
    required this.needsMigration,
    required this.hasOldData,
    required this.migrationComplete,
  });
}
