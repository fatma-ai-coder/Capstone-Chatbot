import 'package:flutter/material.dart';
import 'Chatbot2.dart';
import 'EventPage2.dart';
import 'SittingPage.dart'; // Import the light mode sitting page

class SittingPage2 extends StatefulWidget {
  const SittingPage2({super.key});

  @override
  _SittingPageState createState() => _SittingPageState();
}

class _SittingPageState extends State<SittingPage2> {
  final int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatbotPage2()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EventPage2()),
      );
    }
  }

  // Function to handle theme switching
  void _onThemeSwitchTapped() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SittingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E1D1D), // Dark brown background
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E1D1D),
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              _buildProfileRow(Icons.person, 'Full Name', 'Rahaf AlShabrawi'),
              _buildProfileRow(Icons.tag, 'Student ID', '21103060'),
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
                child: _buildSettingsRow(Icons.dark_mode, 'Theme', 'Dark Mode'),
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
        backgroundColor: const Color(0xFF4A2B2A),
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

  // The rest of the methods remain the same as in the original file
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: const Color(0xFF5C3A3A), // Slightly lighter brown for cards
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
                  color: Colors.white70,
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
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white70,
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
              Icon(icon, color: Colors.white70),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          Row(
            children: [
              if (value.isNotEmpty)
                Text(
                  value,
                  style: const TextStyle(color: Colors.white70),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ],
      ),
    );
  }
}