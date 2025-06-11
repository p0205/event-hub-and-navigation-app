import 'package:event_hub_and_navigation_app/my_events/blocs/my_events_tab_view_bloc/bloc/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:event_hub_and_navigation_app/auth/bloc/auth_bloc.dart'; // To get userId
import 'package:event_hub_and_navigation_app/models/event.dart'; // Adjust path
import 'package:event_hub_and_navigation_app/utils/date_helper.dart';

import '../../widgets/login_reminder_widget.dart';
import '../../event_details/screen/event_details_page.dart'; // For date formatting

class MyEventsTabViewPage extends StatefulWidget {
  final TabController tabController;

  const MyEventsTabViewPage({
    super.key,
    required this.tabController,
  });

  @override
  State<MyEventsTabViewPage> createState() => _MyEventsTabViewPageState();
}

class _MyEventsTabViewPageState extends State<MyEventsTabViewPage>
    with SingleTickerProviderStateMixin {
  late MyEventsTabViewBloc _myEventsBloc;
  int? _currentUserId;
  String _activeTab = 'Upcoming';
  List<Event>? _upcomingEvents;
  List<Event>? _pastEvents;
  bool _isLoading = false;
  bool _isUpcomingEventsLoaded = false;

  bool _isPastEventsLoaded = false;

  // Cache for storing events
  final Map<String, List<Event>> _eventCache = {};

  // Helper method to get cache key
  String _getCacheKey(String type) {
    return '${_currentUserId}_$type';
  }

  // Helper method to check if we have cached events
  bool _hasCachedEvents(String type) {
    return _eventCache.containsKey(_getCacheKey(type));
  }

  // Helper method to get cached events
  List<Event>? _getCachedEvents(String type) {
    return _eventCache[_getCacheKey(type)];
  }

  // Helper method to store events in cache
  void _cacheEvents(String type, List<Event> events) {
    _eventCache[_getCacheKey(type)] = events;
  }

  // Helper method to clear cache
  void _clearCache() {
    _eventCache.clear();
    _upcomingEvents = null;
    _pastEvents = null;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _myEventsBloc = BlocProvider.of<MyEventsTabViewBloc>(context);

    widget.tabController.addListener(() {
      if (_currentUserId != null) {
        final index = widget.tabController.index;
        if (index == 0) {
          _activeTab = "Upcoming";
          if (_upcomingEvents == null) {
            if (_hasCachedEvents("Upcoming")) {
              _upcomingEvents = _getCachedEvents("Upcoming");
              setState(() {});
            } else {
              _myEventsBloc.add(FetchMyUpcomingEvents(userId: _currentUserId!));
            }
          }
        } else {
          _activeTab = "Past";
          if (_pastEvents == null) {
            if (_hasCachedEvents("Past")) {
              _pastEvents = _getCachedEvents("Past");
              setState(() {});
            } else {
              _myEventsBloc.add(FetchMyPastEvents(userId: _currentUserId!));
            }
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
          if (_hasCachedEvents("Upcoming")) {
            _upcomingEvents = _getCachedEvents("Upcoming");
            setState(() {});
          } else {
            _myEventsBloc.add(FetchMyUpcomingEvents(userId: _currentUserId!));
          }
        } else {
          // Handle case where userId is null despite AuthenticatedState
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User ID not found.')),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    // _myEventsBloc.close(); // Managed by BlocProvider usually
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is UnAuthenticatedState) {
          return const LoginReminderWidget();
        }

        return BlocListener<MyEventsTabViewBloc, MyEventsTabViewState>(
          bloc: _myEventsBloc,
          listener: (context, state) {
            print("Enter state listener in tab view... $state");

            if (state is EventErrorState) {
              _isLoading = false;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is EventLoadingState) {
              _isLoading = true;
            } else if (state is UpcomingEventsLoadedState) {
              _upcomingEvents = state.event;
              _cacheEvents("Upcoming", state.event);
              _isLoading = false;
              _isUpcomingEventsLoaded = true;
              setState(() {});
            } else if (state is PastEventsLoadedState) {
              _pastEvents = state.event;
              _cacheEvents("Past", state.event);
              _isLoading = false;
              _isPastEventsLoaded = true;
              setState(() {});
            }
          },
          child: TabBarView(
            controller: widget.tabController,
            children: [
              _isUpcomingEventsLoaded
                  ? _buildEventList(_upcomingEvents ?? [], 'Upcoming')
                  : const Center(child: CircularProgressIndicator()),
              _isPastEventsLoaded
                  ? _buildEventList(_pastEvents ?? [], 'Past')
                  : const Center(child: CircularProgressIndicator())
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventList(List<Event> events, String type) {
    bool shouldShowFeedbackBtn = (type == 'Past') ? true : false;
    if (events.isEmpty) {
      return Center(
        child: Text(
          'No $type events found.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        if (_currentUserId != null) {
          if (type == 'Upcoming') {
            _myEventsBloc.add(FetchMyUpcomingEvents(userId: _currentUserId!));
          } else {
            _myEventsBloc.add(FetchMyPastEvents(userId: _currentUserId!));
          }
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return EventCard(
              event: event, shouldShowFeedbackBtn: shouldShowFeedbackBtn);
        },
      ),
    );
  }
}

// Reusable Widget for Event Display
class EventCard extends StatelessWidget {
  final Event event;
  final bool shouldShowFeedbackBtn;

  const EventCard(
      {super.key, required this.event, required this.shouldShowFeedbackBtn});

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
              builder: (context) => EventDetailsPage(
                eventId: event.id,
                shouldShowFeedbackBtn: shouldShowFeedbackBtn,
              ),
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
