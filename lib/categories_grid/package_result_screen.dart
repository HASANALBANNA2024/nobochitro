import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:nobochitro/categories_grid/package_card.dart';
import 'package:nobochitro/categories_grid/universal_filter_chips.dart';
import 'package:nobochitro/community_gallery/community_gallery.dart';
import 'package:nobochitro/responsive_review_list/responsive_review_list.dart';

class PackageResultScreen extends StatefulWidget {
  final String categoryName;
  final Color primaryAccent;

  const PackageResultScreen({
    super.key,
    required this.categoryName,
    required this.primaryAccent,
    required String package, // কনস্ট্রাক্টরে এটি থাকছে আপনার রিকোয়েস্ট অনুযায়ী
  });

  @override
  State<PackageResultScreen> createState() => _PackageResultScreenState();
}

class _PackageResultScreenState extends State<PackageResultScreen> {
  String selectedFilter = 'All';

  late Future<List<Map<String, dynamic>>> _packageFuture;
  int _bannerIndex = 0;
  Timer? _bannerTimer;
  List<String> _bannerImages = [];

  @override
  void initState() {
    super.initState();
    // database safely call
    _packageFuture = DatabaseHelper.instance.getPackagesByCategory(
      widget.categoryName,
    );
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerImages.isNotEmpty && mounted) {
        setState(() {
          _bannerIndex = (_bannerIndex + 1) % _bannerImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  // --- cash prof filtering (Safe Typecasting) ---
  List<Map<String, dynamic>> _applyFilter(
    List<Map<String, dynamic>> allPackages,
  ) {
    if (selectedFilter == 'All') return allPackages;

    return allPackages.where((pkg) {
      // base_price ফিল্ডটিকে নিরাপদে ডাবল-এ রূপান্তর
      final dynamic rawPrice = pkg['base_price'];
      double price = 0.0;

      if (rawPrice != null) {
        if (rawPrice is num) {
          price = rawPrice.toDouble();
        } else if (rawPrice is String) {
          price = double.tryParse(rawPrice) ?? 0.0;
        }
      }

      switch (selectedFilter) {
        case 'Budget-friendly':
          return price < 8000;
        case 'Standard':
          return price >= 8000 && price < 15000;
        case 'Gold':
          return price >= 15000 && price < 25000;
        case 'Platinum':
          return price >= 25000 && price < 40000;
        case 'Diamond':
          return price >= 40000 && price < 60000;
        case 'Premium':
          return price >= 60000;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 900;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "${widget.categoryName} Packages",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _packageFuture,
        builder: (context, snapshot) {
          // ১. লোডিং স্টেট
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ২. এরর স্টেট
          if (snapshot.hasError) {
            return _buildStatusState("Something went wrong. Please try again.");
          }

          // ৩. ডাটা না পাওয়ার স্টেট
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildStatusState("No packages found in this category.");
          }

          final allPackages = snapshot.data!;
          final filteredPackages = _applyFilter(allPackages);

          // ব্যানার ইমেজ লিস্ট তৈরি (null চেক সহ)
          _bannerImages =
              (filteredPackages.isNotEmpty ? filteredPackages : allPackages)
                  .map((e) => e['image_url']?.toString() ?? "")
                  .where((url) => url.isNotEmpty)
                  .toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildDynamicBanner(isWeb),
                    const SizedBox(height: 20),

                    UniversalFilterChips(
                      accentColor: widget.primaryAccent,
                      onSelected: (value) {
                        setState(() {
                          selectedFilter =
                              value; // শুধু এই এক লাইনে আপনার ফিল্টার আপডেট হবে
                        });
                      },
                    ),
                    const SizedBox(height: 25),
                    _buildSectionTitle(
                      theme,
                      Icons.star_outline_rounded,
                      "Popular Session Types",
                    ),
                    const SizedBox(height: 12),
                    _buildPopularSessions(isDark, filteredPackages),
                    const SizedBox(height: 30),
                    _buildSectionTitle(
                      theme,
                      Icons.auto_awesome_mosaic_outlined,
                      "Exclusive Packages",
                    ),
                    const SizedBox(height: 15),

                    // ফিল্টার করার পর ডাটা না থাকলে সুন্দর মেসেজ
                    filteredPackages.isEmpty
                        ? _buildNoDataMessage(isDark)
                        : _buildPackageList(filteredPackages, isDark),

                    const SizedBox(height: 40),
                    CommunityGallery(
                      primaryAccent: widget.primaryAccent,
                      sectionTitle: "Portfolio Showcase",
                    ),
                    const SizedBox(height: 20),
                    ResponsiveReviewList(
                      primaryAccent: widget.primaryAccent,
                      sectionTitle: "${widget.categoryName} Highlights",
                      filterCategoryName: widget.categoryName,
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- ডাটা না থাকলে ইউজারকে দেখানোর জন্য ---
  Widget _buildNoDataMessage(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 50,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 15),
          Text(
            "Sorry, no $selectedFilter packages available.",
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
          ),
          TextButton(
            onPressed: () => setState(() => selectedFilter = 'All'),
            child: Text(
              "View All",
              style: TextStyle(color: widget.primaryAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusState(String msg) {
    return Center(
      child: Text(msg, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildDynamicBanner(bool isWeb) {
    return Container(
      width: double.infinity,
      height: isWeb ? 380 : 220,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          child: Stack(
            key: ValueKey<int>(_bannerIndex),
            fit: StackFit.expand,
            children: [
              _bannerImages.isNotEmpty
                  ? Image.network(
                      _bannerImages[_bannerIndex],
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) =>
                          Container(color: Colors.grey[900]),
                    )
                  : Container(color: Colors.grey[900]),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.categoryName} Special",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Handpicked premium sessions for you",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularSessions(bool isDark, List<Map<String, dynamic>> pkgs) {
    if (pkgs.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: pkgs.length,
        itemBuilder: (context, index) {
          // টাইটেল ফেচিং-এ নাল সেফটি
          final title = pkgs[index]['title']?.toString() ?? "Package";
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.primaryAccent.withOpacity(0.3)),
              color: widget.primaryAccent.withOpacity(0.05),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPackageList(List<Map<String, dynamic>> pkgs, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Wrap(
        spacing: 15,
        runSpacing: 20, // আপনার উল্লিখিত সমস্যা সমাধানে ভার্টিক্যাল গ্যাপ
        children: pkgs
            .map(
              (pkg) => PackageCard(
                pkg: pkg,
                isDark: isDark,
                accent: widget.primaryAccent,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Icon(icon, color: widget.primaryAccent, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
