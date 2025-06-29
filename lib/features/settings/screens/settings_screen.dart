import 'package:extroza/core/theme/theme_notifier.dart';
import 'package:extroza/features/auth/screens/welcome_screen.dart';
import 'package:extroza/features/settings/screens/about_screen.dart';
import 'package:extroza/features/settings/screens/account_settings_screen.dart';
import 'package:extroza/features/settings/screens/chat_settings_screen.dart';
import 'package:extroza/features/settings/screens/privacy_settings_screen.dart';
import 'package:extroza/features/settings/screens/profile_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Helper function to show the theme selection dialog
  void _showThemeDialog(BuildContext context, ThemeNotifier themeNotifier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: themeNotifier.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) themeNotifier.setTheme(value);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: themeNotifier.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) themeNotifier.setTheme(value);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: themeNotifier.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) themeNotifier.setTheme(value);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    const String userName = "Leeroy";
    const String userStatus = "Available";
    const String userAvatarUrl = "https://placehold.co/100x100/3A76F0/FFFFFF?text=L";

    return Scaffold(
      // We use a simple, invisible AppBar to handle the status bar area correctly.
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- NEW LAYOUT: Title in the main content area ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Settings',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // --- Profile Section ---
            _ProfileHeader(
              avatarUrl: userAvatarUrl,
              name: userName,
              status: userStatus,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
            ),
            const SizedBox(height: 30),

            // The rest of the settings list remains the same
            _SettingsSection(
              title: 'Account',
              tiles: [
                _SettingsTile(
                  icon: Icons.key_rounded,
                  title: 'Account',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountSettingsScreen())),
                ),
                _SettingsTile(
                  icon: Icons.lock_person_rounded,
                  title: 'Privacy',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacySettingsScreen())),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Appearance',
              tiles: [
                _SettingsTile(
                  icon: Icons.palette_rounded,
                  title: 'Chats',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatSettingsScreen())),
                ),
                _SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Theme',
                  subtitle: themeNotifier.currentThemeName,
                  onTap: () => _showThemeDialog(context, themeNotifier),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Help & Information',
              tiles: [
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About Extroza',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Sign Out'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widgets (No changes needed here) ---

class _ProfileHeader extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String status;
  final VoidCallback onTap;

  const _ProfileHeader({
    required this.avatarUrl,
    required this.name,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(avatarUrl),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsTile> tiles;

  const _SettingsSection({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        ...tiles,
        const Divider(height: 1, indent: 16, endIndent: 16),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: onTap,
    );
  }
}
