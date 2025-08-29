import 'package:flutter/material.dart';
import '../models/link_analysis.dart';
import '../services/link_analyzer_service.dart';
import '../widgets/tic_tac_toe.dart';

class LinkAnalyzerScreen extends StatefulWidget {
  const LinkAnalyzerScreen({super.key});

  @override
  State<LinkAnalyzerScreen> createState() => _LinkAnalyzerScreenState();
}

class _LinkAnalyzerScreenState extends State<LinkAnalyzerScreen> {
  final TextEditingController _urlController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LinkAnalyzerService _linkAnalyzerService = LinkAnalyzerService();
  LinkAnalysis? _analysis;
  bool _isLoading = false;
  bool _showGame = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  Future<void> _analyzeLink() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _analysis = null;
    });

    try {
      String url = _urlController.text.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
        _urlController.text = url;
      }

      final analysis = await _linkAnalyzerService.analyzeLink(url);

      if (mounted) {
        setState(() {
          _analysis = analysis;
          _showGame = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildUrlInput() {
    return TextFormField(
      controller: _urlController,
      decoration: InputDecoration(
        labelText: 'Enter URL to analyze',
        hintText: 'https://example.com',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        prefixIcon: const Icon(Icons.link),
        suffixIcon: _urlController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _urlController.clear();
                  setState(() {});
                },
              )
            : null,
      ),
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.go,
      onFieldSubmitted: (_) => _analyzeLink(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a URL';
        }
        return null;
      },
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _analyzeLink,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Analyze', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildAnalysisResult() {
    if (_analysis == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(top: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _analysis!.summary.verdict.toLowerCase() == 'safe'
                      ? Icons.verified_outlined
                      : Icons.warning_amber_rounded,
                  color: _analysis!.summary.verdict.toLowerCase() == 'safe'
                      ? Colors.green
                      : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Text(
                  'Analysis Result',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('URL', _analysis!.url),
            const Divider(height: 24),
            _buildInfoRow('Status', _analysis!.status),
            const Divider(height: 24),
            _buildInfoRow(
              'Security Score',
              '${_analysis!.summary.securityScore}/100',
              style: TextStyle(
                color: _getScoreColor(_analysis!.summary.securityScore),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _analysis!.summary.securityScore / 100,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getScoreColor(_analysis!.summary.securityScore),
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Verdict',
              _analysis!.summary.verdict,
              style: TextStyle(
                color: _analysis!.summary.verdict.toLowerCase() == 'safe'
                    ? Colors.green
                    : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Engines',
              '${_analysis!.summary.enginesReporting.safe} / ${_analysis!.summary.totalEngines} found it safe',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {IconData? icon, Color? color, TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: color, size: 20),
          if (icon != null) const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: style ??
                  Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: color ?? Theme.of(context).colorScheme.onSurface,
                      ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Analyzer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.gamepad),
            onPressed: () {
              setState(() {
                _showGame = !_showGame;
                _analysis = null;
              });
            },
            tooltip: 'Toggle Game Mode',
          ),
        ],
      ),
      body: _showGame
          ? TicTacToe(
              playerFirst: true,
              onGameComplete: (_) {
                setState(() {
                  _showGame = false;
                });
              },
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUrlInput(),
                    const SizedBox(height: 20),
                    _buildAnalyzeButton(),
                    if (_analysis != null) _buildAnalysisResult(),
                  ],
                ),
              ),
            ),
    );
  }
}
