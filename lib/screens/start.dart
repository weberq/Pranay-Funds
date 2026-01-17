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
                Navigator.pop(context); // Close info dialog
                _startUpdate(context, updater, release);
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

  Future<void> _startUpdate(
      BuildContext context, UpdaterService updater, ReleaseInfo release) async {
    if (release.downloadUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No APK asset found in release.')),
      );
      return;
    }

    // Show Progress Dialog
    final progressNotifier = ValueNotifier<double>(0.0);

    // Show dynamic dialog
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Downloading Update...'),
            content: ValueListenableBuilder<double>(
              valueListenable: progressNotifier,
              builder: (context, value, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(value: value),
                    const SizedBox(height: 10),
                    Text('${(value * 100).toStringAsFixed(0)}%'),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    try {
      await updater.downloadAndInstallUpdate(
        release.downloadUrl!,
        (progress) {
          progressNotifier.value = progress;
        },
      );
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Update Failed'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
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
