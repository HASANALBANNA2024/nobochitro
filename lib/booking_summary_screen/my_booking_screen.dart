import 'package:flutter/material.dart';
import 'package:nobochitro/responsive_review_list/_review_sheet_widget.dart';
import 'package:nobochitro/widgets/custom_appbar.dart';
import 'package:nobochitro/widgets/custom_bottom_nav.dart';

class MyBookingScreen extends StatelessWidget {
  final Color primaryAccent;
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final Function(bool) onThemeChanged;
  final VoidCallback onSettingsPressed;

  const MyBookingScreen({
    super.key,
    required this.primaryAccent,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onThemeChanged,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = screenWidth > 800;

    final List<Map<String, dynamic>> bookings = [
      {
        "title": "Premium Portrait Session",
        "photographer": "Ayesha Rahman",
        "date": "Sat, May 15, 2026",
        "time": "10:00 AM",
        "status": "Upcoming",
        "amount": "15,750 BDT",
      },
      {
        "title": "Wedding Photography Session",
        "photographer": "Rahat Khan",
        "date": "Sun, Apr 20, 2026",
        "time": "04:00 PM",
        "status": "Completed",
        "amount": "12,500 BDT",
      },
    ];

    return Scaffold(
      appBar: buildCustomAppBar(context, primaryAccent, "My Bookings"),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isWeb ? 1100 : screenWidth,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          bool isCompleted = booking['status'] == "Completed";

                          // পরিবর্তন ১: এখানে context পাস করে দিয়েছি
                          return _buildBookingCard(
                            booking,
                            isDark,
                            isCompleted,
                            theme,
                            context, // <-- এই context টি পাঠানো হলো
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isWeb
          ? CustomBottomNav(
              currentIndex: selectedIndex,
              onTap: onDestinationSelected,
            )
          : null,
    );
  }

  // পরিবর্তন ২: এখানে BuildContext context প্যারামিটারটি যোগ করেছি
  Widget _buildBookingCard(
    Map<String, dynamic> booking,
    bool isDark,
    bool isCompleted,
    ThemeData theme,
    BuildContext context, // <-- এখানে context রিসিভ করা হচ্ছে
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "#NB-58267",
                style: TextStyle(
                  color: primaryAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              _statusChip(booking['status'], isCompleted),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            booking['title'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.wallet, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              const Text(
                "Payment: ",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const Text(
                "Partial Paid",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                booking['amount'],
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: primaryAccent,
                ),
              ),
            ],
          ),
          const Divider(height: 30, thickness: 0.5),
          Row(
            children: [
              _infoTile(Icons.calendar_today, booking['date'], isDark),
              const SizedBox(width: 20),
              _infoTile(Icons.access_time, booking['time'], isDark),
            ],
          ),
          const SizedBox(height: 12),
          _infoTile(
            Icons.location_on_outlined,
            "Dhanmondi, Dhaka (Studio)",
            isDark,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("View Details"),
                ),
              ),
              const SizedBox(width: 12),
              if (isCompleted)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // এখন আর লাল দাগ আসবে না, কারণ context এখন এই মেথডের পরিচিত
                      ReviewService.showReviewSheet(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Review",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String status, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.15)
            : Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isCompleted ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
