import 'package:flutter/material.dart';
import 'Chatbot.dart';
import 'EventPage1.dart';
import 'SittingPage2.dart'; // Import the dark mode sitting page

class SittingPage extends StatefulWidget {
  const SittingPage({super.key});

  @override
  _SittingPageState createState() => _SittingPageState();
}

class _SittingPageState extends State<SittingPage> {
  final int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatbotPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EventPage1()),
      );
    }
  }

  // Function to handle theme switching
  void _onThemeSwitchTapped() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SittingPage2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E6D0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2E6D0),
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Optional: Add navigation logic if needed
          },
        ),
      ),
      body: ListView(
        children: [
          // Student Profile Section
          _buildSectionCard(
            title: 'STUDENT PROFILE',
            children: [
              _buildProfileRow(Icons.person, 'Full Name', 'Rahaf Al-Shabrawi'),
              _buildProfileRow(Icons.tag, 'Student ID', '2110060'),
              _buildProfileRow(Icons.email, 'Email', 'Raaalshabrawi@dah.edu.sa'),
              _buildProfileRow(Icons.school, 'Major', 'Computer Science'),
              _buildProfileRow(Icons.calendar_today, 'Year of Study', 'Senior'),
            ],
          ),

          // App Settings Section
          _buildSectionCard(
            title: 'APP',
            children: [
              _buildSettingsRow(Icons.language, 'App Language', 'English'),
              // Modify the theme row to be tappable
              GestureDetector(
                onTap: _onThemeSwitchTapped,
                child: _buildSettingsRow(Icons.light_mode, 'Theme', 'Light Mode'),
              ),
              _buildSettingsRow(Icons.notifications, 'Notifications', 'Enable'),
              _buildSettingsRow(Icons.help_outline, 'FAQs', ''),
              _buildSettingsRow(Icons.report_problem, 'Report an Issue', ''),
            ],
          ),

          // About Section
          _buildSectionCard(
            title: 'ABOUT',
            children: [
              _buildSettingsRow(Icons.info_outline, 'About the App', ''),
            ],
          ),
        ],
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
    );
  }

  // The rest of the methods remain the same as in the original file
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 16),
              Text(label),
            ],
          ),
          Row(
            children: [
              if (value.isNotEmpty)
                Text(
                  value,
                  style: const TextStyle(color: Colors.grey),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}