import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import '../models/password_entry.dart';

class PersistentPasswordStorageService {
  static const String _passwordsFileName = 'secureme_passwords.enc';
  static const String _masterPasswordFileName = 'secureme_master.enc';
  static const String _appFolderName = 'SecureMe';

  // AES-GCM encryption for password data
  final _algorithm = crypto.AesGcm.with256bits();

  // Request storage permissions
  Future<bool> requestStoragePermissions() async {
    try {
      // Check Android version and request appropriate permissions
      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.status;
        if (status.isDenied) {
          final result = await Permission.manageExternalStorage.request();
          if (result.isDenied) {
            // Fallback to legacy storage permissions
            final legacyStatus = await [
              Permission.storage,
              Permission.accessMediaLocation,
            ].request();
            return legacyStatus.values.every((status) => status.isGranted);
          }
          return result.isGranted;
        }
        return status.isGranted;
      }
      return true; // iOS doesn't need explicit storage permissions for app documents
    } catch (e) {
      return false;
    }
  }

  // Get the persistent storage directory
  Future<Directory> _getStorageDirectory() async {
    Directory? directory;

    if (Platform.isAndroid) {
      // Use external storage directory that persists across app installations
      directory = await getExternalStorageDirectory();
      directory ??= await getApplicationDocumentsDirectory();
    } else {
      // iOS - use application documents directory
      directory = await getApplicationDocumentsDirectory();
    }

    // Create SecureMe folder in the storage directory
    final appDirectory = Directory('${directory.path}/$_appFolderName');
    if (!await appDirectory.exists()) {
      await appDirectory.create(recursive: true);
    }

    return appDirectory;
  }

  // Generate encryption key from master password
  Future<crypto.SecretKey> _deriveKeyFromPassword(
      String masterPassword, Uint8List salt) async {
    final pbkdf2 = crypto.Pbkdf2(
      macAlgorithm: crypto.Hmac.sha256(),
      iterations: 150000,
      bits: 256,
    );

    return await pbkdf2.deriveKey(
      secretKey: crypto.SecretKey(utf8.encode(masterPassword)),
      nonce: salt,
    );
  }

  // Generate secure random salt
  Uint8List _generateSalt([int length = 32]) {
    return Uint8List.fromList(
        List.generate(length, (_) => crypto.SecureRandom.fast.nextInt(256)));
  }

  // Encrypt data using AES-GCM
  Future<Map<String, String>> _encryptData(
      String data, String masterPassword) async {
    final salt = _generateSalt();
    final key = await _deriveKeyFromPassword(masterPassword, salt);

    final secretBox = await _algorithm.encrypt(
      utf8.encode(data),
      secretKey: key,
    );

    return {
      'salt': base64Encode(salt),
      'nonce': base64Encode(secretBox.nonce),
      'ciphertext': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
      'version': '1',
    };
  }

  // Decrypt data using AES-GCM
  Future<String> _decryptData(
      Map<String, String> encryptedData, String masterPassword) async {
    final salt = base64Decode(encryptedData['salt']!);
    final nonce = base64Decode(encryptedData['nonce']!);
    final cipherText = base64Decode(encryptedData['ciphertext']!);
    final mac = base64Decode(encryptedData['mac']!);

    final key = await _deriveKeyFromPassword(masterPassword, salt);

    final secretBox = crypto.SecretBox(
      cipherText,
      nonce: nonce,
      mac: crypto.Mac(mac),
    );

    final decryptedBytes = await _algorithm.decrypt(secretBox, secretKey: key);
    return utf8.decode(decryptedBytes);
  }

  // Set master password
  Future<void> setMasterPassword(String password) async {
    try {
      final hasPermission = await requestStoragePermissions();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      final directory = await _getStorageDirectory();
      final masterFile = File('${directory.path}/$_masterPasswordFileName');

      // Create master password hash with salt
      final salt = _generateSalt();
      final hashedPassword =
          await _hashMasterPasswordPBKDF2(password, salt: salt);

      final masterData = {
        'hash': hashedPassword,
        'created': DateTime.now().toIso8601String(),
        'version': '1',
      };

      await masterFile.writeAsString(jsonEncode(masterData));
    } catch (e) {
      throw Exception('Failed to set master password: $e');
    }
  }

  // Verify master password
  Future<bool> verifyMasterPassword(String password) async {
    try {
      final directory = await _getStorageDirectory();
      final masterFile = File('${directory.path}/$_masterPasswordFileName');

      if (!await masterFile.exists()) {
        return false;
      }

      final masterDataJson = await masterFile.readAsString();
      final masterData = jsonDecode(masterDataJson) as Map<String, dynamic>;
      final storedHash = masterData['hash'] as String;

      // Parse the stored hash envelope
      final envelope = jsonDecode(storedHash) as Map<String, dynamic>;
      return await _verifyMasterPasswordPBKDF2(password, envelope);
    } catch (e) {
      return false;
    }
  }

  // Check if master password exists
  Future<bool> hasMasterPassword() async {
    try {
      final directory = await _getStorageDirectory();
      final masterFile = File('${directory.path}/$_masterPasswordFileName');
      return await masterFile.exists();
    } catch (e) {
      return false;
    }
  }

  // Save passwords to encrypted file
  Future<void> savePasswords(
      List<PasswordEntry> passwords, String masterPassword) async {
    try {
      final hasPermission = await requestStoragePermissions();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      final directory = await _getStorageDirectory();
      final passwordsFile = File('${directory.path}/$_passwordsFileName');

      final passwordsJson = jsonEncode(
        passwords.map((p) => p.toJson()).toList(),
      );

      final encryptedData = await _encryptData(passwordsJson, masterPassword);
      await passwordsFile.writeAsString(jsonEncode(encryptedData));
    } catch (e) {
      throw Exception('Failed to save passwords: $e');
    }
  }

  // Load passwords from encrypted file
  Future<List<PasswordEntry>> loadPasswords(String masterPassword) async {
    try {
      final directory = await _getStorageDirectory();
      final passwordsFile = File('${directory.path}/$_passwordsFileName');

      if (!await passwordsFile.exists()) {
        return [];
      }

      final encryptedDataJson = await passwordsFile.readAsString();
      final encryptedData =
          jsonDecode(encryptedDataJson) as Map<String, dynamic>;

      final decryptedJson = await _decryptData(
        encryptedData.cast<String, String>(),
        masterPassword,
      );

      final List<dynamic> passwordsList = jsonDecode(decryptedJson);
      return passwordsList.map((json) => PasswordEntry.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load passwords: $e');
    }
  }

  // Get all passwords (requires master password)
  Future<List<PasswordEntry>> getAllPasswords(String masterPassword) async {
    return await loadPasswords(masterPassword);
  }

  // Save a single password entry
  Future<void> savePassword(PasswordEntry entry, String masterPassword) async {
    final passwords = await loadPasswords(masterPassword);

    final existingIndex = passwords.indexWhere((p) => p.id == entry.id);
    if (existingIndex != -1) {
      passwords[existingIndex] = entry;
    } else {
      passwords.add(entry);
    }

    await savePasswords(passwords, masterPassword);
  }

  // Update password entry
  Future<void> updatePassword(
      PasswordEntry entry, String masterPassword) async {
    final passwords = await loadPasswords(masterPassword);
    final index = passwords.indexWhere((p) => p.id == entry.id);

    if (index == -1) {
      throw Exception('Password entry not found');
    }

    passwords[index] = entry;
    await savePasswords(passwords, masterPassword);
  }

  // Delete password entry
  Future<void> deletePassword(String id, String masterPassword) async {
    final passwords = await loadPasswords(masterPassword);
    passwords.removeWhere((p) => p.id == id);
    await savePasswords(passwords, masterPassword);
  }

  // Search passwords
  Future<List<PasswordEntry>> searchPasswords(
      String query, String masterPassword) async {
    final passwords = await loadPasswords(masterPassword);
    final lowerQuery = query.toLowerCase();

    return passwords.where((p) {
      return p.title.toLowerCase().contains(lowerQuery) ||
          (p.website?.toLowerCase().contains(lowerQuery) ?? false) ||
          p.username.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get password count
  Future<int> getPasswordCount(String masterPassword) async {
    try {
      final passwords = await loadPasswords(masterPassword);
      return passwords.length;
    } catch (e) {
      return 0;
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      final directory = await _getStorageDirectory();
      final passwordsFile = File('${directory.path}/$_passwordsFileName');
      final masterFile = File('${directory.path}/$_masterPasswordFileName');

      if (await passwordsFile.exists()) {
        await passwordsFile.delete();
      }
      if (await masterFile.exists()) {
        await masterFile.delete();
      }
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }

  // Export passwords
  Future<String> exportPasswords(String masterPassword) async {
    final passwords = await loadPasswords(masterPassword);
    return jsonEncode(passwords.map((p) => p.toJson()).toList());
  }

  // Import passwords
  Future<void> importPasswords(String jsonData, String masterPassword) async {
    final List<dynamic> passwordsList = jsonDecode(jsonData);
    final passwords =
        passwordsList.map((json) => PasswordEntry.fromJson(json)).toList();
    await savePasswords(passwords, masterPassword);
  }

  // Check if storage directory exists and is accessible
  Future<bool> isStorageAccessible() async {
    try {
      final hasPermission = await requestStoragePermissions();
      if (!hasPermission) return false;

      final directory = await _getStorageDirectory();
      return await directory.exists();
    } catch (e) {
      return false;
    }
  }

  // Get storage path for user information
  Future<String> getStoragePath() async {
    try {
      final directory = await _getStorageDirectory();
      return directory.path;
    } catch (e) {
      return 'Storage path unavailable';
    }
  }

  // Private helper methods for password hashing
  Future<String> _hashMasterPasswordPBKDF2(String password,
      {Uint8List? salt, int iterations = 150000}) async {
    final algorithm = crypto.Pbkdf2(
      macAlgorithm: crypto.Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );

    final actualSalt = salt ?? _generateSalt(16);
    final secretKey = await algorithm.deriveKey(
      secretKey: crypto.SecretKey(utf8.encode(password)),
      nonce: actualSalt,
    );

    final keyBytes = await secretKey.extractBytes();

    final envelope = {
      'v': 1,
      'algo': 'PBKDF2-HMAC-SHA256',
      'it': iterations,
      'salt': base64Encode(actualSalt),
      'hash': base64Encode(keyBytes),
    };

    return jsonEncode(envelope);
  }

  Future<bool> _verifyMasterPasswordPBKDF2(
      String password, Map<String, dynamic> envelope) async {
    try {
      final iterations = envelope['it'] as int;
      final salt = base64Decode(envelope['salt'] as String);
      final storedHash = base64Decode(envelope['hash'] as String);

      final algorithm = crypto.Pbkdf2(
        macAlgorithm: crypto.Hmac.sha256(),
        iterations: iterations,
        bits: 256,
      );

      final secretKey = await algorithm.deriveKey(
        secretKey: crypto.SecretKey(utf8.encode(password)),
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
}
