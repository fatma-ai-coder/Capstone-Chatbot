import 'package:flutter/material.dart';
import 'SittingPage2.dart';
import 'EventPage2.dart';
import 'package:intl/intl.dart';
import 'dart:math';

void main() {
  runApp(const ChatbotPage2());
}

class ChatbotPage2 extends StatelessWidget {
  const ChatbotPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2E1D1D),
        scaffoldBackgroundColor: const Color(0xFF2E1D1D),
        fontFamily: 'Roboto',
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  
  // Conversations storage
  final List<Map<String, dynamic>> _conversations = [];
  
  int _selectedIndex = 0;
  String? _currentConversationId;
  String _currentTitle = 'Ask Dah';

  @override
  void initState() {
    super.initState();
    // Initialize with the first bot message
    _messages = [
      {
        'text':
          'Ask Dah is an AI-powered chatbot developed as part of a capstone project at Dar Al-Hekma University. It provides quick answers, guides users through university resources, and offers academic assistance.',
        'sender': 'bot',
        'timestamp': DateTime.now(),
      }
    ];
  }

  // Generate a unique conversation ID
  String _generateConversationId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }

  // Handle bottom navigation taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EventPage2()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SittingPage2()),
      );
    }
  }

  // Simulate bot responses
  void _handleBotResponse(String userMessage) {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'text': 'Thanks for your question! I am here to help. 😊',
          'sender': 'bot',
          'timestamp': DateTime.now(),
        });
      });
    });
  }

  // Handle user message
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _controller.text,
          'sender': 'user',
          'timestamp': DateTime.now(),
        });
      });
      _handleBotResponse(_controller.text);
      _controller.clear();
    }
  }

  // Save current conversation
  void _saveCurrentConversation() {
    // Skip saving if there are no meaningful messages (only initial bot message)
    if (_messages.length > 1) {
      // If no current conversation ID, generate one
      _currentConversationId ??= _generateConversationId();

      // Check if conversation already exists
      final existingIndex = _conversations.indexWhere(
        (conv) => conv['id'] == _currentConversationId
      );

      final conversation = {
        'id': _currentConversationId,
        'messages': List.from(_messages),
        'timestamp': DateTime.now(),
      };

      if (existingIndex != -1) {
        // Update existing conversation
        _conversations[existingIndex] = conversation;
      } else {
        // Add new conversation
        _conversations.insert(0, conversation);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conversation saved')),
      );
    }
  }

  // Restore a saved conversation
  void _restoreConversation(Map<String, dynamic> conversation) {
    setState(() {
      _messages = List.from(conversation['messages']);
      _currentConversationId = conversation['id'];
      
      // Find the first user message to use as the title
      final firstUserMessage = _messages.firstWhere(
        (message) => message['sender'] == 'user', 
        orElse: () => {'text': 'Ask Dah'}
      );
      
      // Set the title to the first user message (truncate if too long)
      _currentTitle = firstUserMessage['text'].length > 30
        ? '${firstUserMessage['text'].substring(0, 30)}...'
        : firstUserMessage['text'];
    });
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E1D1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E1D1D),
        elevation: 0,
        title: Text(
          _currentTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveCurrentConversation,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Create a new conversation
              _saveCurrentConversation();
              setState(() {
                _messages = [
                  {
                    'text':
                        'Ask Dah is an AI-powered chatbot developed as part of a capstone project at Dar Al-Hekma University. It provides quick answers, guides users through university resources, and offers academic assistance.',
                    'sender': 'bot',
                    'timestamp': DateTime.now(),
                  }
                ];
                _currentConversationId = null;
                _currentTitle = 'Ask Dah';  // Reset to default title
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF2E1D1D),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF3D2C2C),
                ),
                child: Text(
                  'Chats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              ..._buildConversationList(),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF6E5F5F)
                          : const Color(0xFFAB564D),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message['text']!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3D2C2C),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask me what you want',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1414),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }

  // Build the conversation list for the drawer
  List<Widget> _buildConversationList() {
    // If no conversations exist, show a helpful message
    if (_conversations.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Your saved conversations will appear here. Start chatting and save your conversations to see them in this list.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        )
      ];
    }

    // Existing code for building conversation list when conversations exist
    return _conversations.map((conversation) {
      // Get the first message or a preview of the conversation
      final firstMessage = conversation['messages'][1] ?? conversation['messages'][0];
      
      return ListTile(
        title: Text(
          firstMessage['text'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          DateFormat('MMMM dd, HH:mm').format(conversation['timestamp']),
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            setState(() {
              _conversations.remove(conversation);
            });
          },
        ),
        onTap: () {
          // Restore the selected conversation and continue
          _restoreConversation(conversation);
        },
      );
    }).toList();
  }
}