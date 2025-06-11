import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_hub_and_navigation_app/auth/bloc/auth_bloc.dart';
import 'package:event_hub_and_navigation_app/widgets/login_reminder_widget.dart';
import 'my_events_calender_view_page.dart';
import 'my_events_tab_view_page.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> with SingleTickerProviderStateMixin {
  int _selectedViewIndex = 0; // 0 for Calendar, 1 for Tab View
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_selectedViewIndex == 0 ? Icons.view_list : Icons.calendar_month),
            onPressed: () {
              setState(() {
                _selectedViewIndex = _selectedViewIndex == 0 ? 1 : 0;
              });
            },
            tooltip: _selectedViewIndex == 0 ? 'Switch to List View' : 'Switch to Calendar View',
          ),
        ],
        bottom: _selectedViewIndex == 1 ? TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming Events'),
            Tab(text: 'Past Events'),
          ],
        ) : null,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is UnAuthenticatedState) {
            return const LoginReminderWidget();
          }

          return IndexedStack(
            index: _selectedViewIndex,
            children: [
              const MyEventsCalenderViewPage(),
              MyEventsTabViewPage(tabController: _tabController),
            ],
          );
        },
      ),
    );
  }
}
