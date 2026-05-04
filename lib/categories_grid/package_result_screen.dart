import 'package:flutter/material.dart';
import 'package:nobochitro/community_gallery/community_gallery.dart';
import 'package:nobochitro/responsive_review_list/responsive_review_list.dart';

class PackageResultScreen extends StatefulWidget {
  final String categoryName;
  final Color primaryAccent;

  const PackageResultScreen({
    super.key,
    required this.categoryName,
    required this.primaryAccent,
  });

  @override
  State<PackageResultScreen> createState() => _PackageResultScreenState();
}

class _PackageResultScreenState extends State<PackageResultScreen> {
  String selectedFilter = 'Top Packages';
  final List<String> filters = [
    'Top Packages',
    'Cinematic',
    'Pre-Wedding',
    'Reception',
    'Budget-friendly',
    'Premium'
  ];

  // --- নতুন ডাটা সেকশন ---

  // কভার ফটো (ডাইনামিক হতে পারে)
  final String categoryCover = "https://images.unsplash.com/photo-1519741497674-611481863552?w=800";

  // জনপ্রিয় সেশন/সাব-ক্যাটাগরি
  final List<String> popularSessions = [
    'Traditional Portrait',
    'Candid Moments',
    'Cinematic Story',
    'Aerial/Drone Shot'
  ];

  // ডামি ডাটা: প্যাকেজের জন্য (আরও ডিটেইলস যোগ করা হয়েছে)
  final List<Map<String, dynamic>> packages = [
    {
      'title': 'Royal Wedding Collection',
      'price': '৳95,000',
      'rating': 4.9,
      'reviews': 120,
      'image': 'https://images.unsplash.com/photo-1519741497674-611481863552?w=400',
      'features': ['🎥 4K Video', '📸 300 Photos', '⏳ 12 Hours Coverage', '📔 Premium Album', '🚁 Drone Shot'],
    },
    {
      'title': 'Engagement Session',
      'price': '৳30,000',
      'rating': 4.7,
      'reviews': 85,
      'image': 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400',
      'features': ['🎥 HD Video', '📸 150 Photos', '⏳ 6 Hours Coverage', '📔 Softcover Album'],
    },
    {
      'title': 'Pre-Wedding Story',
      'price': '৳45,000',
      'rating': 4.8,
      'reviews': 95,
      'image': 'https://images.unsplash.com/photo-1532712938310-34cb3982ef74?w=400',
      'features': ['🎥 Cinematic Video', '📸 200 Photos', '⏳ 8 Hours Coverage', '🚁 Drone Shot'],
    },
  ];

  // ডামি ডাটা: পোর্টফোলিও ছবির জন্য
  final List<String> portfolioImages = [
    'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=300',
    'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=300',
    'https://images.unsplash.com/photo-1591604466107-dd9ba63625a3?w=300',
    'https://images.unsplash.com/photo-1520854221256-17451cc331bf?w=300',
    'https://images.unsplash.com/photo-1532712938310-34cb3982ef74?w=300',
    'https://images.unsplash.com/photo-1519741497674-611481863552?w=300',
  ];

  // ডামি ডাটা: কাস্টমার রিভিউ
  final List<Map<String, dynamic>> reviews = [
    {'name': 'Anika Rahman', 'review': 'Amazing photography! The Royal Wedding package was worth every taka. Team was very professional.', 'rating': 5},
    {'name': 'Sajid Islam', 'review': 'Great work for our pre-wedding. Captured every moment beautifully.', 'rating': 5},
    {'name': 'Nabila Karim', 'review': 'Engagement photos came out perfect. Recommended!', 'rating': 4},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // রেসপনসিভ লজিক
    bool isWeb = screenWidth > 900;
    bool isTablet = screenWidth > 600 && screenWidth <= 900;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      // filed custom abbar ata autoname niye nibe
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        shape: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          "${widget.categoryName} Photography",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),

