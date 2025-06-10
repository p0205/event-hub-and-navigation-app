import 'package:event_hub_and_navigation_app/utils/date_helper.dart';
import 'package:event_hub_and_navigation_app/widgets/login_reminder_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:event_hub_and_navigation_app/home/bloc/home_bloc.dart';
import 'package:event_hub_and_navigation_app/home/models/calendar_event.dart';
import 'package:event_hub_and_navigation_app/common_widgets/calendar.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../my_events/screens/event_details_page.dart'; // Ensure this points to calendar_event_model.dart if that's the name
// import 'package:event_hub_and_navigation_app/utils/date_helper.dart'; // This might not be needed anymore, remove if unused

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeBloc _homeBloc;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<CalendarEvent>> _events = {};
  int? _currentUserId;
  late final EventCalendar _calendar;

  @override
  void initState() {
    super.initState();
    _homeBloc = BlocProvider.of<HomeBloc>(context);
    _selectedDay = _focusedDay;

    // Initialize calendar with helper functions
    _calendar = EventCalendar(
      focusedDay: _focusedDay,
      selectedDay: _selectedDay,
      calendarFormat: _calendarFormat,
      onDaySelected: _onDaySelected,
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      eventLoader: _getEventsForDay,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthenticatedState) {
        _currentUserId = authState.user.id;
        _homeBloc.add(FetchCalendarEvents(_currentUserId!));
      } 
    });
  }

  @override
  void dispose() {
    // Note: If HomeBloc is provided higher up (e.g., in main.dart),
    // it should usually be disposed by the BlocProvider itself.
    // If you explicitly create it here, then disposing it here is correct.
    // _homeBloc.close();
    super.dispose();
  }

  // Use the calendar's helper function for getting events
  List<CalendarEvent> _getEventsForDay(DateTime day) {
    final normalizedDay = EventCalendar.normalizeDate(day);
    return _events[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!mounted) return;
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
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
                _events = {};
                for (var event in state.events) {
                  if (event.startDateTime != null) {
                    DateTime? dateTime = DateHelper.dateTimeFromString(event.startDateTime);
                    final dateKey = EventCalendar.normalizeDate(dateTime!);
                    if (_events[dateKey] == null) {
                      _events[dateKey] = [];
                    }
                    _events[dateKey]!.add(event);
                  }
                }

                setState(() {});
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
                    child: EventCalendar(
                      focusedDay: _focusedDay,
                      selectedDay: _selectedDay,
                      calendarFormat: _calendarFormat,
                      onDaySelected: _onDaySelected,
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      eventLoader: _getEventsForDay,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: state is CalendarEventLoading
                        ? const Center(child: CircularProgressIndicator())
                        : state is CalendarEventError
                            ? Center(child: Text(state.message))
                            : _selectedDay == null
                                ? const Center(
                                    child: Text('Select a day to view events'))
                                : _getEventsForDay(_selectedDay!).isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No events for this day',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: _getEventsForDay(_selectedDay!).length,
                                        itemBuilder: (context, index) {
                                          final event = _getEventsForDay(_selectedDay!)[index];
                                          return InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EventDetailsPage(
                                                    eventId: event.eventId!,
                                                    shouldShowFeedbackBtn: false,
                                                  ),
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
                                                      Text(
                                                        'Time: ${DateHelper.dateTimeFromString(event.startDateTime)!.hour}:${DateHelper.dateTimeFromString(event.startDateTime)!.minute.toString().padLeft(2, '0')}',
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
}


