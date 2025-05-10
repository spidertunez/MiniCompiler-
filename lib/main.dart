// lib/main.dart
import 'package:flutter/material.dart';
import 'package:untitled9/parser.dart';
import 'package:untitled9/token.dart';

import 'Scanner.dart';

void main() {
  runApp(const CompilerApp());
}

class CompilerApp extends StatelessWidget {
  const CompilerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compiler Project',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Cairo',
        useMaterial3: true,
      ),
      home: const CompilerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CompilerScreen extends StatefulWidget {
  const CompilerScreen({super.key});

  @override
  State<CompilerScreen> createState() => _CompilerScreenState();
}

class _CompilerScreenState extends State<CompilerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final List<Token> _tokens = [];
  String _parserOutput = '';
  bool _isParsingSuccessful = false;
  List<Map<String, dynamic>> _transitionTable = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _codeController.text = '';
  }

  @override
  void dispose() {
    _codeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _runCompiler() {
    try {
      // Phase 1: Scanning
      final scanner = Scanner(_codeController.text);
      final tokens = scanner.scanTokens();

      // Phase 2: Parsing
      final parser = Parser(tokens);
      final isSuccessful = parser.parse();

      setState(() {
        _tokens.clear();
        _tokens.addAll(tokens);
        _isParsingSuccessful = isSuccessful;
        _parserOutput = parser.getOutput();
        _transitionTable = parser.getTransitionTable();
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSuccessful
                ? 'Code analysis successful'
                : 'Code analysis failed, check errors',
          ),
          backgroundColor: isSuccessful ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _parserOutput = 'Error: $e';
        _isParsingSuccessful = false;
        _transitionTable = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compiler Project - Lexical and Syntax Analyzer'),
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.code), text: 'Editor'),
            Tab(icon: Icon(Icons.analytics), text: 'Results'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Code Editor Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: TextField(
                        controller: _codeController,
                        maxLines: null,
                        expands: true,
                        decoration: InputDecoration(
                          hintText: 'Enter code here...',
                          contentPadding: const EdgeInsets.all(16.0),
                          border: InputBorder.none,
                          fillColor: Colors.grey.shade50,
                          filled: true,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _runCompiler,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Analyze Code',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          // Results Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          _isParsingSuccessful
                              ? Icons.check_circle
                              : Icons.error,
                          color:
                              _isParsingSuccessful ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Analysis Result: ${_isParsingSuccessful ? 'Success' : 'Failed'}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                _isParsingSuccessful
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tokens Section
                _buildSectionHeader('Lexical Analysis (Tokens)', Icons.token),
                Card(
                  elevation: 2,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child:
                        _tokens.isEmpty
                            ? const Center(
                              child: Text(
                                'No tokens analyzed yet',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            )
                            : ListView.separated(
                              itemCount: _tokens.length,
                              separatorBuilder:
                                  (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final token = _tokens[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1),
                                    child: Text('${index + 1}'),
                                  ),
                                  title: Text(
                                    '${token.type}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text('Value: ${token.lexeme}'),
                                  trailing: Chip(
                                    label: Text('Line: ${token.line}'),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1),
                                  ),
                                );
                              },
                            ),
                  ),
                ),
                const SizedBox(height: 24),

                // Transition Table Section
                _buildSectionHeader('Transition Table', Icons.table_chart),
                Card(
                  elevation: 2,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerTheme: const DividerThemeData(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                      ),
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                        dataRowColor: MaterialStateProperty.all(Colors.white),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'State',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Input',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Stack',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Action',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Next State',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                        rows:
                            _transitionTable.isEmpty
                                ? [
                                  DataRow(
                                    cells: [
                                      DataCell(
                                        const Text(
                                          'No transitions yet',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                      const DataCell(Text('')),
                                      const DataCell(Text('')),
                                      const DataCell(Text('')),
                                      const DataCell(Text('')),
                                    ],
                                  ),
                                ]
                                : _transitionTable.map((transition) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(transition['state'])),
                                      DataCell(Text(transition['input'])),
                                      DataCell(Text(transition['stack'])),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                transition['action'] == 'SHIFT'
                                                    ? Colors.blue.withOpacity(
                                                      0.1,
                                                    )
                                                    : transition['action'] ==
                                                        'REDUCE'
                                                    ? Colors.green.withOpacity(
                                                      0.1,
                                                    )
                                                    : Colors.orange.withOpacity(
                                                      0.1,
                                                    ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            transition['action'],
                                            style: TextStyle(
                                              color:
                                                  transition['action'] ==
                                                          'SHIFT'
                                                      ? Colors.blue
                                                      : transition['action'] ==
                                                          'REDUCE'
                                                      ? Colors.green
                                                      : Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(transition['nextState'])),
                                    ],
                                  );
                                }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Parser Output Section
                _buildSectionHeader(
                  'Syntax Analysis (Parser)',
                  Icons.account_tree,
                ),
                Card(
                  elevation: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_parserOutput.isEmpty)
                          const Center(
                            child: Text(
                              'No syntax analysis performed yet',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        else
                          SelectableText.rich(
                            TextSpan(
                              children: _formatParserOutput(_parserOutput),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Courier New',
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _formatParserOutput(String output) {
    List<TextSpan> spans = [];
    List<String> lines = output.split('\n');

    for (String line in lines) {
      if (line.isEmpty) {
        spans.add(const TextSpan(text: '\n'));
        continue;
      }

      if (line.startsWith('Error:')) {
        spans.add(
          TextSpan(
            text: '$line\n',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (line.contains('->')) {
        // Grammar rule
        List<String> parts = line.split('->');
        spans.add(
          TextSpan(
            text: parts[0].trim(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: ' -> ',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: '${parts[1].trim()}\n',
            style: const TextStyle(color: Colors.black87),
          ),
        );
      } else if (line.startsWith('Found')) {
        // Found tokens or operators
        spans.add(
          TextSpan(
            text: '$line\n',
            style: const TextStyle(
              color: Colors.blue,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      } else if (line.contains('successfully')) {
        // Success messages
        spans.add(
          TextSpan(
            text: '$line\n',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        // Regular output
        spans.add(
          TextSpan(
            text: '$line\n',
            style: const TextStyle(color: Colors.black87),
          ),
        );
      }
    }

    return spans;
  }
}
