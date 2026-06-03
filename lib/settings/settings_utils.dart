import 'package:flutter/material.dart';
import 'package:nobochitro/settings/privacy_security_view.dart';

class SettingsUtils {
  static void showSettings(
    BuildContext context,
    Color primaryAccent,
    Function(bool) onThemeChanged,
  ) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 800;

    if (isLargeScreen) {
      _showSettingsDialog(context, primaryAccent, onThemeChanged);
    } else {
      _showSettingsSheet(context, primaryAccent, onThemeChanged);
    }
  }

  ///settings dialogue of mobile
  static void _showSettingsDialog(
    BuildContext context,
    Color primaryAccent,
    Function(bool) onThemeChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 450,
          child: _SettingsContent(
            primaryAccent: primaryAccent,
            isSheet: false,
            onThemeChanged: onThemeChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// mobile bottom sheet
  static void _showSettingsSheet(
    BuildContext context,
    Color primaryAccent,
    Function(bool) onThemeChanged,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => _SettingsContent(
        primaryAccent: primaryAccent,
        isSheet: true,
        onThemeChanged: onThemeChanged,
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  final Color primaryAccent;
  final bool isSheet;
  final Function(bool) onThemeChanged;

  const _SettingsContent({
    super.key,
    required this.primaryAccent,
    required this.isSheet,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, isSheet ? 12 : 0, 16, isSheet ? 30 : 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSheet) ...[
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Divider(),
          ],

          /// dark mode switch for mobile only
          if (isSheet)
            SwitchListTile(
              secondary: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: primaryAccent,
              ),
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch visual theme'),
              value: isDarkMode,
              activeColor: primaryAccent,
              onChanged: (value) {
                onThemeChanged(value);
                Navigator.pop(context);
              },
            ),

          ///Notification settings
          ListTile(
            leading: Icon(
              Icons.notifications_none_rounded,
              color: primaryAccent,
            ),
            title: const Text('Notifications'),
            subtitle: const Text('Manage alerts & updates'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              // TODO: Navigate to Notification Settings
            },
          ),

          // Privacy & Security
          ListTile(
            leading: Icon(Icons.lock_outline_rounded, color: primaryAccent),
            title: const Text('Privacy & Policy'),
            subtitle: const Text('Privacy and Policy of Our Event Management'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PrivacySecurityView(onThemeChanged: onThemeChanged),
                ),
              );
            },
          ),

          // Help Support
          ListTile(
            leading: Icon(Icons.help_outline_rounded, color: primaryAccent),
            title: const Text('Help Center'),
            onTap: () {},
          ),

          const Divider(),

          // App Info
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About NoboChitro'),
            subtitle: const Text('Version 1.2.0'),
            onTap: () {},
          ),

          if (!isSheet) const SizedBox(height: 10),
        ],
      ),
    );
  }
}
