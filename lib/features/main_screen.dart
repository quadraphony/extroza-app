import 'package:extroza/features/calls/screens/calls_screen.dart';
import 'package:extroza/features/chats/screens/chats_screen.dart';
import 'package:extroza/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // This list holds the different screens for the bottom navigation bar.
  static const List<Widget> _widgetOptions = <Widget>[
    ChatsScreen(),
    CallsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Chats',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.call_rounded),
            icon: Icon(Icons.call_outlined),
            label: 'Calls',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings_rounded),
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
