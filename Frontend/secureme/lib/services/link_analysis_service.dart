import 'package:flutter/services.dart';

class LinkAnalysisService {
  static const MethodChannel _channel = MethodChannel('com.example.secureme/link_analysis');
  static final LinkAnalysisService _instance = LinkAnalysisService._internal();

  factory LinkAnalysisService() => _instance;

  LinkAnalysisService._internal() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<void> startService() async {
    try {
      await _channel.invokeMethod('startService');
    } on PlatformException catch (e) {
      print('Failed to start service: ${e.message}');
    }
  }

  Future<void> stopService() async {
    try {
      await _channel.invokeMethod('stopService');
    } on PlatformException catch (e) {
      print('Failed to stop service: ${e.message}');
    }
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onLinksFound':
        final List<String> links = List<String>.from(call.arguments);
        await _analyzeLinks(links);
        break;
      case 'startLinkAnalysis':
        // This will be called when the user clicks the notification button
        break;
    }
  }

  Future<void> _analyzeLinks(List<String> links) async {
    // TODO: Implement link analysis using your existing API
    // For each link:
    // 1. Call your API
    // 2. Get the verdict
    // 3. Use platform channel to change link color based on verdict
  }
}
