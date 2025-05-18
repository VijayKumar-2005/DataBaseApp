import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../Services/message.dart';
import '../Services/genkit_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.apikey});
  final String apikey;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  late GenkitService _genkitService;
  final ScrollController _scrollController = ScrollController();
  late Box<Message> _chatBox;

  @override
  void initState() {
    super.initState();
    _genkitService = GenkitService(apiKey: widget.apikey);
    _initChat();
  }

  Future<void> _initChat() async {
    _chatBox = Hive.box<Message>('chatBox');
    setState(() {
      _messages.addAll(_chatBox.values);
    });
    if (_messages.isEmpty) {
      _addBotMessage("Hello! I'm your AI SQL assistant. How can I help you? 😊");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _addBotMessage(String text) {
    final msg = Message(text: text, isMe: false, timestamp: DateTime.now());
    setState(() {
      _messages.add(msg);
    });
    if (text != "Thinking...") {
      _chatBox.add(msg);
    }
    _scrollToBottom();
  }


  Future<void> _getBotResponse(String message) async {
    _addBotMessage("Thinking...");
    try {
      final responses = await _genkitService.processUserQuery(message);
      setState(() {
        _messages.removeLast();
        for (final res in responses) {
          final botMsg = Message(text: res, isMe: false, timestamp: DateTime.now());
          _messages.add(botMsg);
          _chatBox.add(botMsg);
        }
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        final errMsg = Message(
          text: "Sorry, an error occurred. Please try again.",
          isMe: false,
          timestamp: DateTime.now(),
        );
        _messages.add(errMsg);
        _chatBox.add(errMsg);
      });
    }
    _scrollToBottom();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    final message = Message(
      text: _messageController.text.trim(),
      isMe: true,
      timestamp: DateTime.now(),
    );
    _messageController.clear();
    setState(() {
      _messages.add(message);
    });
    _chatBox.add(message);
    _scrollToBottom();
    _getBotResponse(message.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('SQL Chatbot'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
        message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe)
            CircleAvatar(
              backgroundColor: Colors.deepPurple.shade800,
              child: const Text("AI", style: TextStyle(color: Colors.white)),
            ),
          if (!message.isMe) const SizedBox(width: 8),
          if (message.isMe) const Spacer(),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isMe
                    ? Colors.deepPurple.shade600
                    : Colors.grey.shade800,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isMe ? 20 : 0),
                  bottomRight: Radius.circular(message.isMe ? 0 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isMe) const SizedBox(width: 8),
          if (message.isMe)
            CircleAvatar(
              backgroundColor: Colors.blue.shade700,
              child: const Icon(Icons.person, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a SQL question...",
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white70),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
  }
}
