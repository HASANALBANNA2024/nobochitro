import 'package:flutter/material.dart';

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

  // ওয়েবের জন্য সেটিংস ডায়ালগ
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
          width: 450, // ওয়েবের জন্য একটু বড় করা হয়েছে
          child: _SettingsContent(
            primaryAccent: primaryAccent,
            isSheet: false, // ডায়ালগ মোড
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

  // মোবাইলের জন্য বটম শিট
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
        isSheet: true, // বটম শিট মোড
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

          // ১. ডার্ক মোড সুইচ (শুধুমাত্র মোবাইলের জন্য, ওয়েবে এটি হাইড থাকবে)
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

          // ২. নোটিফিকেশন সেটিংস
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

          // ৩. ল্যাঙ্গুয়েজ সেটিংস
          ListTile(
            leading: Icon(Icons.language_rounded, color: primaryAccent),
            title: const Text('Language'),
            trailing: const Text(
              'English (US)',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            onTap: () {},
          ),

          // ৪. প্রাইভেসি ও সিকিউরিটি
          ListTile(
            leading: Icon(Icons.lock_outline_rounded, color: primaryAccent),
            title: const Text('Privacy & Security'),
            subtitle: const Text('Password, account safety'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {},
          ),

          // ৫. হেল্প ও সাপোর্ট
          ListTile(
            leading: Icon(Icons.help_outline_rounded, color: primaryAccent),
            title: const Text('Help Center'),
            onTap: () {},
          ),

          const Divider(),

          // ৬. অ্যাপ ইনফো
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About NoboChitro'),
            subtitle: const Text('Version 1.2.0'),
            onTap: () {},
          ),

          if (!isSheet)
            const SizedBox(height: 10), // ডায়ালগের ক্ষেত্রে নিচের স্পেসিং
        ],
      ),
    );
  }
}
