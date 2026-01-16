import 'package:flutter/material.dart';
import 'package:pranayfunds/models/user_model.dart';
import 'package:pranayfunds/screens/home.dart';
import 'package:pranayfunds/screens/rewards_screen.dart';
import 'package:pranayfunds/screens/settings.dart';
import 'package:pranayfunds/screens/statement_screen.dart';

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
    _pages = [
      HomeScreen(user: widget.user),
      RewardsScreen(user: widget.user),
      StatementScreen(user: widget.user),
      Settings(user: widget.user),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pageIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.stars_outlined),
            selectedIcon: Icon(Icons.stars),
            label: 'Rewards',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
