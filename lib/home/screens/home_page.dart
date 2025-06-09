import 'package:event_hub_and_navigation_app/utils/date_helper.dart';
import 'package:event_hub_and_navigation_app/widgets/login_reminder_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:event_hub_and_navigation_app/home/bloc/home_bloc.dart';
import 'package:event_hub_and_navigation_app/home/models/calendar_event.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../my_events/screens/event_details_page.dart'; // Ensure this points to calendar_event_model.dart if that's the name
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
        // For debugging

        // Now dispatch the event to HomeBloc with the fetched userId
        _homeBloc.add(FetchCalendarEvents(_currentUserId!));
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
    final eventsForSelectedDay = _events[normalizedDay] ?? [];
    return eventsForSelectedDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    // This will implicitly call _getEventsForDay via eventLoader and ListView.builder
    // after setState.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is UnAuthenticatedState) {
            return const LoginReminderWidget();
          }
          
          return BlocConsumer<HomeBloc, HomeState>(
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

                if (_events.isNotEmpty) {
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
                                      return InkWell(
                                        onTap: () {

                                          // Navigate to EventDetailsPage when card is tapped
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EventDetailsPage(eventId : event.eventId! , shouldShowFeedbackBtn: false),
                                            ),
                                          );
                                        },
                                        child: Card(
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
                                        ),
                                      );
                                    },
                                  ),
                  ),
                ],
              );
            },
          );
        },
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   currentIndex: 0,
      //   onTap: (index) {
      //     switch (index) {
      //       case 0:
      //         break;
      //       case 1:
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //               builder: (context) => MyEventsPage()),
      //
      //         );
      //         break;
      //       case 2:
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           const SnackBar(content: Text('Navigate to Notifications Page')),
      //         );
      //         break;
      //       case 3:
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           const SnackBar(
      //               content: Text('Navigate to Profile/Settings Page')),
      //         );
      //         break;
      //     }
      //   },
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.event),
      //       label: 'My Events',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.notifications),
      //       label: 'Notifications',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      // ),
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


