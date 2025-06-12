
import 'package:event_hub_and_navigation_app/utils/date_helper.dart';
import 'package:event_hub_and_navigation_app/widgets/login_reminder_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:event_hub_and_navigation_app/home/models/calendar_event.dart';
import 'package:event_hub_and_navigation_app/common_widget/calendar.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../event_details/screen/event_details_page.dart';
import '../blocs/my_events_calendar_view_bloc/bloc/event_bloc.dart'; // Ensure this points to calendar_event_model.dart if that's the name
// import 'package:event_hub_and_navigation_app/utils/date_helper.dart'; // This might not be needed anymore, remove if unused

class MyEventsCalenderViewPage extends StatefulWidget {
  const MyEventsCalenderViewPage({super.key});

  @override
  State<MyEventsCalenderViewPage> createState() => _MyEventsCalenderViewPageState();
}

class _MyEventsCalenderViewPageState extends State<MyEventsCalenderViewPage> {
  late final MyEventsCalendarViewBloc _eventBloc;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<CalendarEvent>> _events = {};
  int? _currentUserId;
  
  // Cache for storing events by month
  final Map<String, List<CalendarEvent>> _eventCache = {};

  // Helper method to get cache key for a month
  String _getCacheKey(DateTime date) {
    return '${date.year}-${date.month}';
  }

  // Helper method to check if we have cached events for a month
  bool _hasCachedEvents(DateTime date) {
    return _eventCache.containsKey(_getCacheKey(date));
  }

  // Helper method to get cached events for a month
  List<CalendarEvent>? _getCachedEvents(DateTime date) {
    return _eventCache[_getCacheKey(date)];
  }

  // Helper method to store events in cache
  void _cacheEvents(DateTime date, List<CalendarEvent> events) {
    _eventCache[_getCacheKey(date)] = events;
  }

  @override
  void initState() {
    super.initState();
    _eventBloc = BlocProvider.of<MyEventsCalendarViewBloc>(context);
    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthenticatedState) {
        _currentUserId = authState.user.id;
        _fetchEventsForFocusedMonth();
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

  // Helper method to calculate and dispatch the event
  void _fetchEventsForFocusedMonth() {
    print("DEBUG: _fetchEventsForFocusedMonth called with focusedDay: $_focusedDay");
    if (_currentUserId == null) {
      print("DEBUG: _currentUserId is null, returning");
      return;
    }

    // Check if we have cached events for this month
    if (_hasCachedEvents(_focusedDay)) {
      print("DEBUG: Using cached events for month: ${_getCacheKey(_focusedDay)}");
      _updateEventsFromCache(_focusedDay);
      return;
    }

    // Calculate the start of the _focusedDay's month
    DateTime startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    print("DEBUG: startOfMonth: $startOfMonth");

    // Calculate the end of the _focusedDay's month
    DateTime endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0)
        .add(const Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
    print("DEBUG: endOfMonth: $endOfMonth");

    // Dispatch the event with the calculated date range
    _eventBloc.add(
      FetchMyCalendarEventsByMonth(
        userId: _currentUserId!,
        startDateTime: startOfMonth,
        endDateTime: endOfMonth,
      ),
    );
  }

  // Helper method to update events from cache
  void _updateEventsFromCache(DateTime date) {
    final cachedEvents = _getCachedEvents(date);
    if (cachedEvents != null) {
      _events = {};
      for (var event in cachedEvents) {
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
    }
  }

  void _clearCache() {
    _eventCache.clear();
    _events.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is UnAuthenticatedState) {
            return const LoginReminderWidget();
          }

          return BlocConsumer<MyEventsCalendarViewBloc, MyEventsCalendarViewState>(
            bloc: _eventBloc,
            listener: (context, state) {
              if (state is CalenderEventLoadedState) {
                // Cache the events for the current month
                _cacheEvents(_focusedDay, state.events);
                
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
              } else if (state is CalendarEventErrorState) {
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
                        print('DEBUG: Calendar page changed to: $focusedDay');
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                        _fetchEventsForFocusedMonth();
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
                    child: state is CalendarEventLoadingState
                        ? const Center(child: CircularProgressIndicator())
                        : state is CalendarEventErrorState
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


