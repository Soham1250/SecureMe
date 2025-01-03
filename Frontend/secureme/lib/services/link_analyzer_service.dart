import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/link_analysis.dart';
import 'api_config.dart';

class LinkAnalyzerService {
  Future<LinkAnalysis> analyzeLink(String url) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.scanUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'url': url}),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return LinkAnalysis.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to analyze link: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error analyzing link: $e');
    }
  }
}
