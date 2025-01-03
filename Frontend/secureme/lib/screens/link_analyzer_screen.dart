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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Link Analyzer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'Enter link here',
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _analyzeLink,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  _isLoading ? 'Analyzing...' : 'Analyze',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _showGame
                    ? TicTacToe(
                        onGameComplete: _onGameComplete,
                        playerFirst: _playerFirst,
                      )
                    : _buildAnalysisResult(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisResult() {
    final analysis = _analysis;
    if (analysis == null) {
      return const Center(
        child: Text(
          'Enter a URL to analyze',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Verdict: ${analysis.summary.verdict}',
              style: TextStyle(
                color: _getVerdictColor(analysis.summary.verdict),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Security Score: ${analysis.summary.securityScore}',
              style: TextStyle(
                color: _getScoreColor(analysis.summary.securityScore),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            if (analysis.issues?.isNotEmpty ?? false) ...[
              const Text(
                'Security Issues:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Table(
                border: TableBorder.all(
                  color: Colors.white,
                  width: 1,
                ),
                children: [
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Engine',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Finding',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...(analysis.issues ?? []).map(
                    (issue) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            issue.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            issue.result,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
