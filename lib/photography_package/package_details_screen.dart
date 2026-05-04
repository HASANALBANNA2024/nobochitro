import 'package:flutter/material.dart';
import 'package:nobochitro/widgets/custom_appbar.dart'; // আপনার তৈরি অ্যাপবার ফাইল

class PackageDetailsScreen extends StatelessWidget {
  final Color primaryAccent;
  const PackageDetailsScreen({super.key, required this.primaryAccent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: buildCustomAppBar(context, primaryAccent, "Package Details"),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ), // ওয়েব ভিউ এর জন্য ১১০০ পিক্সেল
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ১. হিরো সেকশন (ইমেজ + টাইটেল + প্রাইস)
                _buildHeroSection(theme, isDark),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Infographic Checklist",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // ২. চেক লিস্ট সেকশন
                      _buildChecklist(theme, isDark),

                      const SizedBox(height: 30),
                      const Text(
                        "Package Comparison Table",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // ৩. কম্পারিজন টেবিল (রেসপনসিভ)
                      _buildComparisonTable(theme, isDark, screenWidth),

                      const SizedBox(height: 30),
                      const Text(
                        "Booking & Customization",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Add-ons",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 10),

                      // ৪. অ্যাড-অনস (Wrap ব্যবহার করা হয়েছে যাতে ওভারফ্লো না হয়)
                      _buildAddOns(theme, isDark),

                      const SizedBox(height: 40),

                      // ৫. বুক নাও বাটন
                      _buildBookNowButton(theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- হিরো সেকশন উইজেট ---
  Widget _buildHeroSection(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage(
            "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?fit=crop&w=1200",
          ),
          fit: BoxFit.cover,
        ),
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
            const Text(
              "Royal Wedding Package",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "৳95,000",
              style: TextStyle(
                color: primaryAccent,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ইনক্লুডেড সার্ভিসেস চেকলিস্ট ---
  Widget _buildChecklist(ThemeData theme, bool isDark) {
    final List<Map<String, dynamic>> items = [
      {
        "icon": Icons.camera_alt_rounded,
        "label": "100+ High-Res Retouched Photos",
      },
      {"icon": Icons.videocam_rounded, "label": "4K Video Highlights (5 mins)"},
      {"icon": Icons.hourglass_bottom_rounded, "label": "8 Hours Coverage"},
      {
        "icon": Icons.calendar_month_rounded,
        "label": "Complimentary Pre-Wedding Session",
      },
      {"icon": Icons.menu_book_rounded, "label": "Premium Wedding Album"},
    ];

    return Column(
      children: items
          .map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(item['icon'], color: primaryAccent, size: 22),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      item['label'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // --- কম্পারিজন টেবিল ---
  Widget _buildComparisonTable(ThemeData theme, bool isDark, double width) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: width < 600 ? 20 : 40,
        headingRowColor: WidgetStateProperty.all(
          primaryAccent.withOpacity(0.1),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        columns: const [
          DataColumn(label: Text('Features')),
          DataColumn(label: Text('Silver')),
          DataColumn(label: Text('Gold')),
          DataColumn(label: Text('Royal')),
        ],
        rows: const [
          DataRow(
            cells: [
              DataCell(Text('Photos')),
              DataCell(Text('100+')),
              DataCell(Text('200+')),
              DataCell(Text('Unlimited')),
            ],
          ),
          DataRow(
            cells: [
              DataCell(Text('Video')),
              DataCell(Text('HD')),
              DataCell(Text('4K')),
              DataCell(Text('4K/Cinema')),
            ],
          ),
          DataRow(
            cells: [
              DataCell(Text('Album')),
              DataCell(Icon(Icons.close, color: Colors.red, size: 16)),
              DataCell(Icon(Icons.check, color: Colors.green, size: 16)),
              DataCell(Icon(Icons.check, color: Colors.green, size: 16)),
            ],
          ),
        ],
      ),
    );
  }

  // --- অ্যাড-অনস সেকশন ---
  Widget _buildAddOns(ThemeData theme, bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _addonChip("Drone Shot +৳5,000", isDark),
        _addonChip("Extra Album +৳10,000", isDark),
        _addonChip("Extra Cinematographer +৳8,000", isDark),
      ],
    );
  }

  Widget _addonChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- বুক নাও বাটন ---
  Widget _buildBookNowButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Book Now",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
