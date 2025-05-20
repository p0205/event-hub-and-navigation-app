// // Copyright 2019 Aleksander Woźniak
// // SPDX-License-Identifier: Apache-2.0

// // ignore_for_file: avoid_print

// import 'dart:collection';

// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';



// class EventCalendar extends StatefulWidget {
//   const EventCalendar({super.key});

//   @override
//   State<EventCalendar> createState() => _EventCalendarState();
// }

// class _EventCalendarState extends State<EventCalendar> {
//   late final ValueNotifier<List<MockEvent>> _selectedEvents;
//   final CalendarFormat _calendarFormat = CalendarFormat.month;
//   RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
//       .toggledOff; // Can be toggled on/off by longpressing a date
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   DateTime? _rangeStart;
//   DateTime? _rangeEnd;

//   @override
//   void initState() {
//     super.initState();

//     _selectedDay = _focusedDay;
//     _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
//   }

//   @override
//   void dispose() {
//     _selectedEvents.dispose();
//     super.dispose();
//   }

//   List<MockEvent> _getEventsForDay(DateTime day) {
//     // Implementation example
//     return kEvents[day] ?? [];
//   }

//   List<MockEvent> _getEventsForRange(DateTime start, DateTime end) {
//     // Implementation example
//     final days = daysInRange(start, end);

//     return [
//       for (final d in days) ..._getEventsForDay(d),
//     ];
//   }

//   void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     if (!isSameDay(_selectedDay, selectedDay)) {
//       setState(() {
//         _selectedDay = selectedDay;
//         _focusedDay = focusedDay;
//         _rangeStart = null; // Important to clean those
//         _rangeEnd = null;
//         _rangeSelectionMode = RangeSelectionMode.toggledOff;
//       });

//       _selectedEvents.value = _getEventsForDay(selectedDay);
//     }
//   }

//   void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
//     setState(() {
//       _selectedDay = null;
//       _focusedDay = focusedDay;
//       _rangeStart = start;
//       _rangeEnd = end;
//       _rangeSelectionMode = RangeSelectionMode.toggledOn;
//     });

//     // `start` or `end` could be null
//     if (start != null && end != null) {
//       _selectedEvents.value = _getEventsForRange(start, end);
//     } else if (start != null) {
//       _selectedEvents.value = _getEventsForDay(start);
//     } else if (end != null) {
//       _selectedEvents.value = _getEventsForDay(end);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TableCalendar<MockEvent>(
//       firstDay: kFirstDay,
//       lastDay: kLastDay,
//       focusedDay: _focusedDay,
//       selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//       rangeStartDay: _rangeStart,
//       rangeEndDay: _rangeEnd,
//       calendarFormat: _calendarFormat,
//       rangeSelectionMode: _rangeSelectionMode,
//       eventLoader: _getEventsForDay,
//       startingDayOfWeek: StartingDayOfWeek.monday,
//       calendarStyle: const CalendarStyle(
//         // Use `CalendarStyle` to customize the UI
//         outsideDaysVisible: false,
//       ),
//       onDaySelected: _onDaySelected,
//       onRangeSelected: _onRangeSelected,
//       // onFormatChanged: (format) {
//       //   if (_calendarFormat != format) {
//       //     setState(() {
//       //       _calendarFormat = format;
//       //     });
//       //   }
//       // },
//       onPageChanged: (focusedDay) {
//         _focusedDay = focusedDay;
//       },
//     );

//   }


//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime now = DateTime.now();
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: widget.bloc.state.date,
//       firstDate: DateTime(2020),
//       lastDate:  DateTime(now.year, now.month, now.day),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Colors.blue,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     widget.bloc.add(DateChangedEvent(date: picked!));
//   }
// }
// }

// /// Example events.
// ///
// ///
//  class MockEvent {
//   final String title;

//   const MockEvent(this.title);

//   @override
//   String toString() => title;
// }
// /// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
// final kEvents = LinkedHashMap<DateTime, List<MockEvent>>(
//   equals: isSameDay,
//   hashCode: getHashCode,
// )..addAll(_kEventSource);

// final _kEventSource = {
//   for (var item in List.generate(50, (index) => index))
//     DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5): List.generate(
//       item % 4 + 1,
//       (index) => MockEvent('Event $item | ${index + 1}'),
//     ),
// }..addAll({
//     kToday: [
//       const MockEvent("Today's Event 1"),
//       const MockEvent("Today's Event 2"),
//     ],
//   });

// int getHashCode(DateTime key) {
//   return key.day * 1000000 + key.month * 10000 + key.year;
// }

// /// Returns a list of [DateTime] objects from [first] to [last], inclusive.
// List<DateTime> daysInRange(DateTime first, DateTime last) {
//   final dayCount = last.difference(first).inDays + 1;
//   return List.generate(
//     dayCount,
//     (index) => DateTime.utc(first.year, first.month, first.day + index),
//   );
// }

// final kToday = DateTime.now();
// final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
// final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);


