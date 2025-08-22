# SecureMe

A comprehensive cybersecurity mobile application built with Flutter that provides essential security tools for personal digital protection.

## Features

### 🔐 Password Manager
- **Secure Local Storage**: Passwords stored locally using device keystore/keychain
- **Biometric Authentication**: Fingerprint, Face ID, and device passcode support
- **Master Password**: Optional master password for additional security
- **Password Generation**: Secure password generator with strength indicators
- **Password Masking**: Passwords appear as `***` until authenticated
- **Search & Filter**: Easily find passwords with search functionality
- **Copy Protection**: Authentication required for copying passwords

### 🔗 Link Analyzer
- **URL Safety Check**: Analyze links for potential security threats
- **Real-time Scanning**: Instant feedback on link safety
- **Accessibility Service**: Background monitoring of suspicious links

### 🛡️ Security Features
- **Local-First**: All sensitive data stays on your device
- **Encryption**: Industry-standard encryption for stored data
- **Session Management**: Automatic timeout and manual lock functionality
- **Multi-Factor Authentication**: Multiple authentication methods for enhanced security

## Security Architecture

- **Flutter Secure Storage**: Utilizes Android Keystore and iOS Keychain
- **Biometric Integration**: Native platform biometric APIs
- **No Network Transmission**: Passwords never leave your device
- **Encrypted Storage**: All sensitive data encrypted at rest

## Getting Started

### Prerequisites
- Flutter SDK (3.5.3 or higher)
- Android Studio / Xcode for mobile development
- Device with biometric capabilities (recommended)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd secureme
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

### Permissions

The app requires the following permissions:

**Android:**
- `USE_BIOMETRIC` - For fingerprint authentication
- `USE_FINGERPRINT` - For legacy fingerprint support
- `BIND_ACCESSIBILITY_SERVICE` - For link analysis features

**iOS:**
- Biometric authentication permissions handled automatically

## Dependencies

- `flutter_secure_storage: ^9.2.2` - Secure local storage
- `local_auth: ^2.1.8` - Biometric authentication
- `crypto: ^3.0.3` - Cryptographic operations
- `http: ^1.1.0` - Network requests for link analysis

## Project Structure

```
lib/
├── models/
│   ├── password_entry.dart      # Password data model
│   └── link_analysis.dart       # Link analysis model
├── services/
│   ├── auth_service.dart        # Authentication service
│   ├── password_storage_service.dart # Password storage
│   └── link_analysis_service.dart    # Link analysis
├── screens/
│   ├── password_manager_screen.dart  # Password manager UI
│   ├── add_edit_password_screen.dart # Password form
│   └── link_analyzer_screen.dart     # Link analyzer UI
├── widgets/
│   ├── auth_dialog.dart         # Authentication dialog
│   └── ...
└── main.dart                    # App entry point
```

## Usage

### Password Manager
1. Tap "Password Manager" on the home screen
2. Authenticate using biometric or master password
3. Add new passwords using the + button
4. Edit/delete passwords with authentication
5. Search and copy passwords securely

### Link Analyzer
1. Tap "Link Analyzer" on the home screen
2. Paste or type a URL to analyze
3. View safety assessment and recommendations

## Security Best Practices

- **Unique Passwords**: Use different passwords for each account
- **Strong Passwords**: Minimum 12 characters with mixed case, numbers, symbols
- **Regular Updates**: Update passwords periodically
- **Biometric Lock**: Enable biometric authentication when available
- **Master Password**: Use a strong, memorable master password

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the repository.

---

**⚠️ Security Notice**: This app stores all data locally on your device. Ensure your device is secured with a lock screen and keep the app updated for the latest security features.
