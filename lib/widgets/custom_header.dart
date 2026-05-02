import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final bool isLargeScreen;
  final Color primaryAccent;
  final VoidCallback onMenuPressed;

  const CustomHeader({
    super.key,
    required this.isLargeScreen,
    required this.primaryAccent,
    required this.onMenuPressed,
  });

  bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.onSurface.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          if (isLargeScreen)
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: onMenuPressed,
            ),

          if (!isLargeScreen) ...[
            Icon(Icons.camera_rounded, color: primaryAccent, size: 28),
            const SizedBox(width: 10),
          ],

          Text(
            'NoboChitro',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),

          if (isLargeScreen)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: _buildSearchBar(context),
              ),
            )
          else
            const Spacer(),

          if (isLargeScreen) ...[
            TextButton(
              onPressed: () {},
              child: Text(
                'Login',
                style: TextStyle(color: primaryAccent, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
          ],

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Sign Up',
              style: TextStyle(
                color: isDarkMode(context) ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search for photographers or styles...',
          hintStyle: TextStyle(fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}