import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/password_entry.dart';

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

  // Get all stored passwords
  Future<List<PasswordEntry>> getAllPasswords() async {
    try {
      final passwordsJson = await _storage.read(key: _passwordsKey);
      if (passwordsJson == null) return [];

      final List<dynamic> passwordsList = jsonDecode(passwordsJson);
      return passwordsList
          .map((json) => PasswordEntry.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load passwords: $e');
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
      // Hash the password before storing
      final hashedPassword = _hashPassword(password);
      await _storage.write(key: _masterPasswordKey, value: hashedPassword);
    } catch (e) {
      throw Exception('Failed to set master password: $e');
    }
  }

  // Verify master password
  Future<bool> verifyMasterPassword(String password) async {
    try {
      final storedHash = await _storage.read(key: _masterPasswordKey);
      if (storedHash == null) return false;
      
      final hashedInput = _hashPassword(password);
      return hashedInput == storedHash;
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

  String _hashPassword(String password) {
    // Simple hash for demonstration - in production, use bcrypt or similar
    final bytes = utf8.encode(password + 'secureme_salt');
    return base64Encode(bytes);
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
      final passwords = passwordsList
          .map((json) => PasswordEntry.fromJson(json))
          .toList();
      
      await _savePasswordsList(passwords);
    } catch (e) {
      throw Exception('Failed to import passwords: $e');
    }
  }
}
