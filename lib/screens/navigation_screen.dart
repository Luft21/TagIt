import 'package:flutter/material.dart';
import 'package:tag_it/widgets/navbar_view.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'reminder/reminder_list_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ReminderListScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _screens),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavbarView(
              selectedIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}
