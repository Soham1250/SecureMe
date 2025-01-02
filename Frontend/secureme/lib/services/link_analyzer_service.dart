import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/link_analysis.dart';

class LinkAnalyzerService {
  static const String baseUrl = 'http://localhost:4000'; // Local development URL

  Future<LinkAnalysis> analyzeLink(String url) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/url/scan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return LinkAnalysis.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['error'] ?? 'Analysis failed: No data received');
        }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } on FormatException {
      throw Exception('Invalid response format from server');
    } catch (e) {
      throw Exception('Error analyzing link: ${e.toString()}');
    }
  }
}
