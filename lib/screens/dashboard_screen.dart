import 'package:flutter/material.dart';
import 'package:nobochitro/booking_summary_screen/my_booking_screen.dart';
import 'package:nobochitro/campaign_banner/n8n_dynamic_banner.dart';
import 'package:nobochitro/categories_grid/categories_grid.dart';
import 'package:nobochitro/client_profile/client_profile_screen.dart';
import 'package:nobochitro/community_gallery/community_gallery.dart';
import 'package:nobochitro/photographer_section/photographer_section.dart';
import 'package:nobochitro/photography_package/photography_packages.dart';
import 'package:nobochitro/responsive_review_list/responsive_review_list.dart';
import 'package:nobochitro/settings/settings_utils.dart';
import 'package:nobochitro/widgets/custom_bottom_nav.dart';
import 'package:nobochitro/widgets/custom_header.dart';
import 'package:nobochitro/widgets/custom_side_navigation.dart';

class DashboardScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const DashboardScreen({super.key, required this.onThemeChanged});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // drawer open control
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryAccent = isDarkMode
        ? const Color(0xFFD4AF37)
        : const Color(0xFF008080);
    final background = isDarkMode
        ? const Color(0xFF0F0F0F)
        : theme.scaffoldBackgroundColor;

    bool isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: background,

      // ৫২ নম্বর লাইনের কোডটি এভাবে পরিবর্তন করুন:
      drawer: CustomSideNavigation(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          // আইটেম সিলেক্ট করলে যেন ড্রয়ারটি অটো বন্ধ হয়ে যায়
          Navigator.pop(context);
        },
        onSettingsPressed: () {
          // ড্রয়ার খোলা থাকলে বন্ধ করবে
          if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
            Navigator.pop(context);
          }
          SettingsUtils.showSettings(
            context,
            primaryAccent,
            widget.onThemeChanged,
          );
        },
        onThemeChanged: (isDark) {
          widget.onThemeChanged(isDark);
        },
      ),
      body: Column(
        children: [
          CustomHeader(
            primaryAccent: primaryAccent,
            onMenuPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          Expanded(
            child: _buildMainContent(
              textTheme,
              colorScheme,
              isLargeScreen,
              primaryAccent,
              theme,
            ),
          ),
        ],
      ),

      bottomNavigationBar: isLargeScreen
          ? null
          : CustomBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index == 4) {
                  // Open settings bottom sheet for mobile view
                  SettingsUtils.showSettings(
                    context,
                    primaryAccent,
                    widget.onThemeChanged,
                  );
                } else if (index == 2) {
                  // Direct navigation to My Booking Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyBookingScreen(
                        primaryAccent: primaryAccent,
                        selectedIndex: _currentIndex, // Pass current state
                        onDestinationSelected: (idx) {
                          setState(() => _currentIndex = idx);
                        },
                        onThemeChanged: widget.onThemeChanged,
                        onSettingsPressed: () {
                          SettingsUtils.showSettings(
                            context,
                            primaryAccent,
                            widget.onThemeChanged,
                          );
                        },
                      ),
                    ),
                  );
                }
                else if(index == 3){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=> ClientProfileScreen() ));
                }else {
                  // Regular index update for Home and Packages
                  setState(() => _currentIndex = index);
                }
              },
            ),
    );
  }

  // --- UI Methods (No Logic Change) ---
  Widget _buildMainContent(
    TextTheme textTheme,
    ColorScheme colorScheme,
    bool isLargeScreen,
    Color primaryAccent,
    ThemeData theme,
  ) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // n8n banner dart file call
                  N8nDynamicBanner(
                    primaryAccent: primaryAccent,
                    onBookingClick: () {
                      print("Booking session clicked!");
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Explore Categories',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CategoriesGrid(primaryAccent: primaryAccent),
                  const SizedBox(height: 20),
                  PhotographyPackages(primaryAccent: primaryAccent),
                  const SizedBox(height: 20),
                  PhotographerSection(primaryAccent: primaryAccent),
                  const SizedBox(height: 20),
                  CommunityGallery(
                    primaryAccent: primaryAccent,
                    sectionTitle: "Community Highlights",
                  ),
                  const SizedBox(height: 20),
                  ResponsiveReviewList(
                    primaryAccent: primaryAccent,
                    sectionTitle: "Client Testimonials",
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
