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
      // --- UPDATED WIDGET ---
      // We are now using the Material 3 NavigationBar
      bottomNavigationBar: NavigationBar(
        // The selectedIndex determines which tab is active.
        selectedIndex: _selectedIndex,
        // The onDestinationSelected callback updates the state when a new tab is tapped.
        onDestinationSelected: _onItemTapped,
        // The indicatorColor gives the "pill" shape its color.
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        // The list of destinations (tabs).
        destinations: const <NavigationDestination>[
          NavigationDestination(
            // The icon to show when the tab is selected.
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            // The icon to show when the tab is not selected.
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
