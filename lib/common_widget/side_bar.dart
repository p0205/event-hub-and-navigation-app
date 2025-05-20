import 'dart:convert';

import 'package:flutter/material.dart';



class SideBar extends StatelessWidget {
  final int userId;
  final String userName;
  final String userEmail;
  final String? profileIcon; // Accept profileIcon as nullable

  const SideBar({
    super.key,
    required this.userName,
    required this.userEmail,
    this.profileIcon, required this.userId,
  });

  // Future<void> _logout(BuildContext context) async {
  //   try {
  //     final token = context.read<UserBloc>().state.token!;
  //     final url = Uri.parse('${Constants.BaseUrl}${Constants.AunthenticationPort}/logout'); // Replace with your backend logout URL
  //
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Accept': 'application/json',
  //       },
  //     );
  //     final prefs = await SharedPreferences.getInstance();
  //     if (response.statusCode == 200) {
  //       if (prefs.getBool('rememberMe') == false) {
  //         // Clear all stored data
  //         await prefs.clear();
  //       } else {
  //         // Clear only the token
  //         final email = prefs.getString('email');
  //         await prefs.setString('email', email!);
  //         await prefs.setBool('rememberMe', true);
  //       }
  //
  //       Restart.restartApp();
  //       // Optionally, clear any other session data or token if needed
  //       // You can also clear the token here if you're storing it in SharedPreferences
  //       // await prefs.remove('token');
  //
  //       // Logout successful
  //       // showPopupDialog(
  //       //   context,
  //       //   'Logged out successfully',
  //       //   onOkPressed: () {
  //       //     Restart.restartApp(
  //       //     );
  //       //   },
  //       // );
  //     } else {
  //       // Handle logout failure
  //       showPopupDialog(
  //         context,
  //         'Logout failed',
  //       );
  //     }
  //   } catch (e) {
  //     // Handle connection errors
  //     showPopupDialog(
  //       context,
  //       'An error occurred: $e',
  //     );
  //   }
  //
  // }
  //

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 160,
            decoration: const BoxDecoration(
                color: Color(0xFF599BF9)
            ),
            child: _buildUserProfileHeader(context),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: ()  {

            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: ()  {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => UserProfileScreen(),
              //   ),
              // );
            },
          ),

          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Schedule'),
            onTap: () {
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text('Calories Intake'),
            onTap: () {
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_fire_department),
            title: const Text('Calories Burned'),
            onTap: () {}
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Risk Assessment'),
            onTap: () {

            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // showDialog(
                // context: context,
                // builder: (context) => AlertDialog(
                //   title: const Text('Confirm Logout'),
                //   content: const Text('Are you sure you want to log out?'),
                //   actions: [
                //     TextButton(
                //       onPressed: () {
                //         // Close the dialog without logging out
                //         Navigator.of(context).pop();
                //       },
                //       child: const Text('Cancel'),
                //     ),
                //     TextButton(
                //       onPressed: () {
                //         _logout(context);


            },
          ),
        ],
      ),
    );


  }

  Widget _buildUserProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage:
                 AssetImage("assets/images/USER_ICON.png"),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
               "Username",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Email",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}