import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;


    final primaryAccent = isDarkMode ? const Color(0xFFD4AF37) : const Color(0xFF008080);

    return BottomNavigationBar(
      backgroundColor: colorScheme.surface,
      selectedItemColor: primaryAccent,
      unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), activeIcon: Icon(Icons.grid_view), label: 'Packages'),
        BottomNavigationBarItem(icon: Icon(Icons.book_online_outlined), activeIcon: Icon(Icons.book_online), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), activeIcon: Icon(Icons.person), label: 'Settings'),
      ],
    );
  }
}