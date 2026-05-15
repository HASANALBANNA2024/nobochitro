import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:nobochitro/booking_summary_screen/booking_summary_screen.dart';
import 'package:nobochitro/widgets/custom_appbar.dart';

class PackageDetailsScreen extends StatefulWidget {
  final Color primaryAccent;
  final Map<String, dynamic> packageData; // ডাটাবেস থেকে আসা মেইন ডাটা

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

  // একই ক্যাটাগরির Min, Mid, Max প্রাইসের প্যাকেজগুলো লোড করা
  Future<void> _loadComparisonData() async {
    try {
      final String category = widget.packageData['category'] ?? "";
      // ডাটাবেস থেকে ওই ক্যাটাগরির সব ডাটা নিয়ে আসা
      final allInCategory = await DatabaseHelper.instance.getPackagesByCategory(
        category,
      );

      if (allInCategory.isNotEmpty) {
        // দাম অনুযায়ী ছোট থেকে বড় সর্ট করা
        allInCategory.sort(
          (a, b) => (double.tryParse(a['base_price'].toString()) ?? 0)
              .compareTo(double.tryParse(b['base_price'].toString()) ?? 0),
        );

        List<Map<String, dynamic>> temp = [];

        if (allInCategory.length >= 3) {
          temp.add(allInCategory.first); // সর্বনিম্ন (Min)
          temp.add(allInCategory[allInCategory.length ~/ 2]); // মাঝারি (Mid)
          temp.add(allInCategory.last); // সর্বোচ্চ (Max)
        } else {
          temp = allInCategory; // ৩টির কম থাকলে যা আছে তাই
        }

        setState(() {
          comparisonPackages = temp;
          isCompLoading = false; // লোডিং শেষ
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
                // ১. ডাইনামিক হিরো সেকশন (রিয়েল ইমেজ ও প্রাইস)
                _buildDynamicHero(pkg),

                const SizedBox(height: 25),
                _buildSectionTitle("Package Includes"),
                const SizedBox(height: 15),

                // ২. সিম্পল টেক্সট চেকলিস্ট (ফিচার কলাম থেকে)
                _buildSimpleChecklist(
                  pkg['features'] ?? "",
                  isDark,
                  widget.primaryAccent,
                ),

                const SizedBox(height: 30),
                _buildSectionTitle("Compare with Others"),
                const SizedBox(height: 15),

                // ৩. ডাইনামিক কম্প্যারিশন টেবিল
                isCompLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildComparisonTable(isDark, cardColor),

                const SizedBox(height: 30),
                _buildSectionTitle("Add Extra Services"),
                const SizedBox(height: 10),
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

  // ডাইনামিক হিরো কার্ড
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingSummaryScreen(
                    primaryAccent: widget.primaryAccent,
                    packageData: widget.packageData,
                  ),
                ),
              );
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

  // ২. সুন্দর ডাইনামিক টেবিল উইজেট
  Widget _buildComparisonTable(bool isDark, Color cardColor) {
    // যদি লোডিং হয় তবে সার্কেল দেখাবে
    if (isCompLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // যদি ডাটা না থাকে
    if (comparisonPackages.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("No other packages to compare in this category."),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: DataTable(
          columnSpacing: 10,
          horizontalMargin: 10,
          headingRowColor: WidgetStateProperty.all(
            widget.primaryAccent.withOpacity(0.1),
          ),
          columns: [
            const DataColumn(
              label: Text(
                'Feature',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            ...comparisonPackages.map(
              (pkg) => DataColumn(
                label: Expanded(
                  child: Text(
                    pkg['title'].toString().split(' ')[0], // ছোট নাম
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
          rows: [
            // রো ১: প্রাইস
            DataRow(
              cells: [
                const DataCell(
                  Text(
                    "Price",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                ...comparisonPackages.map(
                  (pkg) => DataCell(
                    Text(
                      "৳${pkg['base_price']}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: widget.primaryAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // রো ২: ফিচারের সংখ্যা (সিম্পল করার জন্য)
            DataRow(
              cells: [
                const DataCell(
                  Text(
                    "Extras",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                ...comparisonPackages.map((pkg) {
                  int count = pkg['features'].toString().split(',').length;
                  return DataCell(
                    Text(
                      "$count Features",
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                }),
              ],
            ),
            // base hours
            DataRow(
              cells: [
                const DataCell(
                  Text(
                    "Time",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                ...comparisonPackages.map((pkg) {
                  int count = pkg['base_hours'].toString().split(',').length;
                  return DataCell(
                    Text("$count hours", style: const TextStyle(fontSize: 11)),
                  );
                }),
              ],
            ),
            // রো ৩: স্ট্যাটাস
            DataRow(
              cells: [
                const DataCell(
                  Text(
                    "Level",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                ...List.generate(comparisonPackages.length, (index) {
                  return DataCell(
                    Icon(
                      index == 0
                          ? Icons.trending_up
                          : (index == 1
                                ? Icons.auto_awesome
                                : Icons.workspace_premium),
                      size: 16,
                      color: widget.primaryAccent.withOpacity(0.7),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
