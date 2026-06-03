import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:nobochitro/booking_summary_screen/booking_summary_screen.dart';
import 'package:nobochitro/photography_package/package_comparison_table.dart';
import 'package:nobochitro/widgets/custom_appbar.dart';

import '../authentication/login_screen.dart';
import '../community_gallery/community_gallery.dart';

class PackageDetailsScreen extends StatefulWidget {
  final Color primaryAccent;
  final Map<String, dynamic> packageData;

  /// to load main data from database

  const PackageDetailsScreen({
    super.key,
    required this.primaryAccent,
    required this.packageData,
  });

  @override
  State<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends State<PackageDetailsScreen> {
  List<Map<String, dynamic>> selectedAddons = [];
  double totalAddonsPrice = 0.0;
  List<Map<String, dynamic>> comparisonPackages = [];
  bool isCompLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComparisonData();
  }

  /// same package to load max,min, mid level of price
  Future<void> _loadComparisonData() async {
    try {
      final String category = widget.packageData['category'] ?? "";

      /// to receive data from database
      final allInCategory = await DatabaseHelper.instance.getPackagesByCategory(
        category,
      );

      if (allInCategory.isNotEmpty) {
        /// to sorting of price
        allInCategory.sort(
          (a, b) => (double.tryParse(a['base_price'].toString()) ?? 0)
              .compareTo(double.tryParse(b['base_price'].toString()) ?? 0),
        );

        List<Map<String, dynamic>> temp = [];

        if (allInCategory.length >= 3) {
          temp.add(allInCategory.first);
          temp.add(allInCategory[allInCategory.length ~/ 2]);
          temp.add(allInCategory.last);
        } else {
          temp = allInCategory;
        }

        setState(() {
          comparisonPackages = temp;
          isCompLoading = false;
        });
      } else {
        setState(() => isCompLoading = false);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isCompLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF252525) : Colors.white;
    final pkg = widget.packageData;
    final String packageId = pkg['package_id'].toString();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      appBar: buildCustomAppBar(
        context,
        widget.primaryAccent,
        "Package Details",
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // dynamic hero
                _buildDynamicHero(pkg),

                const SizedBox(height: 25),
                _buildSectionTitle("Package Includes"),
                const SizedBox(height: 15),

                // simple check list of features
                _buildSimpleChecklist(
                  pkg['features'] ?? "",
                  isDark,
                  widget.primaryAccent,
                ),

                const SizedBox(height: 15),

                //
                PackageComparisonTable(
                  comparisonPackages: comparisonPackages,
                  isLoading: isCompLoading,
                  isDark: isDark,
                  cardColor: cardColor,
                  primaryAccent: widget.primaryAccent,
                ),

                const SizedBox(height: 20),
                CommunityGallery(
                  galleryFuture: DatabaseHelper.instance.getPackageGallery(
                    packageId,
                  ),
                  primaryAccent: Colors.blue,
                ),

                _buildBookButton(pkg),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  /// dynamic hero card
  Widget _buildDynamicHero(Map<String, dynamic> pkg) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(
            pkg['image_url'] ?? "https://via.placeholder.com/800",
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pkg['title'] ?? "Package Details",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "৳${pkg['base_price']}",
              style: TextStyle(
                color: widget.primaryAccent,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // সিম্পল লিস্ট স্টাইল চেকলিস্ট
  Widget _buildSimpleChecklist(String features, bool isDark, Color accent) {
    final List<String> items = features.split(',');
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: accent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.trim(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBookButton(Map<String, dynamic> pkg) {
    double finalPrice =
        (double.tryParse(pkg['base_price'].toString()) ?? 0) + totalAddonsPrice;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Total Estimate:",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              "৳$finalPrice",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: widget.primaryAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (FirebaseAuth.instance.currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingSummaryScreen(
                      primaryAccent: widget.primaryAccent,
                      packageData: widget.packageData,
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6342E8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              "Book Now",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
