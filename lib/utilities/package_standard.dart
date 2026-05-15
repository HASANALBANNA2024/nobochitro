import 'package:flutter/material.dart';

class PackageStandard {
  // প্যাকেজ লেভেলের লিস্ট যা ফিল্টারে ব্যবহার হবে
  static List<String> get packageFilters => [
    'All',
    'Budget',
    'Standard',
    'Gold',
    'Platinum',
    'Diamond',
    'Premium',
  ];

  static String getBadgeLabel(dynamic rawPrice) {
    double price = 0.0;
    if (rawPrice is num)
      price = rawPrice.toDouble();
    else if (rawPrice is String)
      price = double.tryParse(rawPrice) ?? 0.0;

    if (price < 8000) return 'Budget';
    if (price < 15000) return 'Standard';
    if (price < 25000) return 'Gold';
    if (price < 40000) return 'Platinum';
    if (price < 60000) return 'Diamond';
    return 'Premium';
  }

  static Color getBadgeColor(String label) {
    switch (label) {
      case 'Budget':
        return Colors.green;
      case 'Standard':
        return Colors.blue;
      case 'Gold':
        return const Color(0xFFFFD700);
      case 'Platinum':
        return const Color(0xFFE5E4E2);
      case 'Diamond':
        return Colors.cyanAccent;
      case 'Premium':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }
}
