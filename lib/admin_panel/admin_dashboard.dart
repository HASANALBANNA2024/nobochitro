import 'package:flutter/material.dart';
import 'package:nobochitro/admin_panel/addons/addons_view.dart';
import 'package:nobochitro/admin_panel/campaigns/campaigns_view.dart';
import 'package:nobochitro/admin_panel/packages/package_view.dart';
import 'package:nobochitro/admin_panel/payment_verifications/payment_dashboard.dart';
import 'package:nobochitro/admin_panel/photographers/photographer_view.dart';
import 'package:nobochitro/admin_panel/reviews/reviews_view.dart';
import 'package:nobochitro/screens/dashboard_screen.dart';

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
    "Campaigns",
    "Reviews",
    "Addons",
  ];
  final List<IconData> _icons = [
    Icons.grid_view,
    Icons.camera_alt,
    Icons.payment,
    Icons.star,
    Icons.campaign_outlined,
    Icons.add_circle_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryAccent = isDarkMode
        ? const Color(0xFFD4AF37)
        : const Color(0xFF008080);

    /// safe area
    bool isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      // appBar: buildCustomAppBar(context, primaryAccent, "Admin Dashboard"),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Admin Dashboard"),
        leading: IconButton(
          onPressed: () {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DashboardScreen(
                  onThemeChanged: (value) {
                    print("Theme changed to: $value");
                  },
                ),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),

      bottomNavigationBar: isLargeScreen
          ? null
          : _buildBottomNavBar(isDarkMode, primaryAccent),
      body: Row(
        children: [
          if (isLargeScreen) _buildSidebar(isDarkMode, primaryAccent),
          Expanded(
            child: SafeArea(
              // SafeArea
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: _getSelectedWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSelectedWidget() {
    return IndexedStack(
      index: _selectedIndex,
      children: const [
        PackagesView(),
        PhotographerView(),
        PaymentDashboard(),
        CampaignsView(),
        ReviewsView(),
        AddonsView(),
      ],
    );
  }

  Widget _buildSidebar(bool isDarkMode, Color primaryAccent) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDarkMode ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: ListView.builder(
        itemCount: _tabs.length,
        itemBuilder: (context, index) => ListTile(
          leading: Icon(
            _icons[index],
            color: _selectedIndex == index
                ? primaryAccent
                : (isDarkMode ? Colors.white54 : Colors.black54),
          ),
          title: Text(
            _tabs[index],
            style: TextStyle(
              color: _selectedIndex == index ? primaryAccent : null,
            ),
          ),
          onTap: () => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(bool isDarkMode, Color primaryAccent) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      selectedItemColor: primaryAccent,
      unselectedItemColor: isDarkMode ? Colors.white54 : Colors.black54,
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      type: BottomNavigationBarType.fixed,
      items: List.generate(
        _tabs.length,
        (i) => BottomNavigationBarItem(icon: Icon(_icons[i]), label: _tabs[i]),
      ),
    );
  }
}
