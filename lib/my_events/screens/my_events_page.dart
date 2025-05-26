import 'package:event_hub_and_navigation_app/my_events/bloc/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:event_hub_and_navigation_app/auth/bloc/auth_bloc.dart'; // To get userId
import 'package:event_hub_and_navigation_app/models/event.dart'; // Adjust path
import 'package:event_hub_and_navigation_app/utils/date_helper.dart';

import 'event_details_page.dart'; // For date formatting

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late EventBloc _myEventsBloc;
  int? _currentUserId; // To store the userId fetched from AuthBloc
  String _activeTab = 'Upcoming';
  List<Event>? _upcomingEvents;
  List<Event>? _pastEvents;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 tabs
    _myEventsBloc = BlocProvider.of<EventBloc>(context);

    _tabController.addListener(() {
      if (_currentUserId != null) {
        final index = _tabController.index;
        if (index == 0) {
          _activeTab = "Upcoming";
          if (_upcomingEvents == null) {
            _myEventsBloc.add(FetchMyUpcomingEvents(userId: _currentUserId!));
          }
        } else {
          _activeTab = "Past";
          if (_pastEvents == null) {
            _myEventsBloc.add(FetchMyPastEvents(userId: _currentUserId!));
          }
        }
      }
    });
    // Fetch userId from AuthBloc and then dispatch event to MyEventsBloc
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthenticatedState) {
        _currentUserId = authState.user.id;
        if (_currentUserId != null) {
          print("initally   Fetch coming event....");
          print("Loading $_isLoading");
          _myEventsBloc.add(FetchMyUpcomingEvents(userId: _currentUserId!));

          print("Loading $_isLoading");
        } else {
          // Handle case where userId is null despite AuthenticatedState
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User ID not found.')),
          );
        }
      } else {
        // Handle unauthenticated state (e.g., navigate to login)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view your events.')),
        );
        // Navigator.of(context).pushReplacementNamed('/login'); // Example
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    // _myEventsBloc.close(); // Managed by BlocProvider usually
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming Events'),
            Tab(text: 'Past Events'),
          ],
        ),
      ),
      body: BlocListener<EventBloc, EventState>(
          bloc: _myEventsBloc,
          listener: (context, state) {
            print("Enter listener....");
            print("Current state: $state");
            if (state is EventErrorState) {
              _isLoading = false;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is EventLoadingState) {
              _isLoading = true;
            } else if (state is EventLoadedState) {
              if (_activeTab == "Upcoming") {
                _upcomingEvents = state.event;
              } else if (_activeTab == "Past") {
                print("set _pastEvent");
                _pastEvents = state.event;
                print("_pastEvents $_pastEvents");
              }
              _isLoading = false;
              setState(() {});
            }
          },
          child: TabBarView(
            controller: _tabController,
            children: [
              _isLoading || _upcomingEvents == null
                  ? const Center(child: CircularProgressIndicator())
                  : _buildEventList(_upcomingEvents ?? [], 'Upcoming'),
              _isLoading || _pastEvents == null
                  ? const Center(child: CircularProgressIndicator())
                  : _buildEventList(_pastEvents ?? [], 'Past'),
            ],
          )),
    );
  }

  Widget _buildEventList(List<Event> events, String type) {
    bool isPastEvent = (type == 'Past' ) ? true :false;
    if (events.isEmpty) {
      return Center(
        child: Text(
          'No $type events found.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(event: event, isPastEvent:isPastEvent ,); // Use a reusable EventCard widget
      },
    );
  }
}

// Reusable Widget for Event Display
class EventCard extends StatelessWidget {
  final Event event;
  final bool isPastEvent;

  const EventCard({super.key, required this.event, required this.isPastEvent});

  @override
  Widget build(BuildContext context) {
    String dateString;
    if (event.startDateTime.year == event.endDateTime.year &&
        event.startDateTime.month == event.endDateTime.month &&
        event.startDateTime.day == event.endDateTime.day) {
      dateString = DateHelper.formatDate(event.startDateTime);
    } else {
      dateString =
          '${DateHelper.formatDate(event.startDateTime)} - ${DateHelper.formatDate(event.endDateTime)}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      child: InkWell(
        // Use InkWell for tap effect
        onTap: () {

          // Navigate to EventDetailsPage when card is tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsPage(eventId : event.id , isPastEvent: isPastEvent,),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.eventName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Date: $dateString',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
