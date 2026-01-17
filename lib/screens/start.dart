import 'package:flutter/material.dart';
import 'package:pranayfunds/models/user_model.dart';
import 'package:pranayfunds/screens/home.dart';
import 'package:pranayfunds/screens/rewards_screen.dart';
import 'package:pranayfunds/screens/settings.dart';
import 'package:pranayfunds/screens/statement_screen.dart';
import 'package:pranayfunds/services/updater_service.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdates());
  }

  Future<void> _checkForUpdates() async {
    try {
      final updater = UpdaterService();
      final release = await updater.checkForUpdates();
      if (!mounted || release == null) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Update Available: v${release.version}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('A new version is available!'),
                const SizedBox(height: 8),
                const Text('Changelog:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(release.changelog),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                updater.launchUpdateUrl(release.url);
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Startup update check failed: $e');
    }
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
