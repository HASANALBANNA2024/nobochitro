import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:nobochitro/categories_grid/package_result_screen.dart';

class CategoriesGrid extends StatefulWidget {
  final Color primaryAccent;

  const CategoriesGrid({super.key, required this.primaryAccent});

  @override
  State<CategoriesGrid> createState() => _CategoriesGridState();
}

class _CategoriesGridState extends State<CategoriesGrid> {
  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = DatabaseHelper.instance.getUniqueCategories();
  }

  /// category icon logic
  IconData _getIconForCategory(String category) {
    String name = category.toLowerCase();
    if (name.contains('wedding')) return Icons.favorite_rounded;
    if (name.contains('birth')) return Icons.cake_rounded;
    if (name.contains('portrait')) return Icons.portrait_rounded;
    if (name.contains('event')) return Icons.theater_comedy_rounded;
    if (name.contains('nature') || name.contains('wild'))
      return Icons.terrain_rounded;
    if (name.contains('product') || name.contains('commercial'))
      return Icons.business_center_rounded;
    if (name.contains('fashion')) return Icons.checkroom_rounded;
    if (name.contains('food')) return Icons.restaurant_rounded;
    return Icons.grid_view_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FutureBuilder<List<String>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 110,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final categories = snapshot.data!;

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final String categoryName = categories[index];

              return Padding(
                padding: const EdgeInsets.only(right: 25),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PackageResultScreen(
                          categoryName: categoryName,
                          primaryAccent: widget.primaryAccent,
                          package: categoryName,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.08)
                            : widget.primaryAccent.withOpacity(0.1),
                        radius: 30,
                        child: Icon(
                          _getIconForCategory(categoryName),
                          color: isDark ? Colors.white : widget.primaryAccent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // ক্যাটাগরি নাম
                      Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
