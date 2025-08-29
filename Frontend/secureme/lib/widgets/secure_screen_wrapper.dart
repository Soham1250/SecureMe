import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

/// A widget that prevents screenshots and screen recording
/// 
/// Wrap your app's root widget with this to prevent screenshots and screen recording.
/// Set [enableScreenshot] to true to temporarily allow screenshots (for debugging).
class SecureScreenWrapper extends StatefulWidget {
  /// The child widget to be wrapped with secure screen functionality
  final Widget child;
  
  /// Set to true to allow screenshots (for debugging purposes only)
  final bool enableScreenshot;

  /// Creates a widget that prevents screenshots and screen recording
  const SecureScreenWrapper({
    super.key,
    required this.child,
    this.enableScreenshot = false,
  });

  @override
  State<SecureScreenWrapper> createState() => _SecureScreenWrapperState();
}

class _SecureScreenWrapperState extends State<SecureScreenWrapper> with WidgetsBindingObserver {
  bool _isSecure = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateSecureScreen();
  }

  @override
  void didUpdateWidget(SecureScreenWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enableScreenshot != widget.enableScreenshot) {
      _updateSecureScreen();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setSecureScreen(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateSecureScreen();
    }
  }

  Future<void> _updateSecureScreen() async {
    if (kIsWeb) return;
    
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // On Android, we use FLAG_SECURE to prevent screenshots
        // On iOS, we rely on the native implementation in the platform channel
        await _setSecureScreen(!widget.enableScreenshot);
      }
    } catch (e) {
      // Only log errors in debug mode to avoid exposing sensitive information
      if (kDebugMode) {
        debugPrint('Error updating secure screen: $e');
      }
    }
  }

  Future<void> _setSecureScreen(bool secure) async {
    if (kIsWeb) return;
    if (_isSecure == secure) return;
    
    try {
      const platform = MethodChannel('com.example.secureme/secure_screen');
      await platform.invokeMethod('setSecureScreen', secure);
      
      // Update the secure state
      if (mounted) {
        setState(() {
          _isSecure = secure;
        });
      }
    } catch (e) {
      // Only log errors in debug mode
      if (kDebugMode) {
        debugPrint('Error setting secure screen: $e');
      }
      
      // Re-throw the error in debug mode to help with debugging
      if (kDebugMode) {
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // Make status bar transparent with appropriate icon colors
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
            
        // Style the navigation bar
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
            
        // Ensure the system UI is visible but not intrusive
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
      // Wrap with a Builder to ensure the context is available for inherited widgets
      child: Builder(
        builder: (context) => widget.child,
      ),
    );
  }
}

/// Initializes the secure screen functionality
/// 
/// Call this function in main() before runApp() to ensure secure screen
/// is enabled as early as possible in the app lifecycle.
/// 
/// On Android, this will set FLAG_SECURE on the window to prevent screenshots.
/// On iOS, additional Info.plist configuration is required.
/// 
/// Returns a Future that completes when initialization is done.
Future<void> setupSecureScreen() async {
  // Skip on web as it's not applicable
  if (kIsWeb) return;
  
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      // Use the platform channel to set the secure flag
      const platform = MethodChannel('com.example.secureme/secure_screen');
      await platform.invokeMethod('setSecureScreen', true);
      
      if (kDebugMode) {
        debugPrint('Secure screen initialized');
      }
    }
  } catch (e) {
    // Only log errors in debug mode
    if (kDebugMode) {
      debugPrint('Error initializing secure screen: $e');
    }
    
    // Re-throw in debug mode to help with debugging
    if (kDebugMode) {
      rethrow;
    }
  }
}
