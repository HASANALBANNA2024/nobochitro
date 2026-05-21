import 'package:flutter/material.dart';
import 'package:nobochitro/widgets/custom_appbar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    "Packages",
    "Photographers",
    "Payments",
    "Reviews",
    "Addons",
  ];
  // এখানে ৫টি ট্যাবের জন্য ৫টি আইকন নিশ্চিত করা হয়েছে
  final List<IconData> _icons = [
    Icons.grid_view,
    Icons.camera_alt,
    Icons.payment,
    Icons.star,
    Icons.add_circle_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final primaryAccent = isDarkMode
        ? const Color(0xFFD4AF37)
        : const Color(0xFF008080);
    final backgroundColor = isDarkMode
        ? const Color(0xFF0F0F0F)
        : theme.scaffoldBackgroundColor;
    bool isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: buildCustomAppBar(context, primaryAccent, "Admin Dashboard"),
      drawer: isLargeScreen
          ? null
          : Drawer(child: _buildSidebar(isDarkMode, primaryAccent)),
      body: Row(
        children: [
          if (isLargeScreen) _buildSidebar(isDarkMode, primaryAccent),
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                padding: const EdgeInsets.all(20),
                child: _buildContent(theme, primaryAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isDarkMode, Color primaryAccent) {
    return Container(
      width: 250,
      color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 50),
        itemCount: _tabs.length,
        itemBuilder: (context, index) => ListTile(
          leading: Icon(
            _icons[index],
            color: _selectedIndex == index
                ? primaryAccent
                : (isDarkMode ? Colors.white70 : Colors.black54),
          ),
          title: Text(
            _tabs[index],
            style: TextStyle(
              color: _selectedIndex == index
                  ? primaryAccent
                  : (isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          selected: _selectedIndex == index,
          selectedTileColor: primaryAccent.withOpacity(0.1),
          onTap: () {
            setState(() => _selectedIndex = index);
            if (MediaQuery.of(context).size.width <= 800)
              Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, Color primaryAccent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tabs[_selectedIndex],
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primaryAccent,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => Card(
              elevation: 2,
              color: theme.cardColor,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text("${_tabs[_selectedIndex]} Item ${index + 1}"),
                subtitle: const Text("Details for this item..."),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
