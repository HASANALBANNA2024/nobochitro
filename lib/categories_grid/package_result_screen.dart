import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart'; // আপনার ডাটাবেস পাথ
import 'package:nobochitro/community_gallery/community_gallery.dart';
import 'package:nobochitro/photography_package/package_details_screen.dart';
import 'package:nobochitro/responsive_review_list/responsive_review_list.dart';
import 'package:nobochitro/categories_grid/package_card.dart';

class PackageResultScreen extends StatefulWidget {
  final String categoryName;
  final Color primaryAccent;
  final String package;

  const PackageResultScreen({
    super.key,
    required this.categoryName,
    required this.primaryAccent,
    required this.package,
  });

  @override
  State<PackageResultScreen> createState() => _PackageResultScreenState();
}

class _PackageResultScreenState extends State<PackageResultScreen> {
  String selectedFilter = 'Top Packages';
  // আপনার চাহিদা অনুযায়ী ফিল্টার লিস্ট
  final List<String> filters = [
    'Top Packages', 'Premium', 'Platinum', 'Gold', 'Diamond', 'Budget-friendly'
  ];

  late Future<List<Map<String, dynamic>>> _packageFuture;

  // ব্যানারের ইমেজের জন্য স্লাইডার লজিক
  int _bannerIndex = 0;
  Timer? _bannerTimer;
  List<String> _bannerImages = [];

  @override
  void initState() {
    super.initState();
    // ডাটাবেস থেকে ওই ক্যাটাগরির ডাটা ফেচ করা
    _packageFuture = DatabaseHelper.instance.getPackagesByCategory(widget.categoryName);
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerImages.isNotEmpty) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    bool isWeb = screenWidth > 900;
    bool isTablet = screenWidth > 600 && screenWidth <= 900;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "${widget.categoryName} Photography",
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _packageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Packages Found"));
          }

          final allPackages = snapshot.data!;
          // ব্যানারের জন্য সব প্যাকেজের ইমেজ সংগ্রহ করা
          _bannerImages = allPackages.map((e) => e['image_url'].toString()).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDynamicBanner(isWeb),
                    const SizedBox(height: 15),
                    _buildFilterChips(isDark),
                    const SizedBox(height: 25),
                    _buildSectionTitle(theme, Icons.star_border_rounded, "Popular Session Types"),
                    const SizedBox(height: 10),
                    // ডাইনামিক টাইটেল লিস্ট
                    _buildPopularSessions(isDark, allPackages),
                    const SizedBox(height: 30),
                    _buildSectionTitle(theme, Icons.card_giftcard_rounded, "Exclusive Packages"),
                    const SizedBox(height: 15),
                    // রিয়েল ডাটা দিয়ে প্যাকেজ লিস্ট
                    _buildPackageList(allPackages, isWeb, isTablet, isDark),
                    const SizedBox(height: 30),
                    // সব ইমেজ দিয়ে পোর্টফোলিও শো-কেস গ্রিড
                    CommunityGallery(
                      primaryAccent: widget.primaryAccent,
                      sectionTitle: "Portfolio Showcase",
                    ),
                    const SizedBox(height: 15),
                    ResponsiveReviewList(primaryAccent: widget.primaryAccent, sectionTitle: "Client Reviews"),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ব্যানারে ইমেজ লুপ হবে
  Widget _buildDynamicBanner(bool isWeb) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: Container(
        key: ValueKey<int>(_bannerIndex),
        width: double.infinity,
        height: isWeb ? 350 : 220,
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
              image: NetworkImage(_bannerImages.isNotEmpty ? _bannerImages[_bannerIndex] : ""),
              fit: BoxFit.cover
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)]
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${widget.categoryName} Special", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const Text("Explore our top rated sessions", style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  // পপুলার সেশনে ওই ক্যাটাগরির প্যাকেজ টাইটেলগুলো আসবে
  Widget _buildPopularSessions(bool isDark, List<Map<String, dynamic>> pkgs) {
    final titles = pkgs.map((e) => e['title'].toString()).take(5).toList();
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: titles.length,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(15),
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          ),
          child: Center(child: Text(titles[index], style: const TextStyle(fontSize: 11, color: Colors.grey))),
        ),
      ),
    );
  }

  // প্যাকেজ কার্ডে ডাইনামিক ইমেজ লুপ করার জন্য একটি আলাদা উইজেট ব্যবহার করুন
  Widget _buildPackageList(List<Map<String, dynamic>> pkgs, bool isWeb, bool isTablet, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Wrap(
        spacing: 15,
        runSpacing: 15,
        children: pkgs.map((pkg) => PackageCard( // এখানে '_Package' এর বদলে 'PackageCard' হবে
          pkg: pkg,
          isDark: isDark,
          accent: widget.primaryAccent,
        )).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 18),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = filters[index] == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filters[index], style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.grey : Colors.black87), fontSize: 12)),
              selected: isSelected,
              selectedColor: widget.primaryAccent,
              onSelected: (val) => setState(() => selectedFilter = filters[index]),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}


