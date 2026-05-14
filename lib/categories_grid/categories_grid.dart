import 'package:flutter/material.dart';
// আপনার প্রোজেক্টের সঠিক পাথ অনুযায়ী এটি ইম্পোর্ট নিশ্চিত করুন
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
    final List<Map<String, dynamic>> categories = [
      {'name': 'Wedding', 'icon': Icons.favorite_rounded},
      {'name': 'Newborn', 'icon': Icons.child_care_rounded},
      {'name': 'Birthday', 'icon': Icons.cake_rounded},
      {'name': 'Travel', 'icon': Icons.terrain_rounded},
      {'name': 'Event', 'icon': Icons.theater_comedy_rounded},
      {'name': 'Portrait', 'icon': Icons.portrait_rounded},
    ];

    return SizedBox(
      height: 110, // টেক্সট যেন কেটে না যায় তাই উচ্চতা সামান্য বাড়ানো হয়েছে
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20), // দুই পাশে সামান্য প্যাডিং
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];

          return Padding(
            padding: const EdgeInsets.only(right: 25),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PackageResultScreen(
                      categoryName: cat['name'],
                      primaryAccent: primaryAccent,
                      // 'package' প্যারামিটারটি আপনার স্ক্রিনে রিকোয়ার্ড ছিল, তাই এটি যোগ করা হলো
                      package: cat['name'],
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Circle
                  CircleAvatar(
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : primaryAccent.withOpacity(0.1),
                    radius: 30,
                    child: Icon(
                        cat['icon'],
                        color: primaryAccent,
                        size: 28
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Category Name
                  Text(
                    cat['name'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
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