
// --- Reusable Widget for Event Card ---
import 'package:flutter/material.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          // // Navigate to Event Detail Page when card is tapped
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => EventDetailPage(event: event),
          //   ),
          // );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        // '${DateFormat('MMM dd').format(event.startDate)} - ${DateFormat('MMM dd, yyyy').format(event.endDate)}',
                        "date",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
              
                  Align(
                    alignment: Alignment.bottomRight,
                    child: event.isRegistered
                        ? const Chip(
                      label: Text('Registered', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green,
                    )
                        : ElevatedButton(
                      onPressed: () {
                        // TODO: Implement registration logic
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Registering for ${event.name}...')));
                      },
                      child: const Text('Register'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}