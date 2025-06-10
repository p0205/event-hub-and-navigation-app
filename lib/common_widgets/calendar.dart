import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:event_hub_and_navigation_app/home/models/calendar_event.dart';

class EventCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final Function(CalendarFormat) onFormatChanged;
  final List<CalendarEvent> Function(DateTime) eventLoader;

  const EventCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onFormatChanged,
    required this.eventLoader,
  });

  // Helper method to normalize date to midnight for consistent comparison
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Helper method to check if two dates are the same day
  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Helper method to get events for a specific day
  List<CalendarEvent> getEventsForDay(DateTime day) {
    return eventLoader(normalizeDate(day));
  }

  // Helper method to check if a day has events
  bool hasEvents(DateTime day) {
    return getEventsForDay(day).isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: Building EventCalendar widget');
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar<CalendarEvent>(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2025, 12, 31),
          focusedDay: focusedDay,
          calendarFormat: calendarFormat,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          onDaySelected: onDaySelected,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          onFormatChanged: onFormatChanged,
          onPageChanged: (focusedDay) {
            print('DEBUG: TableCalendar onPageChanged triggered');
            onPageChanged(focusedDay);
          },
          eventLoader: eventLoader,
          calendarStyle: CalendarStyle(
            markersMaxCount: 1,
            markerDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            outsideDaysVisible: false,
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
            dowBuilder: (context, day) {
              if (day.weekday == DateTime.sunday) {
                return Center(
                  child: Text(
                    'S',
                    style: TextStyle(color: Colors.red[300]),
                  ),
                );
              }
              return null;
            },
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekendStyle: TextStyle(color: Colors.red[300]),
          ),
          pageJumpingEnabled: true,
          pageAnimationEnabled: true,
        ),
      ),
    );
  }
} 