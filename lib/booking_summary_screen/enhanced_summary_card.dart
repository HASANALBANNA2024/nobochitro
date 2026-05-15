import 'package:flutter/material.dart';

class EnhancedSummaryCard extends StatelessWidget {
  final Map<String, dynamic> packageData;
  final Color primaryAccent;
  final int selectedHours;
  final int selectedMinutes;
  final String selectedTime; // নতুন টাইম প্যারামিটার
  final String locationType;
  final double totalAddonsPrice;

  const EnhancedSummaryCard({
    super.key,
    required this.packageData,
    required this.primaryAccent,
    required this.selectedHours,
    required this.selectedMinutes,
    required this.selectedTime,
    required this.locationType,
    required this.totalAddonsPrice,
  });

  // --- ডাইনামিক প্রাইস ক্যালকুলেশন লজিক ---
  Map<String, double> _calculateDetailedTotal() {
    double basePrice =
        double.tryParse(packageData['base_price'].toString()) ?? 0;
    int baseHours = packageData['base_hours'] ?? 1;

    // প্রতি ঘণ্টার রেট বের করা (Base Price / Base Hours)
    double ratePerHour = basePrice / baseHours;
    double selectedTotalDuration = selectedHours + (selectedMinutes / 60);
    double extraCost = 0;

    // এক্সট্রা টাইম ক্যালকুলেশন
    if (selectedTotalDuration > baseHours) {
      double extraTime = selectedTotalDuration - baseHours;
      extraCost = extraTime * ratePerHour;
    }

    double finalTotal = basePrice + extraCost + totalAddonsPrice;
    return {"base": basePrice, "extra": extraCost, "total": finalTotal};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final priceDetails = _calculateDetailedTotal();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: primaryAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  packageData['title'] ?? "Package Summary",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 35, thickness: 0.8),

          // ডাটা রোগুলো
          _infoRow(
            Icons.timer_outlined,
            "Total Duration",
            "$selectedHours h $selectedMinutes m",
          ),

          // আপনার চাহিদা অনুযায়ী ডিউরেশনের নিচে টাইম স্লট
          _infoRow(Icons.access_time_rounded, "Scheduled Time", selectedTime),

          _infoRow(
            Icons.history_toggle_off_rounded,
            "Included Time",
            "${packageData['base_hours']} Hours",
          ),

          if (priceDetails['extra']! > 0)
            _infoRow(
              Icons.more_time_rounded,
              "Extra Time Cost",
              "+ ৳${priceDetails['extra']!.toStringAsFixed(0)}",
              valueColor: Colors.orangeAccent,
            ),

          _infoRow(Icons.location_on_outlined, "Location", locationType),
          _infoRow(
            Icons.add_box_outlined,
            "Add-ons Cost",
            "৳${totalAddonsPrice.toStringAsFixed(0)}",
          ),

          const Divider(height: 35, thickness: 0.8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "৳${priceDetails['total']!.toStringAsFixed(0)}",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: primaryAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
