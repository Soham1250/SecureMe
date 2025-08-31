import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';
import '../models/password_entry.dart';
import 'persistent_password_storage_service.dart';
import 'storage_migration_service.dart';

class PasswordStorageService {
  static const String _passwordsKey = 'stored_passwords';
  static const String _masterPasswordKey = 'master_password_hash';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final PersistentPasswordStorageService _persistentStorage = PersistentPasswordStorageService();
  final StorageMigrationService _migrationService = StorageMigrationService();
  
  String? _currentMasterPassword;

  // Get all stored passwords
  Future<List<PasswordEntry>> getAllPasswords() async {
    try {
      // Check if migration is needed
      if (await _migrationService.needsMigration()) {
        throw Exception('Migration required. Please authenticate to migrate your data.');
      }
      
      if (_currentMasterPassword == null) {
        throw Exception('Master password required');
      }
      
      return await _persistentStorage.getAllPasswords(_currentMasterPassword!);
    } catch (e) {
      // Fallback to old storage for backward compatibility
      try {
        final passwordsJson = await _storage.read(key: _passwordsKey);
        if (passwordsJson == null) return [];

        final List<dynamic> passwordsList = jsonDecode(passwordsJson);
        return passwordsList.map((json) => PasswordEntry.fromJson(json)).toList();
      } catch (fallbackError) {
        throw Exception('Failed to load passwords: $e');
      }
    }
  }

  // Save a new password entry
  Future<void> savePassword(PasswordEntry entry) async {
    try {
      final passwords = await getAllPasswords();

      // Check if password with same ID already exists
      final existingIndex = passwords.indexWhere((p) => p.id == entry.id);
      if (existingIndex != -1) {
        passwords[existingIndex] = entry;
      } else {
        passwords.add(entry);
      }

      await _savePasswordsList(passwords);
    } catch (e) {
      throw Exception('Failed to save password: $e');
    }
  }

