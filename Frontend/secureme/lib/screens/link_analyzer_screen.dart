import 'package:flutter/material.dart';
import '../models/link_analysis.dart';
import '../services/link_analyzer_service.dart';

class LinkAnalyzerScreen extends StatefulWidget {
  const LinkAnalyzerScreen({super.key});

  @override
  State<LinkAnalyzerScreen> createState() => _LinkAnalyzerScreenState();
}

class _LinkAnalyzerScreenState extends State<LinkAnalyzerScreen> {
  final _linkController = TextEditingController();
  final _service = LinkAnalyzerService();
  bool _isLoading = false;
  LinkAnalysis? _result;
  String? _error;

  Future<void> _analyzeLink() async {
    var link = _linkController.text.trim();
    if (link.isEmpty) {
      setState(() => _error = 'Please enter a link');
      return;
    }

    // Add https:// if no protocol is specified
    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      link = 'https://$link';
      _linkController.text = link;  // Update the text field to show the modified URL
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await _service.analyzeLink(link);
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Analyzer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _linkController,
              decoration: InputDecoration(
                hintText: 'Enter link here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeLink,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Analyze'),
            ),
            const SizedBox(height: 24),
            if (_result != null) _buildResult(_result!),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(LinkAnalysis analysis) {
    final isSafe = analysis.summary.verdict.toLowerCase() == 'safe';
    final color = isSafe ? Colors.green : Colors.red;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Centered verdict section
            Center(
              child: Column(
                children: [
                  Text(
                    'Verdict: ${analysis.summary.verdict}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(
                          value: analysis.summary.securityScore / 100,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${analysis.summary.securityScore}/100',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: color,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (!isSafe && analysis.issues != null) ...[
              Text(
                'Security Issues:',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Centered table with 80% width
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Engine')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Finding')),
                      ],
                      rows: analysis.issues!.map((issue) {
                        final ismalicious = issue.category == 'malicious';
                        final rowColor = ismalicious
                            ? Colors.red.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1);
                        final textColor = ismalicious ? Colors.red : Colors.orange;

                        return DataRow(
                          color: MaterialStateProperty.all(rowColor),
                          cells: [
                            DataCell(Text(issue.name)),
                            DataCell(Text(
                              issue.category,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                            DataCell(Text(issue.result)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }
}
