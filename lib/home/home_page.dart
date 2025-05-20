// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// import '../common_widget/event_card.dart';
// import '../models/event.dart';
// import 'calendar.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
// // Dummy Data - Replace with actual data fetching later
//   final List<Event> _upcomingEvents = [
//     Event(
//       id: 'e1',
//       name: 'FTMK Tech Talk 2025',
//       description:
//           'A series of insightful talks on cutting-edge technology and IT innovations.',
//       startDate: DateTime(2025, 5, 25),
//       endDate: DateTime(2025, 5, 25),
//       isRegistered: false,
//     ),
//     Event(
//       id: 'e2',
//       name: 'Student Innovation Showcase',
//       description:
//           'Witness the incredible projects developed by FTMK students.',
//       startDate: DateTime(2025, 6, 10),
//       endDate: DateTime(2025, 6, 10),
//       isRegistered: true, // Example: User is already registered for this
//     ),
//     Event(
//       id: 'e3',
//       name: 'Career Fair 2025',
//       description:
//           'Connect with leading tech companies for internship and job opportunities.',
//       startDate: DateTime(2025, 7, 5),
//       endDate: DateTime(2025, 7, 6),
//       isRegistered: false,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Event Hub'), // App name at the top
//         centerTitle: false, // Align title to start
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search), // Search icon
//             onPressed: () {
// // TODO: Implement search functionality
//               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                   content: Text('Search functionality coming soon!')));
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.filter_list), // Filter icon
//             onPressed: () {
// // TODO: Implement filter functionality
//               ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Filter options coming soon!')));
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               EventCalendar(),
// // --- Featured Events Carousel (Optional) ---
// // If you want a carousel for featured events, uncomment and build it here.
// // Example:
// // const Text(
// //   'Featured Events',
// //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// // ),
// // const SizedBox(height: 10),
// // Container(
// //   height: 180, // Adjust height as needed
// //   child: ListView.builder(
// //     scrollDirection: Axis.horizontal,
// //     itemCount: _upcomingEvents.length > 2 ? 2 : _upcomingEvents.length, // Show top 2 as featured
// //     itemBuilder: (context, index) {
// //       final event = _upcomingEvents[index];
// //       return Padding(
// //         padding: const EdgeInsets.only(right: 15.0),
// //         child: FeatureEventCard(event: event),
// //       );
// //     },
// //   ),
// // ),
// // const SizedBox(height: 20),

//               const Text(
//                 'Upcoming Events',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 15),
// // --- Upcoming Events List ---
//               ListView.builder(
//                 shrinkWrap: true,
//                 // Important for ListView inside SingleChildScrollView
//                 physics: const NeverScrollableScrollPhysics(),
//                 // Disable ListView's own scrolling
//                 itemCount: _upcomingEvents.length,
//                 itemBuilder: (context, index) {
//                   final event = _upcomingEvents[index];
//                   return EventCard(event: event);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed, // Ensures all items are visible
//         currentIndex: 0, // Highlight 'Home'
//         onTap: (index) {
// // TODO: Implement navigation to other tabs
// // 0: Home (current)
// // 1: My Events
// // 2: Notifications
// // 3: Profile/Settings
//           switch (index) {
//             case 0:
// // Already on Home
//               break;
//             case 1:
// // Navigate to MyEventsPage
//               ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Navigate to My Events Page')));
//               break;
//             case 2:
// // Navigate to NotificationsPage
//               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                   content: Text('Navigate to Notifications Page')));
//               break;
//             case 3:
// // Navigate to ProfileSettingsPage
//               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                   content: Text('Navigate to Profile/Settings Page')));
//               break;
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.event), // Calendar or Event icon
//             label: 'My Events',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.notifications),
//             label: 'Notifications',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }
