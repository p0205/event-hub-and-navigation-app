

import 'package:event_hub_and_navigation_app/my_events/screens/event_details_page.dart';
import 'package:event_hub_and_navigation_app/my_events/screens/my_events_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../home/screens/home_page.dart';
import '../navigation/screens/navigation_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0; // State to track the selected tab index

  // List of your main pages
  final List<Widget> _pages = [
    const HomePage(),
    const MyEventsPage(),
    const NavigationScreen(),
    // const ProfilePage(),
  ];

  // Callback for when a tab is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    // Define your theme color (dark gold/orange)
    final Color themeColor = Colors.amber[700]!; // Example using a darker amber

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex, // Shows the page at the selected index
        children: _pages, // The list of pages
      ),
      bottomNavigationBar: Container( // No Padding wrapper needed for this effect
        decoration: BoxDecoration(
          color: Colors.white, // Background color of the nav bar itself
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), // Softer shadow color
              spreadRadius: 0, // No spread
              blurRadius: 10, // A good amount of blur for a soft fade
              offset: Offset(0, -5), // Negative Y offset to put shadow *above* the container
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Ensures labels are visible
          currentIndex: _selectedIndex,
          onTap: _onItemTapped, // Call the method to update selected index
          backgroundColor: Colors.transparent, // Make it transparent so the Container's color shows
          elevation: 0, // Remove default shadow of BottomNavigationBar


          selectedItemColor: themeColor, // Active icon color
          unselectedItemColor: Colors.grey[600], // Inactive icon color
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'My Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}