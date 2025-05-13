import 'package:flutter/material.dart';
import '../Services/database_services.dart';

class QueryScreen extends StatefulWidget {
  const QueryScreen({super.key});
  @override
  _QueryScreenState createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ConsoleLine> _consoleLines = [];
  bool _isExecuting = false;

  static const sqlKeywords = {
    'select', 'from', 'where', 'insert', 'into', 'values', 'update', 'set',
    'delete', 'create', 'table', 'alter', 'drop', 'index', 'view', 'join',
    'inner', 'outer', 'left', 'right', 'group', 'order', 'by', 'having',
    'distinct', 'limit', 'offset', 'as', 'and', 'or', 'not', 'null', 'is',
    'in', 'like', 'between', 'exists', 'case', 'when', 'then', 'else', 'end'
  };

  void _sendQuery() async {
    String query = _controller.text.trim();
    if (query.isEmpty || _isExecuting) return;

    if (query.toLowerCase() == 'clear') {
      setState(() => _consoleLines.clear());
      _controller.clear();
      return;
    }

    setState(() {
      _consoleLines.add(ConsoleLine(text: "SQL> $query", type: LineType.input));
      _isExecuting = true;
    });

    try {
      List<String> result = await DatabaseService.instance.executeQuery(query);
      setState(() {
        _consoleLines.addAll(result.map((line) =>
            ConsoleLine(text: line, type: LineType.output)));
      });
    } catch (e) {
      setState(() {
        _consoleLines.add(ConsoleLine(
            text: "Error: ${e.toString()}", type: LineType.error));
      });
    } finally {
      setState(() => _isExecuting = false);
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            _buildTerminalHeader(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _consoleLines.length,
                  itemBuilder: (context, index) =>
                      _buildConsoleLine(_consoleLines[index]),
                ),
              ),
            ),
            _buildInputSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminalHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderDot(Colors.red),
          const SizedBox(width: 6),
          _buildHeaderDot(Colors.yellow),
          const SizedBox(width: 6),
          _buildHeaderDot(Colors.green),
          const SizedBox(width: 16),
          const Text(
            'SQL Console',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_isExecuting)
            Row(
              children: const [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Executing...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(
          top: BorderSide(color: Colors.grey.shade800, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            'SQL>',
            style: TextStyle(
              color: Colors.greenAccent,
              fontFamily: 'RobotoMono',
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontFamily: 'RobotoMono',
              ),
              cursorColor: Colors.greenAccent,
              decoration: InputDecoration(
                hintText: 'Enter SQL query...',
                hintStyle: TextStyle(
                  color: Colors.greenAccent.withValues(alpha: 0.4),
                  fontFamily: 'RobotoMono',
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 12),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                  BorderSide(color: Colors.greenAccent.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.greenAccent),
                ),
              ),
              onSubmitted: (_) => _sendQuery(),
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ),
          IconButton(
            onPressed: _sendQuery,
            icon: const Icon(Icons.send_rounded),
            color: Colors.greenAccent,
            tooltip: 'Execute (Shift+Enter)',
          ),
        ],
      ),
    );
  }

  Widget _buildConsoleLine(ConsoleLine line) {
    Color textColor;
    switch (line.type) {
      case LineType.input:
        textColor = Colors.greenAccent;
        break;
      case LineType.output:
        textColor = Colors.white70;
        break;
      case LineType.error:
        textColor = Colors.redAccent;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SelectableText.rich(
        _highlightSqlKeywords(line.text, textColor),
        style: const TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 14,
          height: 1.3,
        ),
      ),
    );
  }

  TextSpan _highlightSqlKeywords(String text, Color baseColor) {
    List<TextSpan> spans = [];
    List<String> words = text.split(' ');

    for (String word in words) {
      String lowerWord = word.toLowerCase();
      bool isKeyword = sqlKeywords.contains(lowerWord) ||
          sqlKeywords.contains(lowerWord.replaceAll(RegExp(r'[^a-z]'), ''));

      spans.add(TextSpan(
        text: '$word ',
        style: TextStyle(
          color: isKeyword ? Colors.blueAccent : baseColor,
          fontWeight: isKeyword ? FontWeight.bold : FontWeight.normal,
        ),
      ));
    }

    return TextSpan(children: spans);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

enum LineType { input, output, error }

class ConsoleLine {
  final String text;
  final LineType type;

  ConsoleLine({required this.text, required this.type});
}