  // Update an existing password entry
  Future<void> updatePassword(PasswordEntry entry) async {
    try {
      final passwords = await getAllPasswords();
      final index = passwords.indexWhere((p) => p.id == entry.id);

      if (index == -1) {
        throw Exception('Password entry not found');
      }

      passwords[index] = entry;
      await _savePasswordsList(passwords);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // Delete a password entry
  Future<void> deletePassword(String id) async {
    try {
      final passwords = await getAllPasswords();
      passwords.removeWhere((p) => p.id == id);
      await _savePasswordsList(passwords);
    } catch (e) {
      throw Exception('Failed to delete password: $e');
    }
  }

  // Get a specific password entry by ID
  Future<PasswordEntry?> getPasswordById(String id) async {
    try {
      final passwords = await getAllPasswords();
      return passwords.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Password not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Search passwords by title or website
  Future<List<PasswordEntry>> searchPasswords(String query) async {
    try {
      final passwords = await getAllPasswords();
      final lowerQuery = query.toLowerCase();

      return passwords.where((p) {
        return p.title.toLowerCase().contains(lowerQuery) ||
            (p.website?.toLowerCase().contains(lowerQuery) ?? false) ||
            p.username.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search passwords: $e');
    }
  }

  // Set master password for additional security
  Future<void> setMasterPassword(String password) async {
    try {
      // Use secure PBKDF2 hashing
      final hashedPassword = await _hashMasterPasswordPBKDF2(password);
      await _storage.write(key: _masterPasswordKey, value: hashedPassword);
    } catch (e) {
      throw Exception('Failed to set master password: $e');
    }
  }

  // Verify master password with migration support
  Future<bool> verifyMasterPassword(String password) async {
    try {
      final storedHash = await _storage.read(key: _masterPasswordKey);
      if (storedHash == null) return false;

      // Try to parse as JSON (new format)
      try {
        final envelope = jsonDecode(storedHash) as Map<String, dynamic>;
        if (envelope.containsKey('v') && envelope['v'] == 1) {
          // New PBKDF2 format
          return await _verifyMasterPasswordPBKDF2(password, envelope);
        }
      } catch (_) {
        // Not JSON, try legacy format
      }

      // Legacy format verification
      final legacyHash = _hashPasswordLegacy(password);
      if (legacyHash == storedHash) {
        // Migration: upgrade to PBKDF2 on successful legacy verification
        try {
          final newHash = await _hashMasterPasswordPBKDF2(password);
          await _storage.write(key: _masterPasswordKey, value: newHash);
        } catch (e) {
          // Migration failed, but authentication succeeded
          // Log error but don't fail the authentication
        }
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if master password is set
  Future<bool> hasMasterPassword() async {
    try {
      final storedHash = await _storage.read(key: _masterPasswordKey);
      return storedHash != null;
    } catch (e) {
      return false;
    }
  }

  // Clear all stored data (for reset functionality)
  Future<void> clearAllData() async {
    try {
      await _storage.delete(key: _passwordsKey);
      await _storage.delete(key: _masterPasswordKey);
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }

  // Get password count
  Future<int> getPasswordCount() async {
    try {
      final passwords = await getAllPasswords();
      return passwords.length;
    } catch (e) {
      return 0;
    }
  }

  // Private helper methods
  Future<void> _savePasswordsList(List<PasswordEntry> passwords) async {
    final passwordsJson = jsonEncode(
      passwords.map((p) => p.toJson()).toList(),
    );
    await _storage.write(key: _passwordsKey, value: passwordsJson);
  }

  // Legacy hash method for backward compatibility
  String _hashPasswordLegacy(String password) {
    final bytes = utf8.encode(password + 'secureme_salt');
    return base64Encode(bytes);
  }

  // Secure PBKDF2 hash method
  Future<String> _hashMasterPasswordPBKDF2(String password,
      {Uint8List? salt, int iterations = 150000}) async {
    final algorithm = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );

    final actualSalt = salt ?? _generateSalt();
    final secretKey = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: actualSalt,
    );

    final keyBytes = await secretKey.extractBytes();

    // Return JSON envelope with all parameters
    final envelope = {
      'v': 1,
      'algo': 'PBKDF2-HMAC-SHA256',
      'it': iterations,
      'salt': base64Encode(actualSalt),
      'hash': base64Encode(keyBytes),
    };

    return jsonEncode(envelope);
  }

  // Verify PBKDF2 hash
  Future<bool> _verifyMasterPasswordPBKDF2(
      String password, Map<String, dynamic> envelope) async {
    try {
      final iterations = envelope['it'] as int;
      final salt = base64Decode(envelope['salt'] as String);
      final storedHash = base64Decode(envelope['hash'] as String);

      final algorithm = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: iterations,
        bits: 256,
      );

      final secretKey = await algorithm.deriveKey(
        secretKey: SecretKey(utf8.encode(password)),
        nonce: salt,
      );

      final computedHash = await secretKey.extractBytes();

      // Constant-time comparison
      if (computedHash.length != storedHash.length) return false;

      int result = 0;
      for (int i = 0; i < computedHash.length; i++) {
        result |= computedHash[i] ^ storedHash[i];
      }

      return result == 0;
    } catch (e) {
      return false;
    }
  }

  // Generate cryptographically secure random salt
  Uint8List _generateSalt([int length = 16]) {
    return Uint8List.fromList(
        List.generate(length, (_) => SecureRandom.fast.nextInt(256)));
  }

  // Export passwords (for backup functionality)
  Future<String> exportPasswords() async {
    try {
      final passwords = await getAllPasswords();
      return jsonEncode(passwords.map((p) => p.toJson()).toList());
    } catch (e) {
      throw Exception('Failed to export passwords: $e');
    }
  }

  // Import passwords (for restore functionality)
  Future<void> importPasswords(String jsonData) async {
    try {
      final List<dynamic> passwordsList = jsonDecode(jsonData);
      final passwords =
          passwordsList.map((json) => PasswordEntry.fromJson(json)).toList();

      await _savePasswordsList(passwords);
    } catch (e) {
      throw Exception('Failed to import passwords: $e');
    }
  }
}
