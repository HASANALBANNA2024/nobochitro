import 'package:flutter/material.dart';

class BookingTabButtons extends StatelessWidget {
  final int selectedTabIndex;
  final Color primaryAccent;
  final bool isDark;
  final Function(int) onTabSelected;

  const BookingTabButtons({
    super.key,
    required this.selectedTabIndex,
    required this.primaryAccent,
    required this.isDark,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    List<String> tabs = ["ACTIVE & UPCOMING", "CANCELLED & REFUNDS", "SUSPENDED"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(tabs.length, (index) {
            bool isSelected = selectedTabIndex == index;
            return GestureDetector(
              onTap: () => onTabSelected(index),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryAccent : (isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : (isDark ? Colors.white60 : Colors.black54)),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}