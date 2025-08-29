import 'package:flutter/foundation.dart';

class AnalyticsProvider with ChangeNotifier {
  int _linksAnalyzed = 0;
  int _passwordCount = 0;

  int get linksAnalyzed => _linksAnalyzed;
  int get passwordCount => _passwordCount;

  void incrementLinksAnalyzed() {
    _linksAnalyzed++;
    notifyListeners();
  }

  void setPasswordCount(int count) {
    _passwordCount = count;
    notifyListeners();
  }

  void incrementPasswordCount() {
    _passwordCount++;
    notifyListeners();
  }

  void decrementPasswordCount() {
    if (_passwordCount > 0) {
      _passwordCount--;
      notifyListeners();
    }
  }

  // Optional: Reset counters if needed
  void resetCounters() {
    _linksAnalyzed = 0;
    _passwordCount = 0;
    notifyListeners();
  }
}
