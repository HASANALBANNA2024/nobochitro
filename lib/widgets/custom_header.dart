import 'package:flutter/material.dart';
import 'package:nobochitro/screens/search_screen.dart';

class CustomHeader extends StatelessWidget {
  final Color primaryAccent;
  final VoidCallback onMenuPressed;

  final bool isLoggedIn = false;

  const CustomHeader({
    super.key,
    required this.primaryAccent,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 800;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity, // ফুল উইডথ নিশ্চিত করে
        padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 32 : 16,
            vertical: 12
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(color: colorScheme.onSurface.withOpacity(0.05)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ১. বাম পাশের অংশ: লোগো (এবং ওয়েবে মেনু ও টেক্সট)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLargeScreen) ...[
                  IconButton(
                    padding: const EdgeInsets.only(right: 12),
                    icon: const Icon(Icons.menu_rounded),
                    onPressed: onMenuPressed,
                  ),
                  Image.asset(
                    'assets/images/app_icon.png',
                    height: 35,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'NoboChitro - নবচিত্র',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ] else ...[
                  Image.asset(
                    'assets/images/app_icon.png',
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                ],
              ],
            ),

            // ২. মাঝখানের অংশ: ওয়েব সার্চ বার
            if (isLargeScreen)
              Expanded(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 700),
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: _buildSearchBar(context),
                  ),
                ),
              ),

            // ৩. ডান পাশের অংশ: লগইন এবং সার্চ (মোবাইলের জন্য সাজানো)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // মোবাইলে সার্চ আইকনটি এখন লগইনের একদম কাছে থাকবে
                if (!isLargeScreen) ...[
                  const SizedBox(width: 4), // গ্যাপ কমানো হয়েছে
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.search_rounded, size: 24),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SearchScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 5,),
                ],
                isLoggedIn
                    ? _buildLoggedInView(primaryAccent)
                    : _buildLoggedOutView(context, primaryAccent, isLargeScreen),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInView(Color primaryAccent) {
    return Icon(Icons.account_circle, color: primaryAccent, size: 28);
  }

  Widget _buildLoggedOutView(BuildContext context, Color primaryAccent, bool isLargeScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            'Login',
            style: TextStyle(
                color: primaryAccent,
                fontWeight: FontWeight.w600,
                fontSize: isLargeScreen ? 14 : 13
            ),
          ),
        ),
        // Sign Up শুধুমাত্র ওয়েবে দেখাবে
        if (isLargeScreen) ...[
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search photographers...',
          hintStyle: TextStyle(fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}