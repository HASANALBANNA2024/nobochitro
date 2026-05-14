import 'package:flutter/material.dart';
import 'package:nobochitro/community_gallery/community_gallery.dart';
import 'package:nobochitro/photography_package/package_details_screen.dart';
import 'package:nobochitro/responsive_review_list/responsive_review_list.dart';

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
  final List<String> filters = [
    'Top Packages', 'Cinematic', 'Pre-Wedding', 'Reception', 'Budget-friendly', 'Premium'
  ];

  final String categoryCover = "https://images.unsplash.com/photo-1519741497674-611481863552?w=800";

  final List<String> popularSessions = [
    'Traditional Portrait', 'Candid Moments', 'Cinematic Story', 'Aerial/Drone Shot'
  ];

  final List<Map<String, dynamic>> packages = [
    {
      'title': 'Royal Wedding Collection with Cinematic Video & Drone',
      'price': '95,000',
      'rating': 4.9,
      'reviews': 120,
      'image': 'https://images.unsplash.com/photo-1519741497674-611481863552?w=400',
      'features': ['🎥 4K Video', '📸 300 Photos', '⏳ 12 Hours Coverage', '📔 Premium Album', '🚁 Drone Shot', '🎬 Teaser Video'],
    },
    {
      'title': 'Standard Engagement Session',
      'price': '30,000',
      'rating': 4.7,
      'reviews': 85,
      'image': 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400',
      'features': ['🎥 HD Video', '📸 150 Photos', '⏳ 6 Hours Coverage'],
    },
  ];

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
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border_rounded, size: 22, color: Colors.grey)),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCoverPhoto(isWeb),
                const SizedBox(height: 15),
                _buildFilterChips(isDark),
                const SizedBox(height: 25),
                _buildSectionTitle(theme, Icons.star_border_rounded, "Popular Session Types"),
                const SizedBox(height: 10),
                _buildPopularSessions(isDark),
                const SizedBox(height: 30),
                _buildSectionTitle(theme, Icons.card_giftcard_rounded, "Exclusive Packages"),
                const SizedBox(height: 15),
                _buildPackageList(isWeb, isTablet, isDark, widget.primaryAccent),
                const SizedBox(height: 30),
                CommunityGallery(primaryAccent: widget.primaryAccent, sectionTitle: "Portfolio Showcase"),
                const SizedBox(height: 15),
                ResponsiveReviewList(primaryAccent: widget.primaryAccent, sectionTitle: "Client Reviews"),
                const SizedBox(height: 30),
                _buildRequestQuoteSection(),
              ],
            ),
          ),
        ),
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

  Widget _buildCoverPhoto(bool isWeb) {
    return Container(
      width: double.infinity,
      height: isWeb ? 300 : 200,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: NetworkImage(categoryCover), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.categoryName} Photography", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Capture every moment beautifully", style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
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

  Widget _buildPopularSessions(bool isDark) {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: popularSessions.length,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(15),
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          ),
          child: Center(child: Text(popularSessions[index], style: const TextStyle(fontSize: 11, color: Colors.grey))),
        ),
      ),
    );
  }

  Widget _buildPackageList(bool isWeb, bool isTablet, bool isDark, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = isWeb ? 3 : (isTablet ? 2 : 1);
          double spacing = 15.0;
          double itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: packages.map((pkg) {
              return SizedBox(
                width: itemWidth,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        pkg['image'],
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 160,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    pkg['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "৳${pkg['price']}",
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "${pkg['rating']} (${pkg['reviews']} Reviews)",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: (pkg['features'] as List<String>).map((f) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  f,
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )).toList(),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PackageDetailsScreen(
                                        primaryAccent: widget.primaryAccent,
                                        packageData: pkg, // এখানে pkg (Map) পাস করা হয়েছে
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "View Details & Book",
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildRequestQuoteSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6342E8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Request Custom Quote", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}