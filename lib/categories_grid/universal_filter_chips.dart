import 'package:flutter/material.dart';

class UniversalFilterChips extends StatefulWidget {
  final Function(String) onSelected;
  final Color accentColor;
  const UniversalFilterChips({
    super.key,
    required this.onSelected,
    this.accentColor = Colors.blue,
  });

  @override
  State<UniversalFilterChips> createState() => _UniversalFilterChipsState();
}

class _UniversalFilterChipsState extends State<UniversalFilterChips> {
  String selectedFilter = 'All';
  final List<String> filters = [
    'All',
    'Budget-friendly',
    'Standard',
    'Gold',
    'Platinum',
    'Diamond',
    'Premium',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filterName = filters[index];
          final isSelected = filterName == selectedFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filterName),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() => selectedFilter = filterName);
                  widget.onSelected(filterName);
                }
              },
              selectedColor: widget.accentColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.black
                    : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}
