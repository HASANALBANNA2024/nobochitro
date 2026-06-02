import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class AddOnsSelector extends StatefulWidget {
  final String selectedCategory;

  ///package category
  final Function(List<Map<String, dynamic>>) onSelectionChanged;

  const AddOnsSelector({
    super.key,
    required this.selectedCategory,
    required this.onSelectionChanged,
  });

  @override
  State<AddOnsSelector> createState() => _AddOnsSelectorState();
}

class _AddOnsSelectorState extends State<AddOnsSelector> {
  final Set<Map<String, dynamic>> _selectedAddons = {};
  late Future<List<Map<String, dynamic>>> _addonsFuture;

  @override
  void initState() {
    super.initState();

    /// category wise filter
    _addonsFuture = _getFilteredAddons();
  }

  /// category filter logic
  Future<List<Map<String, dynamic>>> _getFilteredAddons() async {
    final allAddons = await DatabaseHelper.instance.getAddons();

    /// package category
    return allAddons
        .where(
          (addon) =>
              addon['category'].toString().toLowerCase() ==
              widget.selectedCategory.toLowerCase(),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _addonsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        /// if no exist in addons category
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "No specific add-ons for ${widget.selectedCategory}",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          );
        }

        final addons = snapshot.data!;

        return Container(
          width: double.infinity,
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: addons.map((addon) {
              /// for logic of selection check
              final isSelected = _selectedAddons.any(
                (item) => item['title'] == addon['title'],
              );

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedAddons.removeWhere(
                        (item) => item['title'] == addon['title'],
                      );
                    } else {
                      _selectedAddons.add(addon);
                    }
                  });
                  widget.onSelectionChanged(_selectedAddons.toList());
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primaryColor.withOpacity(isDark ? 0.2 : 0.1)
                        : (isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor
                          : (isDark
                                ? Colors.white12
                                : Colors.black.withOpacity(0.05)),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (addon['iamge_url'] != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              addon['iamge_url'],
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: 20,
                                    color: theme.primaryColor,
                                  ),
                            ),
                          ),
                        ),
                      Flexible(
                        child: Text(
                          "${addon['title']} +৳${addon['price']}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? Colors.white : theme.primaryColor)
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
