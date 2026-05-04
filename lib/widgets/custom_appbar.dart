import 'package:flutter/material.dart';

/// this function AppBar call
/// this Dark/Light Mode এবং Responsive Text support |
PreferredSizeWidget buildCustomAppBar(
  BuildContext context,
  Color accentColor,
  String title,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return AppBar(
    // dark mode and light mode
    backgroundColor: isDark ? Colors.grey[900] : Colors.white,
    elevation: 0.5,
    centerTitle: true,

    // back button
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios_new, color: accentColor, size: 20),
      onPressed: () => Navigator.pop(context),
    ),

    // mobile view
    title: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          title,
          style: TextStyle(
            // theme text colou auto change ok
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    ),

    // system bar color adjustment
    surfaceTintColor: Colors.transparent,
  );
}
