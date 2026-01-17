import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pranayfunds/models/user_model.dart';
import 'package:pranayfunds/services/updater_service.dart';
import 'package:url_launcher/url_launcher.dart';

// Corrected class name from SettingsScreen to Settings
class Settings extends StatelessWidget {
  final UserModel user;
  const Settings({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User Profile Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      user.customerName.isNotEmpty ? user.customerName[0] : 'U',
                      style: textTheme.headlineSmall
                          ?.copyWith(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.customerName,
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Username: ${user.username}',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Menu Items
          _buildSectionHeader('Account', textTheme),
          _buildSettingsTile(
            context: context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {},
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.lock_outline,
            title: 'Change MPIN',
            onTap: () {},
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.devices_other_outlined,
            title: 'Manage Devices',
            onTap: () {},
          ),

          _buildSettingsTile(
            context: context,
            icon: Icons.system_update_outlined,
            title: 'Check for Updates',
            onTap: () => _checkForUpdates(context),
          ),

          const Divider(height: 32),

          _buildSectionHeader('Security', textTheme),
          SwitchListTile(
            title:
                Text('Two-Factor Authentication', style: textTheme.titleMedium),
            secondary: const Icon(Icons.shield_outlined),
            value: false, // Placeholder
            onChanged: (bool value) {
              // TODO: Implement 2FA logic
            },
          ),

          const Divider(height: 32),

          _buildSectionHeader('Legal', textTheme),
          _buildSettingsTile(
            context: context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => _launchWebUrl(
                context, 'https://funds.cottonseeds.org/privacy-policy'),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => _launchWebUrl(
                context, 'https://funds.cottonseeds.org/terms-of-service'),
          ),

          const Divider(height: 32),

          // Logout Button
          ListTile(
            leading: Icon(Icons.logout, color: colorScheme.error),
            title: Text(
              'Logout',
              style: textTheme.titleMedium?.copyWith(color: colorScheme.error),
            ),
            onTap: () {
              // Navigate back to the login screen, clearing all other screens
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),

          const SizedBox(height: 32),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Version info unavailable',
                    style:
                        textTheme.bodySmall?.copyWith(color: colorScheme.error),
                  ),
                );
              }
              if (!snapshot.hasData) return const SizedBox();
              return Center(
                child: Text(
                  'v${snapshot.data!.version} (Build ${snapshot.data!.buildNumber})',
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _checkForUpdates(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final updater = UpdaterService();
      final release = await updater.checkForUpdates();

      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loading

      if (release != null) {
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App is up to date!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading if error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking updates: $e')),
        );
      }
    }
  }

  Future<void> _launchWebUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open link: $url')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double progress = 0.0;
            return PopScope(
              canPop: false,
              child: AlertDialog(
                title: const Text('Downloading Update...'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 10),
                    Text('${(progress * 100).toStringAsFixed(0)}%'),
                    const SizedBox(height: 10),
                    const Text('Please wait while the update downloads.'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // Provide a way to update the dialog state
    // Since StatefulBuilder rebuilds its child, we need to find a way to update 'progress'
    // actually, the simplest way without complex state management in a static method context
    // is to use a ValueNotifier or just rebuilding the widget.
    // However, clean approach:

    // Changing approach: define progress notifier outside
    final progressNotifier = ValueNotifier<double>(0.0);

    // Close the static dialog
    if (context.mounted) Navigator.pop(context);

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
      // If install triggers, app might close or pause.
      // We can pop the dialog if we are still here.
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

  Widget _buildSectionHeader(String title, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }
}
