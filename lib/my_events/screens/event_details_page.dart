import 'package:flutter/material.dart';
import 'package:event_hub_and_navigation_app/models/event.dart';
import 'package:event_hub_and_navigation_app/models/session.dart';
import 'package:event_hub_and_navigation_app/utils/date_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/event_bloc.dart';

class EventDetailsPage extends StatefulWidget {
  final int eventId;

  const EventDetailsPage({super.key, required this.eventId});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late EventBloc _eventBloc;

  @override
  void initState() {
    super.initState();
    _eventBloc = BlocProvider.of<EventBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthenticatedState) {
        _eventBloc.add(FetchEventDetails(eventId: widget.eventId));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view your events.')),
        );
        // Optionally: redirect to login
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      bloc: _eventBloc,
      builder: (context, state) {
        if (state is EventDetailsLoadedState) {
          final event = state.event;
          // final titleHeight = _calculateToolbarHeight(event.eventName);

          return Scaffold(
            appBar: AppBar(
              title: Text(
                event.eventName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
              centerTitle: true,
              backgroundColor: const Color.fromARGB(255, 245, 197, 66),
              toolbarHeight: 70,
            ),
            body: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('About Event',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(
                            event.description ?? 'No description available.',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Date: ${DateHelper.formatDate(event.startDateTime)} - ${DateHelper.formatDate(event.endDateTime)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text('Organizer: ${event.organizer}',
                              style: const TextStyle(fontSize: 16)),
                          if (event.picName != null && event.picContact != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                'PIC: ${event.picName} (${event.picContact})',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1, height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sessions',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          if (event.sessions!.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Text('No sessions available for this event.'),
                            )
                          else
                            ...event.sessions!.map((session) => _buildSessionCard(context, session)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ]),
                ),
              ],
            ),
          );
        } else if (state is EventErrorState) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Event Details'),
            ),
            body: Center(child: Text(state.message)),
          );
        } else if (state is EventDetailsLoadingState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text('No event data available.')),
          );
        }
      },
    );
  }

  Widget _buildSessionCard(BuildContext context, Session session) {
    String sessionTimeString =
        '${DateHelper.formatDate(session.startDateTime)} - ${DateHelper.formatDate(session.endDateTime)}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: [
                Text(
                  session.sessionName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 5),

            Text(
              'Time: $sessionTimeString',
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            if (session.venues!.isNotEmpty)
              ...session.venues!.map((venue) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Venue: ${venue.name}',
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Getting directions to ${venue.name} (Node: ${venue.nodeId})'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                    ),
                  ],
                ),
              ))

          ],
        ),
      ),
    );
  }


}
