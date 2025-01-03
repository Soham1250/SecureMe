import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/link_analysis.dart';
import 'api_config.dart';

class LinkAnalyzerService {
  Future<LinkAnalysis> analyzeLink(String url) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.scanUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'url': url}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. Please try again.');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return LinkAnalysis.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['error'] ?? 'Failed to analyze link');
        }
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('Network error. Please check your internet connection.');
      }
      rethrow;
    }
  }
}
