import 'package:flutter/material.dart';
import 'Chatbot2.dart'; // Import your Chatbot page
import 'SittingPage2.dart'; // Import Sitting page (create it later)
import 'EventDatailPage2.dart';
import 'api_service.dart'; 

void main() {
  runApp(const EventPage2());
}

class EventPage2 extends StatelessWidget {
  const EventPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All";
  String searchQuery = "";
  int _selectedIndex = 1; // Default selected index (calendar icon)

  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      
      final List<dynamic> jsonData = await ApiService.getEvents();
      
      List<Map<String, dynamic>> loadedEvents = [];
      for (var event in jsonData) {
        String dateStr = event['start_date'] ?? '';
        DateTime? date;
        try {
          date = DateTime.parse(dateStr);
        } catch (e) {
          // معالجة تنسيقات التاريخ غير الصالحة
          print('Invalid date format: $dateStr');
        }
        
        String formattedDate = date != null
            ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
            : 'Date not available';

        String displayDate = date != null
            ? '${date.day} ${_getMonthName(date.month)} ${date.year}'
            : 'Date not available';

        Map<String, dynamic> formattedEvent = {
          "image": event['image'] != null && event['image'].isNotEmpty 
              ? ApiService.getImageUrl(event['image']) 
              : "assets/computer science.jpg", 
          "title": event['title'] ?? 'Untitled Event',
          "location": event['location'] ?? 'Unknown Location',
          "date": formattedDate, // التاريخ بصيغة YYYY-MM-DD
          "displayDate": displayDate, // التاريخ بصيغة DD Month YYYY للعرض
          "time": event['time'] ?? 'Time not available', 
          "categories": event['categories'] ?? [],
          "description": event['description'] ?? '',
          "event_id": event['event_id'] ?? '',
          "start_date": event['start_date'] ?? '',
          "end_date": event['end_date'] ?? ''
        };
        
        loadedEvents.add(formattedEvent);
      }
      
      setState(() {
        events = loadedEvents;
      });
    } catch (e) {
      print('Error loading events from API: $e');
      
    }
  }
  
  // Helper method to convert month number to name
  String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }

  // Helper method to format date string from YYYY-MM-DD to a readable format
  String _formatDateString(String dateStr) {
    try {
      if (dateStr.isEmpty) return 'Date not available';
      
      // Parse the date string from format YYYY-MM-DD
      final parts = dateStr.split('-');
      if (parts.length < 3) return dateStr; // Return original if not in expected format
      
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      
      // Create a formatted date string
      return '$day ${_getMonthName(month)} $year';
    } catch (e) {
      print('Error formatting date: $e');
      return dateStr; // Return original in case of error
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatbotPage2()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SittingPage2()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredEvents = selectedCategory == "All"
        ? events.where((event) {
            return event['title']!.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList()
        : events.where((event) {
            // Check if the event has categories and if the selected category is in that list
            List<dynamic> categories = event['categories'] ?? [];
            return categories.contains(selectedCategory) &&
                event['title']!.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF2E1D1D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Hi, User 👋",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Stay Tune!",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const Spacer(),
            const CircleAvatar(
              backgroundImage: AssetImage('assets/Rahaf.jpg'),
              radius: 20,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3D2C2C),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Search events",
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Latest Events",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.favorite, color: Colors.red),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    buildCategoryTab("All"),
                    buildCategoryTab("Volunteer"),
                    buildCategoryTab("Student Council"),
                    buildCategoryTab("Computer Science"),
                    buildCategoryTab("Architecture"),
                    buildCategoryTab("Visual Communication"),
                    buildCategoryTab("Law"),
                    buildCategoryTab("International Relations"),
                    buildCategoryTab("Clubs"),
                    buildCategoryTab("Online"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (filteredEvents.isEmpty)
                const Center(
                  child: Text(
                    "No events found.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ...filteredEvents.map((event) {
                return buildEventCard(
                  event['image'] ?? 'assets/placeholder.jpg',
                  event['title'] ?? 'Untitled Event',
                  event['location'] ?? 'Unknown Location',
                  event['displayDate'] ?? 'Date not available', // Use displayDate instead of date
                  event['time'] ?? 'Time not available',
                  event['description'] ?? 'No description available',
                  event['event_id'] ?? '',
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF1E1414),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }

  Widget buildCategoryTab(String title) {
    bool isSelected = selectedCategory == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFAB564D) : const Color(0xFF3D2C2C),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEventCard(
    String image,
    String title,
    String location,
    String date,
    String time,
    String description,
    String eventId,
  ) {
    // Find the full event from our events list to pass to the detail page
    Map<String, dynamic> fullEvent = {};
    for (var event in events) {
      if (event['event_id'] == eventId) {
        fullEvent = event;
        break;
      }
    }
    
    // If we didn't find the event, create a basic one
    if (fullEvent.isEmpty) {
      fullEvent = {
        "image": image,
        "title": title,
        "location": location,
        "date": date,
        "time": time,
        "description": description,
        "event_id": eventId,
      };
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(event: fullEvent),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF3D2C2C),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  ),
  child: SizedBox(
    height: 180,
    width: double.infinity,
    child: image.startsWith('http')
        ? Image.network(
            image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/computer science.jpg',
                fit: BoxFit.cover,
                height: 180,
                width: double.infinity,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          )
        : Image.asset(
            image,
            fit: BoxFit.cover,
            height: 180,
            width: double.infinity,
          ),
  ),
),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(location, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  // Formatted display for date
                  Text(_formatDateString(date), style: const TextStyle(color: Colors.grey)),
                  // Directly show the time from backend
                  Text(time, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
