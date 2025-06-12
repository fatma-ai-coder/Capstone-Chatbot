import 'package:flutter/material.dart';
import 'SittingPage.dart';
import 'EventPage1.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

void main() {
  runApp(const ChatbotPage());
}

class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  
  // Conversations storage
  final List<Map<String, dynamic>> _conversations = [];
  
  int _selectedIndex = 0;
  String? _currentConversationId;
  String _currentTitle = 'Ask Dah';  // Added a variable to store the current title
  // Session ID for memory system
  String? _sessionId;

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
    // Load or generate a session ID
    _loadSessionId();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Load session ID from SharedPreferences or generate a new one
  Future<void> _loadSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _sessionId = prefs.getString('chat_session_id');
        if (_sessionId == null) {
          _sessionId = _generateSessionId();
          prefs.setString('chat_session_id', _sessionId!);
        }
        print('Using session ID: $_sessionId'); // Debug log
      });
    } catch (e) {
      print('Error loading session ID: $e');
      _sessionId = _generateSessionId();
    }
  }

  // Save session ID to SharedPreferences
  Future<void> _saveSessionId(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('chat_session_id', sessionId);
    } catch (e) {
      print('Error saving session ID: $e');
    }
  }

  // Generate a unique conversation ID
  String _generateConversationId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }

  // Generate a unique session ID
  String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(10000).toString();
  }

  // Handle bottom navigation taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EventPage1()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SittingPage()),
      );
    }
  }

  // Handle bot responses
  void _handleBotResponse(String userMessage) async {
    try {
      // Ensure we have a session ID
      if (_sessionId == null) {
        _sessionId = _generateSessionId();
        await _saveSessionId(_sessionId!);
      }
      
      // Use the centralized API service
      final data = await ApiService.sendChatMessage(userMessage, _sessionId);
      
      // Update session ID if returned from server
      if (data['session_id'] != null) {
        _sessionId = data['session_id'];
        await _saveSessionId(_sessionId!);
        print('Updated session ID: $_sessionId'); // Debug log
      }
      
      setState(() {
        _messages.add({
          'text': data['response'] ?? 'Sorry, I could not process your request.',
          'sender': 'bot',
          'timestamp': DateTime.now(),
        });
      });
      
      // Auto-scroll to the bottom when bot responds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'text': 'Sorry, there was an error connecting to the server.',
          'sender': 'bot',
          'timestamp': DateTime.now(),
        });
      });
    }
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
      
      // Auto-scroll to the bottom of the chat
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
        'title': _currentTitle,
        'messages': List.from(_messages),
        'timestamp': DateTime.now(),
        'session_id': _sessionId, // Save session ID with conversation
      };

      setState(() {
        if (existingIndex != -1) {
          // Update existing conversation
          _conversations[existingIndex] = conversation;
        } else {
          // Add new conversation
          _conversations.add(conversation);
        }
      });
    }
  }

  // Restore conversation
  void _restoreConversation(Map<String, dynamic> conversation) {
    setState(() {
      _messages = List.from(conversation['messages']);
      _currentConversationId = conversation['id'];
      _currentTitle = conversation['title'] ?? 'Ask Dah';
      
      // Restore session ID if available
      if (conversation['session_id'] != null) {
        _sessionId = conversation['session_id'];
      }
    });
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
    behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCE7D1),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFCE7D1),
          elevation: 0,
          title: Text(
            _currentTitle,  // Use the dynamic title here
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save, color: Colors.black),
              onPressed: _saveCurrentConversation,
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
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
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFFFCE7D1),
                ),
                child: Text(
                  'Chats',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              ..._buildConversationList(),
            ],
          ),
        ),
        body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isUser = message['sender'] == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.red.shade700 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message['text']!,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black,
                    ),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.add, color: Colors.black),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask me what you want',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
        ),
      ), 
      
      
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
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
          style: const TextStyle(color: Colors.black),
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