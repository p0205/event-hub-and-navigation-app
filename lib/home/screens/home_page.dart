import 'package:event_hub_and_navigation_app/my_events/screens/my_events_page.dart';
import 'package:event_hub_and_navigation_app/utils/date_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:event_hub_and_navigation_app/home/bloc/home_bloc.dart';
import 'package:event_hub_and_navigation_app/home/models/calendar_event.dart';

import '../../auth/bloc/auth_bloc.dart'; // Ensure this points to calendar_event_model.dart if that's the name
// import 'package:event_hub_and_navigation_app/utils/date_helper.dart'; // This might not be needed anymore, remove if unused

class HomePage extends StatefulWidget {


  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Use CalendarEventModel as per previous discussion, assuming CalendarEvent is CalendarEventModel
  late final HomeBloc _homeBloc;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Change map key type to DateTime, and value to List<CalendarEvent>
  Map<DateTime, List<CalendarEvent>> _events = {};
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _homeBloc = BlocProvider.of<HomeBloc>(context);

    // Use addPostFrameCallback to ensure context is fully built and
    // BlocProviders are available before attempting to read other blocs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access the AuthBloc here
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthenticatedState) {
        _currentUserId = authState.user.id; // Get the userId from the authenticated user
        print("Logged in userId: $_currentUserId"); // For debugging

        // Now dispatch the event to HomeBloc with the fetched userId
        _homeBloc.add(FetchCalendarEvents(_currentUserId!));
      } else {
        // Handle the case where the user is not authenticated.
        // This usually means navigating them back to the login screen,
        // or showing an error message.
        print("Error: User is not authenticated on HomePage.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are not logged in. Please log in.')),
        );
        // Example: Navigator.of(context).pushReplacementNamed('/login');
      }
    });

    // Initialize _selectedDay to _focusedDay so that events for today are shown by default
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    // Note: If HomeBloc is provided higher up (e.g., in main.dart),
    // it should usually be disposed by the BlocProvider itself.
    // If you explicitly create it here, then disposing it here is correct.
    // _homeBloc.close();
    super.dispose();
  }

  // Normalize the 'day' parameter to midnight for map lookup
  List<CalendarEvent> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    print("_getEventsForDay for $normalizedDay");
    final eventsForSelectedDay = _events[normalizedDay] ?? [];
    print("Events found for $normalizedDay: ${eventsForSelectedDay.length}");
    return eventsForSelectedDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      print("_selectedDay: $_selectedDay");
      print("_focusedDay: $_focusedDay");
    });
    // This will implicitly call _getEventsForDay via eventLoader and ListView.builder
    // after setState.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 245, 197, 66)
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        bloc: _homeBloc,
        listener: (context, state) {
          if (state is CalendarEventLoaded) {
            _events = {}; // Clear map for fresh data
            for (var event in state.events) {
              if (event.startDateTime != null) {
                // Ensure the key is normalized to midnight
                DateTime? dateTime =
                    DateHelper.dateTimeFromString(event.startDateTime);
                final dateKey = DateTime(
                  dateTime!.year,
                  dateTime.month,
                  dateTime.day,
                );
                if (_events[dateKey] == null) {
                  _events[dateKey] = [];
                }
                _events[dateKey]!.add(event);
              }
            }

            print("Events map populated with ${_events.length} entries.");
            if (_events.isNotEmpty) {
              print("_events.entries.first.key: ${_events.entries.first.key}");
              print(
                  "_events.entries.first.value: ${_events.entries.first.value.first.eventName}");
            }

            // Trigger a rebuild of the widget to reflect the updated _events map.
            // This is crucial for TableCalendar and ListView.builder to update.
            setState(() {
              // The _events map has been updated.
            });
          } else if (state is CalendarEventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading events: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: eventCalendar(),
              ),
              const Divider(),
              Expanded(
                child: state is CalendarEventLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state is CalendarEventError
                        ? Center(child: Text(state.message))
                        : _selectedDay ==
                                null // Show events for the selected day or initial focused day
                            ? const Center(
                                child: Text('Select a day to view events'))
                            : ListView.builder(
                                // Ensure _selectedDay is not null before accessing its events
                                itemCount:
                                    _getEventsForDay(_selectedDay!).length,
                                itemBuilder: (context, index) {
                                  final event =
                                      _getEventsForDay(_selectedDay!)[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                          event.eventName ?? 'Unnamed Event'),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (event.sessionName != null)
                                            Text(
                                                'Session: ${event.sessionName}'),
                                          if (event.venueNames != null)
                                            Text('Venue: ${event.venueNames}'),
                                          if (event.startDateTime != null)
                                            // Directly use event.startDateTime, as it's already a DateTime
                                            Text(
                                              'Time: ${ DateHelper.dateTimeFromString(event.startDateTime)!.hour}:${ DateHelper.dateTimeFromString(event.startDateTime)!.minute.toString().padLeft(2, '0')}',
                                            ),
                                        ],
                                      ),
                                      isThreeLine: true,
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MyEventsPage()),

              );
              break;
            case 2:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to Notifications Page')),
              );
              break;
            case 3:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Navigate to Profile/Settings Page')),
              );
              break;
          }
        },
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

  Widget eventCalendar (){
    return TableCalendar<CalendarEvent>(
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.utc(2025, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      headerStyle: HeaderStyle(
            formatButtonVisible: false,
          titleCentered: true
      ),
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      eventLoader: _getEventsForDay,
      // Uses the corrected function
      calendarStyle: const CalendarStyle(
        markersMaxCount: 1,
        markerDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}


