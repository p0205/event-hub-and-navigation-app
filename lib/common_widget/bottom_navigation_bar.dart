import 'package:event_hub_and_navigation_app/my_events/screens/my_events_page.dart';
import 'package:event_hub_and_navigation_app/profile/screens/profile_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home/screens/home_page.dart';
import '../navigation/screens/navigation_screen.dart';
import 'navigation_provider.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final List<Widget> _pages = [
    const HomePage(),
    const MyEventsPage(),
    NavigationScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Handle deep link parameters after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        final int? initialTab = args['initialTab'];
        final String? venue = args['venue'];

        // Switch to the specified tab (Map tab)
        if (initialTab != null) {
          final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
          navigationProvider.setPage(initialTab);

          // You can also pass the venue information to your NavigationScreen here
          // For example, you could store it in a provider or pass it via some other means
          print('Switched to tab $initialTab with venue: $venue');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define your theme color (dark gold/orange)
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final Color themeColor = Colors.amber[700]!;

    return Scaffold(
      body: IndexedStack(
        index: navigationProvider.selectedIndex,
        children: _pages,
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
          currentIndex: navigationProvider.selectedIndex,
          onTap: (index) => navigationProvider.setPage(index),
          backgroundColor: Colors.transparent, // Make it transparent so the Container's color shows
          elevation: 0, // Remove default shadow of BottomNavigationBar

          selectedItemColor: themeColor, // Active icon color
          unselectedItemColor: Colors.grey[600], // Inactive icon color
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'All Events',
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