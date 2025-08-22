import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'password_storage_service.dart';

enum AuthMethod {
  biometric,
  masterPassword,
  devicePasscode,
}

class AuthResult {
  final bool success;
  final String? error;
  final AuthMethod? method;

  AuthResult({
    required this.success,
    this.error,
    this.method,
  });
}

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final PasswordStorageService _storageService = PasswordStorageService();

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Authenticate using biometrics
  Future<AuthResult> authenticateWithBiometrics() async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return AuthResult(
          success: false,
          error: 'Biometric authentication is not available on this device',
        );
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your passwords',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        return AuthResult(
          success: true,
          method: AuthMethod.biometric,
        );
      } else {
        return AuthResult(
          success: false,
          error: 'Authentication failed or was cancelled',
        );
      }
    } on PlatformException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'NotAvailable':
          errorMessage = 'Biometric authentication is not available';
          break;
        case 'NotEnrolled':
          errorMessage = 'No biometrics enrolled on this device';
          break;
        case 'LockedOut':
          errorMessage = 'Too many failed attempts. Please try again later';
          break;
        case 'PermanentlyLockedOut':
          errorMessage = 'Biometric authentication is permanently locked';
          break;
        default:
          errorMessage = 'Authentication error: ${e.message}';
      }
      
      return AuthResult(
        success: false,
        error: errorMessage,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Unexpected error during authentication: $e',
      );
    }
  }

  // Authenticate using device passcode/PIN
  Future<AuthResult> authenticateWithDevicePasscode() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please enter your device passcode to access passwords',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        return AuthResult(
          success: true,
          method: AuthMethod.devicePasscode,
        );
      } else {
        return AuthResult(
          success: false,
          error: 'Device passcode authentication failed',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Device passcode authentication error: $e',
      );
    }
  }

  // Authenticate using master password
  Future<AuthResult> authenticateWithMasterPassword(String password) async {
    try {
      final bool isValid = await _storageService.verifyMasterPassword(password);
      
      if (isValid) {
        return AuthResult(
          success: true,
          method: AuthMethod.masterPassword,
        );
      } else {
        return AuthResult(
          success: false,
          error: 'Invalid master password',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Master password verification error: $e',
      );
    }
  }

  // Check if master password is set
  Future<bool> hasMasterPassword() async {
    return await _storageService.hasMasterPassword();
  }

  // Set master password
  Future<bool> setMasterPassword(String password) async {
    try {
      await _storageService.setMasterPassword(password);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get authentication options available to user
  Future<List<AuthMethod>> getAvailableAuthMethods() async {
    final List<AuthMethod> methods = [];

    // Check if biometric is available
    if (await isBiometricAvailable()) {
      methods.add(AuthMethod.biometric);
    }

    // Device passcode is usually available if biometric is available
    if (await isBiometricAvailable()) {
      methods.add(AuthMethod.devicePasscode);
    }

    // Check if master password is set
    if (await hasMasterPassword()) {
      methods.add(AuthMethod.masterPassword);
    }

    return methods;
  }

  // Get user-friendly name for biometric type
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.weak:
        return 'Weak Biometric';
      case BiometricType.strong:
        return 'Strong Biometric';
    }
  }

  // Get authentication method display name
  String getAuthMethodName(AuthMethod method) {
    switch (method) {
      case AuthMethod.biometric:
        return 'Biometric';
      case AuthMethod.masterPassword:
        return 'Master Password';
      case AuthMethod.devicePasscode:
        return 'Device Passcode';
    }
  }

  // Perform authentication with fallback options
  Future<AuthResult> authenticateWithFallback() async {
    // Try biometric first if available
    if (await isBiometricAvailable()) {
      final result = await authenticateWithBiometrics();
      if (result.success) {
        return result;
      }
    }

    // If biometric fails or not available, and master password is set
    if (await hasMasterPassword()) {
      return AuthResult(
        success: false,
        error: 'Please use master password authentication',
      );
    }

    // If no authentication methods available
    return AuthResult(
      success: false,
      error: 'No authentication methods available',
    );
  }

  // Stop authentication (cancel ongoing authentication)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      // Ignore errors when stopping authentication
    }
  }
}
