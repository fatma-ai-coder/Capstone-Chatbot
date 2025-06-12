import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  
  static const String baseUrl = 'http://172.20.10.3:5555'; // 10.0.2.2 Android Emulator
  //localhost:5555 iOS
  //localhost5000 windows

  // function to get events
  static Future<List<dynamic>> getEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/events'));

      if (response.statusCode == 200) {
        // Parsing the JSON response
        return json.decode(response.body);
      } else {
        // 
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching events: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }
  // Function to get the full URL of an image
  // This function constructs the full URL for an image based on its name
  static String getImageUrl(String imageName) {
    return '$baseUrl/api/events/images/$imageName';
  }
  // Function to send a chat message
  static Future<Map<String, dynamic>> sendChatMessage(String message, String? sessionId) async {
    try {
      print('Sending request with session ID: $sessionId'); // Debug log
      
      // Only send the current message and session ID
      // The backend will retrieve the history based on session_id
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': message,
          'session_id': sessionId,
          // Don't send conversation_history - let the backend retrieve it
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to get chat response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending chat message: $e');
      throw Exception('Failed to connect to chat server: $e');
    }
  }
}
