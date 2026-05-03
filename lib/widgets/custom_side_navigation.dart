import 'package:flutter/material.dart';

class CustomSideNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onSettingsPressed;
  final Function(bool) onThemeChanged;

  const CustomSideNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onThemeChanged,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    // গোল্ডেন বা প্রাইমারি কালার সিলেকশন
    final primaryAccent = isDarkMode ? const Color(0xFFD4AF37) : theme.primaryColor;

    return Drawer(
      width: 280,
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          // লোগো হেডার
          _buildHeader(context, isDarkMode),

          // নেভিগেশন আইটেম লিস্ট (এখন সুইচ এবং সেটিংস এর ভেতরেই থাকবে)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDrawerItem(context, index: 0, icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home', primaryAccent: primaryAccent),
                _buildDrawerItem(context, index: 1, icon: Icons.grid_view_outlined, selectedIcon: Icons.grid_view_rounded, label: 'Packages', primaryAccent: primaryAccent),
                _buildDrawerItem(context, index: 2, icon: Icons.confirmation_number_outlined, selectedIcon: Icons.confirmation_number_rounded, label: 'Bookings', primaryAccent: primaryAccent),
                _buildDrawerItem(context, index: 3, icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Account', primaryAccent: primaryAccent),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Divider(height: 1),
                ),

                // ডার্ক মোড সুইচ - এখন এটি ড্রয়ার লিস্টের একটি আইটেম
                SwitchListTile(
                  secondary: Icon(
                    isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: isDarkMode ? primaryAccent : colorScheme.onSurface.withOpacity(0.6),
                    size: 22,
                  ),
                  title: const Text('Dark Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  value: isDarkMode,
                  dense: true,
                  activeColor: primaryAccent,
                  onChanged: (value) => onThemeChanged(value),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),

                // সেটিংস আইটেম - এখন এটিও লিস্টের অংশ
                ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: Icon(Icons.settings_outlined, color: colorScheme.onSurface.withOpacity(0.6), size: 22),
                  title: const Text('Settings', style: TextStyle(fontSize: 14)),
                  onTap: onSettingsPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05)),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                'assets/images/app_icon.png',
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'NoboChitro - নবচিত্র', // আপনার ব্র্যান্ডিং অনুযায়ী আপডেট করা
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required int index,
        required IconData icon,
        required IconData selectedIcon,
        required String label,
        required Color primaryAccent,
      }) {
    bool isSelected = selectedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        selected: isSelected,
        dense: true,
        selectedTileColor: primaryAccent.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? primaryAccent : colorScheme.onSurface.withOpacity(0.6),
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? primaryAccent : colorScheme.onSurface.withOpacity(0.8),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: () => onDestinationSelected(index),
      ),
    );
  }
}