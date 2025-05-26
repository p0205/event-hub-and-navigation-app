

import 'package:event_hub_and_navigation_app/my_events/screens/event_details_page.dart';
import 'package:event_hub_and_navigation_app/my_events/screens/my_events_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../home/screens/home_page.dart';

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
    // const NotificationsPage(),
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
    return Scaffold(
      // The AppBar can be here, or each page can have its own AppBar.
      // If shared, title might change based on _selectedIndex.
      // For simplicity, let's keep the AppBars on individual pages for now,
      // as they have different titles and actions.
      body: IndexedStack(
        index: _selectedIndex, // Shows the page at the selected index
        children: _pages,       // The list of pages
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensures labels are visible
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Call the method to update selected index
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
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}