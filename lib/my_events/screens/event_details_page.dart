// import 'package:flutter/material.dart';
// import 'package:event_hub_and_navigation_app/models/event.dart'; // Adjust path
// import 'package:event_hub_and_navigation_app/models/session.dart'; // Adjust path
// import 'package:event_hub_and_navigation_app/utils/date_helper.dart'; // Your date utility

// class EventDetailsPage extends StatelessWidget {
//   final Event event;

//   const EventDetailsPage({super.key, required this.event});

//   @override
//   Widget build(BuildContext context) {
//     // Determine the date string format
//     String dateString;
//     if (event.startDateTime.year == event.endDateTime.year &&
//         event.startDateTime.month == event.endDateTime.month &&
//         event.startDateTime.day == event.endDateTime.day) {
//       // Single-day event
//       dateString = DateHelper.formatDate(event.startDateTime); // e.g., "Fri, 21 March 2025"
//     } else {
//       // Multi-day event
//       dateString =
//       '${DateHelper.formatDate(event.startDateTime)} - ${DateHelper.formatDate(event.endDateTime)}';
//     }

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 200.0, // Height of the banner
//             floating: false,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               title: Text(
//                 event.eventName,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 20.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               centerTitle: true,
//               background: Image.network(
//                 // Replace with an actual event banner image URL or asset
//                 'https://via.placeholder.com/400x200/4CAF50/FFFFFF?text=Event+Banner',
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           SliverList(
//             delegate: SliverChildListDelegate(
//               [
//                 // --- About Event / Summary Bar ---
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'About Event',
//                         style: TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         event.description ?? 'No description available.',
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         'Date: $dateString',
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         'Organizer: ${event.organizer}',
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                       if (event.picName != null && event.picContact != null)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 5.0),
//                           child: Text(
//                             'PIC: ${event.picName} (${event.picContact})',
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 const Divider(thickness: 1, height: 30),

//                 // --- Sessions / Schedule Section ---
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Sessions',
//                         style: TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 10),
//                       // Use a ListView.builder if sessions can be very long
//                       // For now, a Column with SessionCard widgets:
//                       if (event.sessions.isEmpty)
//                         const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 10.0),
//                           child: Text('No sessions available for this event.'),
//                         )
//                       else
//                         ...event.sessions.map((session) =>
//                             _buildSessionCard(context, session)).toList(),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20), // Add some space at the bottom
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSessionCard(BuildContext context, Session session) {
//     String sessionTimeString =
//         '${DateHelper.formatTime(session.startDateTime)} - ${DateHelper.formatTime(session.endDateTime)}';

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               session.sessionName,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               'Time: $sessionTimeString',
//               style: TextStyle(fontSize: 15, color: Colors.grey[700]),
//             ),
//             const SizedBox(height: 10),
//             // Venues for this session
//             if (session.venues.isNotEmpty)
//               ...session.venues.map((venue) => Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         'Venue: ${venue.name}',
//                         style: const TextStyle(fontSize: 15),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     TextButton.icon(
//                       onPressed: () {
//                         // Navigate to the navigation page
//                         // Navigator.push(
//                         //   context,
//                         //   MaterialPageRoute(
//                         //     builder: (context) => NavigationPage(
//                         //       destinationNodeId: venue.nodeId,
//                         //       destinationVenueName: venue.name,
//                         //     ),
//                         //   ),
//                         // );
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content: Text(
//                                   'Getting directions to ${venue.name} (Node: ${venue.nodeId})')),
//                         );
//                       },
//                       icon: const Icon(Icons.directions),
//                       label: const Text('Get Directions'),
//                     ),
//                   ],
//                 ),
//               )),
//             if (session.venues.isEmpty)
//               const Text('Venue: Not specified', style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic)),
//           ],
//         ),
//       ),
//     );
//   }
// }