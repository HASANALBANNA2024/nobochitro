import 'package:flutter/material.dart';
import 'package:nobochitro/widgets/custom_appbar.dart';
import 'package:nobochitro/widgets/addOns_selector.dart';

// এখান থেকে StatefulWidget শুরু
class PackageDetailsScreen extends StatefulWidget {
  final Color primaryAccent;
  final Map<String, dynamic> packageData;

  const PackageDetailsScreen({
    super.key,
    required this.primaryAccent,
    required this.packageData,
  });

  @override
  State<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends State<PackageDetailsScreen> {
  // লজিক এবং স্টেট ভেরিয়েবল এখানে থাকবে
  List<Map<String, dynamic>> selectedAddons = [];
  double totalAddonsPrice = 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF252525) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: buildCustomAppBar(context, widget.primaryAccent, "Package Details"),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                _buildHeroCard(widget.primaryAccent),

                const SizedBox(height: 25),
                const Text(
                  "Infographic Checklist",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Checklist Section
                _buildDetailedChecklist(isDark, cardColor, widget.primaryAccent),

                const SizedBox(height: 30),
                const Text(
                  "Package Comparison Table",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Comparison Table
                _buildComparisonCard(isDark, cardColor, widget.primaryAccent),

                const SizedBox(height: 15),

                // Add ons Section
                const Text(
                  "Extra Service (Exclusive)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // AddOnsSelector Call
                AddOnsSelector(
                  onSelectionChanged: (newList) {
                    setState(() {
                      selectedAddons = newList; // লিস্টটি আপডেট করা হচ্ছে
                      totalAddonsPrice = newList.fold(
                          0.0,
                              (sum, item) => sum + (double.tryParse(item['price'].toString()) ?? 0.0)
                      );
                    });
                    print("সিলেক্ট করা হয়েছে: ${selectedAddons.length} টি আইটেম");
                    print("মোট খরচ: ৳$totalAddonsPrice");
                  },
                ),

                const SizedBox(height: 40),

                // Book Now Button
                _buildBookButton(widget.primaryAccent),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- হিরো কার্ড ---
  Widget _buildHeroCard(Color accent) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage(
            "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800",
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
            colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Royal Wedding Package",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "৳95,000",
              style: TextStyle(
                color: accent,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Checklist Section ---
  Widget _buildDetailedChecklist(bool isDark, Color cardColor, Color accent) {
    final List<Map<String, dynamic>> items = [
      {"icon": Icons.camera_alt_rounded, "label": "100+ High-Res Retouched Photos", "color": Colors.deepPurple},
      {"icon": Icons.videocam_rounded, "label": "4K Video Highlights (5 mins)", "color": Colors.indigo},
      {"icon": Icons.hourglass_bottom_rounded, "label": "8 Hours Coverage Album", "color": Colors.orange},
      {"icon": Icons.calendar_month_rounded, "label": "Complimentary Pre-Wedding Session", "color": Colors.pink},
      {"icon": Icons.menu_book_rounded, "label": "Premium Wedding Album", "color": Colors.red},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWideScreen ? 2 : 1,
            crossAxisSpacing: 15,
            mainAxisSpacing: 12,
            mainAxisExtent: 75,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item['color'].withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item['icon'], color: item['color'], size: 20),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      item['label'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Comparison Table ---
  Widget _buildComparisonCard(bool isDark, Color cardColor, Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: DataTable(
          headingRowHeight: 60,
          horizontalMargin: 15,
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(isDark ? Colors.white.withOpacity(0.02) : Colors.grey[50]),
          columns: const [
            DataColumn(label: Text('')),
            DataColumn(label: Text('Royal\nWedding', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Silver\nPackage', textAlign: TextAlign.center, style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('Gold\nPackage', textAlign: TextAlign.center, style: TextStyle(fontSize: 12))),
          ],
          rows: [
            _buildDataRow('Photos', '100+', '200+', '100+', true, isDark),
            _buildDataRow('8 Hours', '8', '5', '8', false, isDark),
            _buildDataRow('Video', '4K', 'Medium', 'High', false, isDark),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String feature, String v1, String v2, String v3, bool isFirst, bool isDark) {
    return DataRow(
      cells: [
        DataCell(Text(feature, style: const TextStyle(fontSize: 13, color: Colors.grey))),
        DataCell(Container(
          alignment: Alignment.center,
          color: isDark ? Colors.deepPurple.withOpacity(0.1) : Colors.deepPurple.withOpacity(0.05),
          child: Text(v1, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        )),
        DataCell(Center(child: Text(v2, style: const TextStyle(fontSize: 13)))),
        DataCell(Center(child: Text(v3, style: const TextStyle(fontSize: 13)))),
      ],
    );
  }

  // --- Book Now Button ---
  Widget _buildBookButton(Color accent) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // এখানে selectedAddons এবং totalAddonsPrice ব্যবহার করে পরবর্তী ধাপে যেতে পারবেন
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6342E8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: const Text("Book Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}