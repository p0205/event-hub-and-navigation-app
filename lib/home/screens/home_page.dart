import 'dart:async';

import 'package:event_hub_and_navigation_app/navigation/bloc/navigation_bloc.dart';
import 'package:event_hub_and_navigation_app/utils/date_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:event_hub_and_navigation_app/home/bloc/home_bloc.dart';
import 'package:event_hub_and_navigation_app/home/models/calendar_event.dart';
import 'package:event_hub_and_navigation_app/common_widget/calendar.dart';
import 'package:event_hub_and_navigation_app/common_widget/navigation_provider.dart';

import '../../event_details/screen/event_details_page.dart';
import '../../qr_scanner/screens/QRScannerScreen.dart';
// Navigation screen import removed as it's no longer needed

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
    _homeBloc = BlocProvider.of<HomeBloc>(context);
    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEventsForFocusedMonth();
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
    // Check if we have cached events for this month
    if (_hasCachedEvents(_focusedDay)) {
      _updateEventsFromCache(_focusedDay);
      return;
    }

    // Calculate the start of the _focusedDay's month
    DateTime startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);

    // Calculate the end of the _focusedDay's month
    DateTime endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0)
        .add(const Duration(
            hours: 23, minutes: 59, seconds: 59, milliseconds: 999));

    // Dispatch the event with the calculated date range
    _homeBloc.add(
      FetchAllCalendarEventsByMonth(
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
          DateTime? dateTime =
              DateHelper.dateTimeFromString(event.startDateTime);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              print('🔍 [HomePage] QR Scanner button pressed');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRScannerScreen(),
                ),
              ).then((result) {
                // This runs immediately when Navigator.pop is called, no async gap
                if (result != null &&
                    result is Map &&
                    result['type'] == 'venue') {
                  print(
                      '🏠 [HomePage] Received venue data from QR scanner: ${result['data']}');

                  // Use Timer to add delay without async gap
                  Timer(Duration(milliseconds: 200), () {
                    if (mounted) {
                      try {
                        final navigationProvider =
                            Provider.of<NavigationProvider>(context,
                                listen: false);
                        navigationProvider.setPage(2);
                        print(
                            '🧭 [HomePage] Successfully navigated to navigation screen (page 2)');
                      } catch (e) {
                        print(
                            '❌ [HomePage] Error navigating to navigation screen: $e');
                      }
                    } else {
                      print(
                          '⚠️ [HomePage] Widget no longer mounted, skipping navigation');
                    }
                  });
                } else {
                  print(
                      '🏠 [HomePage] No venue data received or user cancelled QR scan');
                }
              }).catchError((error) {
                print('❌ [HomePage] Error in navigation: $error');
              });
            },
          ),
        ],
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        bloc: _homeBloc,
        listener: (context, state) {
          if (state is CalendarEventLoaded) {
            _cacheEvents(_focusedDay, state.events);

            _events = {};
            for (var event in state.events) {
              if (event.startDateTime != null) {
                DateTime? dateTime =
                    DateHelper.dateTimeFromString(event.startDateTime);
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
                                    itemCount:
                                        _getEventsForDay(_selectedDay!).length,
                                    itemBuilder: (context, index) {
                                      final event = _getEventsForDay(
                                          _selectedDay!)[index];
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EventDetailsPage(
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
                                            title: Text(event.eventName ??
                                                'Unnamed Event'),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (event.sessionName != null)
                                                  Text(
                                                      'Session: ${event.sessionName}'),
                                                if (event.venueNames != null)
                                                  Text(
                                                      'Venue: ${event.venueNames}'),
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
      ),
    );
  }
}
