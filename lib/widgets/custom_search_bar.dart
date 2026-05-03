import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final Function(String)? onSearch;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Search photographers, packages...',
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48, // হাইট সামান্য বাড়ানো হয়েছে প্রফেশনাল লুকের জন্য
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12), // রাউন্ডেড কর্নার কিছুটা শার্প করা হয়েছে (Modern Look)
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: onSearch,
        cursorColor: isDark ? const Color(0xFFD4AF37) : theme.primaryColor,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white38 : Colors.black38,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: isDark ? Colors.white54 : Colors.black54
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13), // টেক্সট ভার্টিক্যালি সেন্ট্রাল করার জন্য
        ),
      ),
    );
  }
}