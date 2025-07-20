import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pranayfunds/models/user_model.dart';

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
            color: colorScheme.surfaceVariant.withOpacity(0.5),
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
        ],
      ),
    );
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
