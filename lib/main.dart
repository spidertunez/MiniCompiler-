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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize with empty editor
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
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('State')),
                        DataColumn(label: Text('Input')),
                        DataColumn(label: Text('Stack')),
                        DataColumn(label: Text('Action')),
                        DataColumn(label: Text('Next State')),
                      ],
                      rows: const [
                        DataRow(
                          cells: [
                            DataCell(Text('q0')),
                            DataCell(Text('id')),
                            DataCell(Text('\$')),
                            DataCell(Text('Shift')),
                            DataCell(Text('q1')),
                          ],
                        ),
                        DataRow(
                          cells: [
                            DataCell(Text('q1')),
                            DataCell(Text('=')),
                            DataCell(Text('id\$')),
                            DataCell(Text('Shift')),
                            DataCell(Text('q2')),
                          ],
                        ),
                        DataRow(
                          cells: [
                            DataCell(Text('q2')),
                            DataCell(Text('id')),
                            DataCell(Text('id=\$')),
                            DataCell(Text('Shift')),
                            DataCell(Text('q3')),
                          ],
                        ),
                        DataRow(
                          cells: [
                            DataCell(Text('q3')),
                            DataCell(Text(';')),
                            DataCell(Text('id=id\$')),
                            DataCell(Text('Reduce')),
                            DataCell(Text('q4')),
                          ],
                        ),
                      ],
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
                    ),
                    child: SelectableText(
                      _parserOutput,
                      style: const TextStyle(
                        fontFamily: 'Courier New',
                        fontSize: 14,
                        height: 1.5,
                      ),
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
}
