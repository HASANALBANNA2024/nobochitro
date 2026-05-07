import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nobochitro/booking_summary_screen/my_booking_screen.dart';
import 'package:nobochitro/campaign_banner/n8n_dynamic_banner.dart';
import 'package:nobochitro/categories_grid/categories_grid.dart';
import 'package:nobochitro/client_profile/client_profile_screen.dart';
import 'package:nobochitro/community_gallery/community_gallery.dart';
import 'package:nobochitro/photographer_section/photographer_section.dart';
import 'package:nobochitro/photography_package/photography_packages.dart';
import 'package:nobochitro/responsive_review_list/_review_sheet_widget.dart';
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
  bool _isReviewVisible = false;
  Timer? _reviewTimer;

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
      drawer: CustomSideNavigation(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          Navigator.pop(context);
        },
        onSettingsPressed: () {
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
      floatingActionButton: _buildWriteReviewButton(context, primaryAccent),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

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
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ClientProfileScreen()),
                  );
                } else if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardScreen(
                        onThemeChanged: widget.onThemeChanged,
                      ),
                    ),
                  );
                } else {
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
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                // vertical: 20,
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

  // review widget of review
  Widget _buildWriteReviewButton(BuildContext context, Color primaryAccent) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;

    return StatefulBuilder(
      builder: (context, setState) {
        // Timer settings
        _reviewTimer ??= Timer.periodic(const Duration(seconds: 10), (timer) {
          if (context.mounted) {
            setState(() => _isReviewVisible = true);
            Future.delayed(const Duration(seconds: 10), () {
              if (context.mounted) {
                setState(() => _isReviewVisible = false);
              }
            });
          }
        });

        return AnimatedOpacity(
          opacity: _isReviewVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 800),
          child: AnimatedSlide(
            offset: _isReviewVisible ? Offset.zero : const Offset(-0.5, 0),
            duration: const Duration(milliseconds: 800),
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: InkWell(
                onTap: () => ReviewService.showReviewSheet(context),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: primaryAccent,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.rate_review_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Write Review",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
