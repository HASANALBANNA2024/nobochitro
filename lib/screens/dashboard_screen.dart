import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nobochitro/booking_summary_screen/my_booking_screen.dart';
import 'package:nobochitro/campaign_banner/n8n_dynamic_banner.dart';
import 'package:nobochitro/categories_grid/categories_grid.dart';
import 'package:nobochitro/client_profile/client_profile_screen.dart';
import 'package:nobochitro/community_gallery/community_gallery.dart';
import 'package:nobochitro/photographer_section/photographer_section.dart';
import 'package:nobochitro/photography_package/photography_packages.dart';
import 'package:nobochitro/responsive_review_list/responsive_review_list.dart';
import 'package:nobochitro/responsive_review_list/review_sheet_widget.dart';
import 'package:nobochitro/settings/settings_utils.dart';
import 'package:nobochitro/widgets/custom_bottom_nav.dart';
import 'package:nobochitro/widgets/custom_header.dart';
import 'package:nobochitro/widgets/custom_side_navigation.dart';

import '../authentication/login_screen.dart';

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
  Timer? _hideTimer; // 🟢 হাইড করার জন্য আরেকটি সেফ টাইমার মেমোরি

  // drawer open control
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // 🟢 টাইমার লজিকটি initState-এ নিয়ে আসা হলো যাতে স্ক্রিন লোড হতেই পারফেক্টলি কাজ শুরু করে
    _startReviewButtonTimer();
  }

  void _startReviewButtonTimer() {
    // প্রতি ২০ সেকেন্ডের লুপ (১০ সেকেন্ড শো থাকবে, ১০ সেকেন্ড হাইড থাকবে)
    _reviewTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted) {
        setState(() => _isReviewVisible = true); // ১০ সেকেন্ড পর শো হবে

        // ঠিক ১০ সেকেন্ড পর আবার বাটনটি সুন্দর অ্যানিমেশন দিয়ে হাইড হয়ে যাবে
        _hideTimer = Timer(const Duration(seconds: 10), () {
          if (mounted) {
            setState(() => _isReviewVisible = false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // 🛑 মেমোরি লিক এবং ব্যাকগ্রাউন্ড ক্র্যাশ রোধ করতে টাইমারগুলো ডিসপোজ করা হলো
    _reviewTimer?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          setState(() => _currentIndex = index);
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
        onThemeChanged: widget.onThemeChanged,
      ),
      body: Column(
        children: [
          CustomHeader(
            primaryAccent: primaryAccent,
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: _buildMainContent(
              theme.textTheme,
              theme.colorScheme,
              isLargeScreen,
              primaryAccent,
              theme,
            ),
          ),
        ],
      ),
      // 🟢 ফিক্সড বাটন কল
      floatingActionButton: _buildWriteReviewButton(context, primaryAccent),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

      bottomNavigationBar: isLargeScreen
          ? null
          : CustomBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index == 4) {
                  SettingsUtils.showSettings(
                    context,
                    primaryAccent,
                    widget.onThemeChanged,
                  );
                } else if (index == 2) {
                  if (FirebaseAuth.instance.currentUser != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyBookingScreen(
                          primaryAccent: primaryAccent,
                          selectedIndex: _currentIndex,
                          onDestinationSelected: (idx) =>
                              setState(() => _currentIndex = idx),
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
                  } else {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const LoginModalSheet(),
                    );
                  }
                } else if (index == 3) {
                  if (FirebaseAuth.instance.currentUser != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ClientProfileScreen(),
                      ),
                    );
                  } else {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const LoginModalSheet(),
                    );
                  }
                } else if (index == 0) {
                  // কারেন্ট স্ক্রিনেই থাকলে নতুন করে পুশ করার দরকার নেই, জাস্ট স্টেট রিসেট করলেই হয়
                  setState(() => _currentIndex = 0);
                } else {
                  setState(() => _currentIndex = index);
                }
              },
            ),
    );
  }

  // --- UI Methods ---
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  N8nDynamicBanner(
                    primaryAccent: primaryAccent,
                    onBookingClick: () => print("Booking session clicked!"),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Explore Categories',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  CategoriesGrid(primaryAccent: primaryAccent),
                  const SizedBox(height: 5),
                  PhotographyPackages(primaryAccent: primaryAccent),
                  const SizedBox(height: 5),
                  PhotographerSection(primaryAccent: primaryAccent),
                  const SizedBox(height: 5),
                  CommunityGallery(
                    primaryAccent: primaryAccent,
                    sectionTitle: "Community Highlights",
                  ),
                  const SizedBox(height: 5),
                  ResponsiveReviewList(
                    primaryAccent: primaryAccent,
                    sectionTitle: "Client Review With us",
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Clean and fixed review button
  Widget _buildWriteReviewButton(BuildContext context, Color primaryAccent) {
    return AnimatedOpacity(
      opacity: _isReviewVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: AnimatedSlide(
        offset: _isReviewVisible ? Offset.zero : const Offset(-0.3, 0),
        duration: const Duration(milliseconds: 600),
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: InkWell(
            onTap: () => ReviewService.showReviewSheet(context),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
  }
}
