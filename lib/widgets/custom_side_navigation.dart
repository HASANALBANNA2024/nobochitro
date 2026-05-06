import 'package:flutter/material.dart';
import 'package:nobochitro/booking_summary_screen/my_booking_screen.dart';
import 'package:nobochitro/client_profile/client_profile_screen.dart';
import 'package:nobochitro/photographer_section/photographer_profile_screen.dart';

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

    final primaryAccent = isDarkMode
        ? const Color(0xFFD4AF37)
        : theme.primaryColor;
    return Drawer(
      width: 280,
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          _buildHeader(context, isDarkMode),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              physics: const BouncingScrollPhysics(),
              children: [
                // Home - Direct Logic in onTap
                _buildDrawerItem(
                  context,
                  isSelected: selectedIndex == 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: "Home",
                  primaryAccent: primaryAccent,
                  onTap: () => onDestinationSelected(0),
                ),
                // packages
                _buildDrawerItem(
                  context,
                  isSelected: selectedIndex == 1,
                  icon: Icons.grid_view_outlined,
                  selectedIcon: Icons.grid_view_rounded,
                  label: "Packages",
                  primaryAccent: primaryAccent,
                  onTap: () => onDestinationSelected(1),
                ),
                // My Bookings
                _buildDrawerItem(
                  context,
                  isSelected: selectedIndex == 2,
                  icon: Icons.confirmation_num_outlined,
                  selectedIcon: Icons.confirmation_num_rounded,
                  label: "My Bookings",
                  primaryAccent: primaryAccent,
                  onTap: () {
                    onDestinationSelected(2);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyBookingScreen(
                          primaryAccent: primaryAccent,
                          selectedIndex: selectedIndex,
                          onDestinationSelected: onDestinationSelected,
                          onThemeChanged: onThemeChanged,
                          onSettingsPressed: onSettingsPressed,
                        ),
                      ),
                    );
                  },
                ),
                // Account
                _buildDrawerItem(
                  context,
                  isSelected: selectedIndex == 3,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person_rounded,
                  label: "Profile",
                  primaryAccent: primaryAccent,
                 onTap: (){
                    onDestinationSelected(3);
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>
                    ClientProfileScreen()
                    ));
                 }
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                  child: Divider(height: 1),
                ),
                // Theme Switch and Settings stay as they are
                SwitchListTile(
                  secondary: Icon(
                    isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: isDarkMode
                        ? primaryAccent
                        : colorScheme.onSurface.withOpacity(0.6),
                    size: 22,
                  ),
                  title: const Text(
                    "Dark Mode",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  value: isDarkMode,
                  dense: true,
                  activeColor: primaryAccent,
                  onChanged: (value) => onThemeChanged(value),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Text(
                    "Settings",
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: onSettingsPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // helper widgets
  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero, // বাড়তি প্যাডিং কমানোর জন্য
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
          ),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // কনটেন্ট অনুযায়ী সাইজ হবে
          children: [
            Container(
              height: 80, // লোগোর জন্য একটি নির্দিষ্ট হাইট দিন
              width: 80,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                "assets/images/app_icon.png",
                fit: BoxFit.contain, // ইমেজ যেন কনটেইনারের বাইরে না যায়
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Nobochitro - নবচিত্র",
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

  // build Drawer Item
  Widget _buildDrawerItem(
    BuildContext context, {
    required bool isSelected,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required Color primaryAccent,
    required VoidCallback onTap,
  }) {
    final coloScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
      child: ListTile(
        selected: isSelected,
        dense: true,
        selectedTileColor: primaryAccent.withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected
              ? primaryAccent
              : coloScheme.onSurface.withOpacity(0.55),
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? primaryAccent
                : coloScheme.onSurface.withOpacity(0.85),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onTap: () {
          onTap();
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