        //
        actions: [
          IconButton(
            onPressed: () {

            },
            icon: const Icon(
              Icons.favorite_border_rounded,
              size: 22,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover photo session
                    _buildCoverPhoto(screenWidth, isWeb, theme),

                    const SizedBox(height: 15),

                    _buildFilterChips(accentColor: widget.primaryAccent, isDark: isDark, theme: theme),
                    const SizedBox(height: 25),

                    // popular session
                    _buildSectionTitle(theme, Icons.star_border_rounded, "Popular Session Types"),
                    const SizedBox(height: 10),
                    _buildPopularSessions(isDark, theme),
                    const SizedBox(height: 30),

                    // package title
                    _buildSectionTitle(theme, Icons.card_giftcard_rounded, "Exclusive Packages"),
                    const SizedBox(height: 15),
                    _buildPackageList(isWeb, isTablet, isDark, theme, widget.primaryAccent),

                    const SizedBox(height: 30),
                    // portfolio section convert by community gallary ok
                    CommunityGallery(primaryAccent: widget.primaryAccent, sectionTitle: "Portfolio showcase",),
                    const SizedBox(height: 15),
                    ResponsiveReviewList(primaryAccent: widget.primaryAccent, sectionTitle: "Client Say about packages",),
                    const SizedBox(height: 15,),
                    _buildRequestQuoteSection(context),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- title widget ---
  Widget _buildSectionTitle(ThemeData theme, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  // --- cover photo widgets ---
  Widget _buildCoverPhoto(double width, bool isWeb, ThemeData theme) {
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.categoryName} Photography", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("Capture every moment beautifully", style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }



  // --- Filter Chips Widgets ---
  Widget _buildFilterChips({required Color accentColor, required bool isDark, required ThemeData theme}) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(filter, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.grey : Colors.black87), fontSize: 13)),
              selected: isSelected,
              selectedColor: accentColor,
              backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEEEEEE),
              showCheckmark: false,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.transparent)),
              onSelected: (bool selected) {
                setState(() {
                  selectedFilter = filter;
                });
              },
            ),
          );
        },
      ),
    );
  }

  // --- Popular session widgets ---
  Widget _buildPopularSessions(bool isDark, ThemeData theme) {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: popularSessions.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(20),
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            ),
            child: Center(
              child: Text(popularSessions[index], style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          );
        },
      ),
    );
  }

  // --- ৩. প্যাকেজ লিস্ট উইজেট (আপডেট করা হয়েছে: রেটিং এবং রিভিউ যোগ করা হয়েছে) ---
  Widget _buildPackageList(bool isWeb, bool isTablet, bool isDark, ThemeData theme, Color accent) {
    int crossAxisCount = isWeb ? 3 : (isTablet ? 2 : 1);
    double aspect = isWeb ? 0.95 : (isTablet ? 1.0 : 1.15); // আসপেক্ট রেশিও অ্যাডজাস্ট করা হয়েছে

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: aspect,
      ),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final pkg = packages[index];
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // প্যাকেজ ইমেজ
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  child: Image.network(pkg['image'], fit: BoxFit.cover, width: double.infinity),
                ),
              ),
              // প্যাকেজ ডিটেইলস
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(pkg['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          Text(pkg['price'], style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 17)),
                        ],
                      ),
                      // রেটিং যোগ করা হয়েছে
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text("${pkg['rating']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(" (${pkg['reviews']} Reviews)", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // ফিচার চিপস (Wrap ব্যবহার করা হয়েছে ওভারফ্লো এড়াতে)
                      Wrap(
                        spacing: 5, runSpacing: 5,
                        children: pkg['features'].map<Widget>((f) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: accent.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                          child: Text(f, style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w600)),
                        )).toList(),
                      ),
                      const SizedBox(height: 5),
                      // ডিটেইলস বাটন
                      SizedBox(
                        width: double.infinity, height: 35,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: accent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: const Text("View Details & Book", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)), // বাটন টেক্সট আপডেট
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

// --- Helper Widget quotes selection
  Widget _buildRequestQuoteSection(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15), // দুই পাশে একটু গ্যাপ
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          width: double.infinity,
          height: 52, // বাটনের উচ্চতা কিছুটা বাড়ানো হলো প্রিমিয়াম লুকের জন্য
          child: ElevatedButton(
            onPressed: () {
              // আপনার অ্যাকশন এখানে দিন
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6342E8), // আপনার সেই পার্পেল কালার
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // রাউন্ডেড কোণ
              ),
              elevation: 0, // কোনো শ্যাডো থাকবে না, একদম ফ্ল্যাট
            ),
            child: const Text(
              "Request Custom Quote",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }



}