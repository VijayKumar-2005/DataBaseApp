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
    'inner', 'outer', 'left', 'right', 'group by', 'order by', 'having',
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

    if (query.toLowerCase() == 'exit') {
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
        _consoleLines.addAll(result.map((line) => ConsoleLine(text: line, type: LineType.output)));
      });
    } catch (e) {
      setState(() {
        _consoleLines.add(ConsoleLine(text: "Error: ${e.toString()}", type: LineType.error));
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
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildTerminalHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Row(
            children: [
              _buildHeaderDot(Colors.red),
              _buildHeaderDot(Colors.yellow),
              _buildHeaderDot(Colors.green),
            ],
          ),
          SizedBox(width: 16),
          Text(
            'SQL Console',
            style: TextStyle(
              fontSize: 25,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          if (_isExecuting)
            Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.greenAccent),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Executing...',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 12),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderDot(Color color) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildConsoleLine(ConsoleLine line) {
    Color textColor;
    switch (line.type) {
      case LineType.input:
        textColor = Colors.greenAccent[400]!; // Green for input
        break;
      case LineType.output:
        textColor = Colors.white70; // White for output
        break;
      case LineType.error:
        textColor = Colors.redAccent; // Red for errors
        break;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: SelectableText.rich(
        _highlightSqlKeywords(line.text, textColor),
        style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            _buildTerminalHeader(),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _consoleLines.length,
                  itemBuilder: (context, index) => _buildConsoleLine(_consoleLines[index]),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'SQL>',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'RobotoMono',
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'RobotoMono',
                      ),
                      cursorColor: Colors.greenAccent,
                      decoration: InputDecoration(
                        hintText: 'Enter SQL query . . . . .  ',
                        hintStyle: TextStyle(color: Colors.greenAccent.withValues(alpha: 0.5)),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendQuery(),
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                  ),
                  IconButton(
                    onPressed: _sendQuery,
                    icon: Icon(Icons.send_rounded),
                    color: Colors.greenAccent,
                    tooltip: 'Execute (Shift+Enter)',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum LineType { input, output, error }

class ConsoleLine {
  final String text;
  final LineType type;

  ConsoleLine({required this.text, required this.type});
}
