class LinkAnalysis {
  final String url;
  final String analysisId;
  final String status;
  final AnalysisSummary summary;
  final List<SecurityIssue>? issues;
  final DateTime lastAnalysisDate;

  LinkAnalysis({
    required this.url,
    required this.analysisId,
    required this.status,
    required this.summary,
    this.issues,
    required this.lastAnalysisDate,
  });

  factory LinkAnalysis.fromJson(Map<String, dynamic> json) {
    try {
      return LinkAnalysis(
        url: json['url']?.toString() ?? '',
        analysisId: json['analysisId']?.toString() ?? '',
        status: json['status']?.toString() ?? 'unknown',
        summary: AnalysisSummary.fromJson(
          json['summary'] as Map<String, dynamic>? ?? {},
        ),
        issues: json['issues'] is List
            ? (json['issues'] as List)
                .map((e) => SecurityIssue.fromJson(e as Map<String, dynamic>))
                .take(15)
                .toList()
            : null,
        lastAnalysisDate: json['lastAnalysisDate'] != null
            ? DateTime.parse(json['lastAnalysisDate'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error parsing LinkAnalysis: ${e.toString()}');
    }
  }
}

class AnalysisSummary {
  final int securityScore;
  final String verdict;
  final int totalEngines;
  final EngineReports enginesReporting;

  AnalysisSummary({
    required this.securityScore,
    required this.verdict,
    required this.totalEngines,
    required this.enginesReporting,
  });

  factory AnalysisSummary.fromJson(Map<String, dynamic> json) {
    try {
      return AnalysisSummary(
        securityScore: (json['securityScore'] as num?)?.toInt() ?? 0,
        verdict: json['verdict']?.toString() ?? 'unknown',
        totalEngines: (json['totalEngines'] as num?)?.toInt() ?? 0,
        enginesReporting: EngineReports.fromJson(
          json['enginesReporting'] as Map<String, dynamic>? ?? {},
        ),
      );
    } catch (e) {
      throw Exception('Error parsing AnalysisSummary: ${e.toString()}');
    }
  }
}

class EngineReports {
  final int safe;
  final int malicious;
  final int suspicious;
  final int undetected;

  EngineReports({
    required this.safe,
    required this.malicious,
    required this.suspicious,
    required this.undetected,
  });

  factory EngineReports.fromJson(Map<String, dynamic> json) {
    try {
      return EngineReports(
        safe: (json['safe'] as num?)?.toInt() ?? 0,
        malicious: (json['malicious'] as num?)?.toInt() ?? 0,
        suspicious: (json['suspicious'] as num?)?.toInt() ?? 0,
        undetected: (json['undetected'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      throw Exception('Error parsing EngineReports: ${e.toString()}');
    }
  }
}

class SecurityIssue {
  final String name;
  final String category;
  final String result;

  SecurityIssue({
    required this.name,
    required this.category,
    required this.result,
  });

  factory SecurityIssue.fromJson(Map<String, dynamic> json) {
    try {
      return SecurityIssue(
        name: json['engine']?.toString() ?? 'Unknown Engine',
        category: json['category']?.toString() ?? 'unknown',
        result: json['finding']?.toString() ?? 'No details available',
      );
    } catch (e) {
      throw Exception('Error parsing SecurityIssue: ${e.toString()}');
    }
  }
}
