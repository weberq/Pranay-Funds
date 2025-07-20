import 'package:flutter/material.dart';
import 'package:pranayfunds/models/user_model.dart';
import 'package:pranayfunds/screens/home.dart';
import 'package:pranayfunds/screens/settings.dart';

class StartScreen extends StatefulWidget {
  final UserModel user;
  const StartScreen({super.key, required this.user});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late final List<Widget> _pages;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the pages list and pass the user data to both screens
    _pages = [
      HomeScreen(user: widget.user),
      Settings(user: widget.user), // <-- Pass user data here
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _pageIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
