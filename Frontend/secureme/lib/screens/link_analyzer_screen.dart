import 'package:flutter/material.dart';
import '../services/link_analyzer_service.dart';
import '../models/link_analysis.dart';
import '../widgets/tic_tac_toe.dart';

class LinkAnalyzerScreen extends StatefulWidget {
  const LinkAnalyzerScreen({super.key});

  @override
  State<LinkAnalyzerScreen> createState() => _LinkAnalyzerScreenState();
}

class _LinkAnalyzerScreenState extends State<LinkAnalyzerScreen> {
  final _urlController = TextEditingController();
  LinkAnalysis? _analysis;
  bool _isLoading = false;
  bool _showGame = false;
  bool _playerFirst = true;
  LinkAnalysis? _pendingAnalysis;

  void _analyzeLink() async {
    if (_urlController.text.isEmpty) return;

    String url = _urlController.text;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
      _urlController.text = url;
    }

    setState(() {
      _isLoading = true;
      _showGame = true;
      _analysis = null;
    });

    try {
      final analysis = await LinkAnalyzerService().analyzeLink(url);

      if (_showGame) {
        setState(() => _pendingAnalysis = analysis);
        _showAnalysisDialog();
      } else {
        setState(() {
          _analysis = analysis;
          _isLoading = false;
          _showGame = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showGame = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showAnalysisDialog() {
    if (_pendingAnalysis == null || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Analysis Complete'),
        content: const Text(
            'Would you like to see the analysis now or finish your game?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _analysis = _pendingAnalysis;
                _showGame = false;
                _isLoading = false;
                _pendingAnalysis = null;
                _playerFirst = !_playerFirst;
              });
            },
            child: const Text('Show Analysis'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Finish Game'),
          ),
        ],
      ),
    );
  }

  void _onGameComplete(bool gameEnded) {
    if (gameEnded && _pendingAnalysis != null && mounted) {
      _showAnalysisDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width > 600 ? 32.0 : 16.0;
    final maxWidth = size.width > 1200 ? 1000.0 : size.width * 0.9;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  Text(
                    'Link Analyzer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width > 600 ? 32 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Container(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: 'Enter link here',
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  SizedBox(
                    width: size.width > 600 ? 300 : double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _analyzeLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isLoading ? 'Analyzing...' : 'Analyze',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width > 600 ? 18 : 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _showGame
                  ? TicTacToe(
                      onGameComplete: _onGameComplete,
                      playerFirst: _playerFirst,
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(padding),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: _buildAnalysisResult(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResult() {
    final analysis = _analysis;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width <= 600;

    if (analysis == null) {
      return Center(
        child: Text(
          'Enter a URL to analyze',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 16 : 20,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Verdict: ${analysis.summary.verdict}',
              style: TextStyle(
                color: _getVerdictColor(analysis.summary.verdict),
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'Security Score: ${analysis.summary.securityScore}',
              style: TextStyle(
                color: _getScoreColor(analysis.summary.securityScore),
                fontSize: isSmallScreen ? 16 : 20,
              ),
            ),
            SizedBox(height: size.height * 0.03),
            if (analysis.issues?.isNotEmpty ?? false) ...[
              Text(
                'Security Issues:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? double.infinity : 800,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    defaultColumnWidth: FixedColumnWidth(
                      isSmallScreen ? size.width * 0.4 : 300,
                    ),
                    border: TableBorder.all(
                      color: Colors.white24,
                      width: 1,
                    ),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                            child: Text(
                              'Engine',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                            child: Text(
                              'Finding',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...(analysis.issues ?? []).map(
                        (issue) => TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                              child: Text(
                                issue.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                              child: Text(
                                issue.result,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getVerdictColor(String verdict) {
    switch (verdict.toLowerCase()) {
      case 'safe':
        return Colors.green;
      case 'suspicious':
        return Colors.orange;
      case 'malicious':
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
