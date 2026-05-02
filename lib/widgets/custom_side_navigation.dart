import 'package:flutter/material.dart';

class CustomSideNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomSideNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryAccent = isDarkMode ? const Color(0xFFD4AF37) : theme.primaryColor;

    return Drawer(
      width: 280, // ড্রয়ারের স্ট্যান্ডার্ড উইডথ
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          // ১. ড্রয়ার হেডার (লোগো সেকশন)
          DrawerHeader(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colorScheme.onSurface.withOpacity(0.05))),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.camera_rounded, color: primaryAccent, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'NoboChitro',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Naviagtion item bar
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildDrawerItem(
                  context,
                  index: 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  primaryAccent: primaryAccent,
                ),
                _buildDrawerItem(
                  context,
                  index: 1,
                  icon: Icons.grid_view_outlined,
                  selectedIcon: Icons.grid_view_rounded,
                  label: 'Packages',
                  primaryAccent: primaryAccent,
                ),
                _buildDrawerItem(
                  context,
                  index: 2,
                  icon: Icons.confirmation_number_outlined,
                  selectedIcon: Icons.confirmation_number_rounded,
                  label: 'Bookings',
                  primaryAccent: primaryAccent,
                ),
                _buildDrawerItem(
                  context,
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'Account',
                  primaryAccent: primaryAccent,
                ),
              ],
            ),
          ),

          // settings cion
          Divider(color: colorScheme.onSurface.withOpacity(0.05)),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {

            },
          ),
          const SizedBox(height: 10),
        ],
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
        selectedTileColor: primaryAccent.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? primaryAccent : colorScheme.onSurface.withOpacity(0.6),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? primaryAccent : colorScheme.onSurface.withOpacity(0.8),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => onDestinationSelected(index),
      ),
    );
  }
}