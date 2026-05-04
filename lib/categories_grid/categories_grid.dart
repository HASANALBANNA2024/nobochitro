import 'package:flutter/material.dart';
// ১. আপনার প্রোজেক্টের সঠিক পাথ অনুযায়ী এটি ইম্পোর্ট করুন
import 'package:nobochitro/categories_grid/package_result_screen.dart';

class CategoriesGrid extends StatelessWidget {
  final Color primaryAccent;

  const CategoriesGrid({
    super.key,
    required this.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // --- DATA SECTION ---
    // এই লিস্টটি এখন ডাইনামিক। ভবিষ্যতে Firebase থেকে ডাটা আনলে জাস্ট এই লিস্টটি আপডেট করলেই হবে।
    final List<Map<String, dynamic>> categories = [
      {'name': 'Wedding', 'icon': Icons.favorite_rounded},
      {'name': 'Newborn', 'icon': Icons.child_care_rounded},
      {'name': 'Birthday', 'icon': Icons.cake_rounded},
      {'name': 'Travel', 'icon': Icons.terrain_rounded},
      {'name': 'Event', 'icon': Icons.theater_comedy_rounded},
      {'name': 'Portrait', 'icon': Icons.portrait_rounded},
    ];

    return SizedBox(
      height: 100, // উচ্চতা প্রয়োজন অনুযায়ী ঠিক করে নিন
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(), // স্মুথ স্ক্রলিং
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];

          return Padding(
            padding: const EdgeInsets.only(right: 25),
            child: InkWell(
              // ২. ডাইনামিক নেভিগেশন logic
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PackageResultScreen(
                      // ভুলটি এখানে ছিল: 'categoryName' এর বদলে 'cat['name']' হবে
                      categoryName: cat['name'],
                      primaryAccent: primaryAccent,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(30), // Ripple effect circular
              child: Column(
                children: [
                  // Icon Circle (ইমেজের ডিজাইনের মতো)
                  CircleAvatar(
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.05) // ডার্ক মোডে হালকা সাদা
                        : primaryAccent.withOpacity(0.1), // লাইট মোডে এক্সেন্ট কালার
                    radius: 30,
                    child: Icon(
                        cat['icon'],
                        color: primaryAccent, // আইকন কালার সবসময় এক্সেন্ট থাকবে
                        size: 28
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Category Name
                  Text(
                    cat['name'], // ডাইনামিক নাম
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface, // ডার্ক/লাইটে অটো অ্যাডজাস্ট হবে
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}