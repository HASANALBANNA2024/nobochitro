import 'package:flutter/material.dart';
import 'package:nobochitro/widgets/custom_appbar.dart';
import 'package:nobochitro/widgets/custom_bottom_nav.dart';

class MyBookingScreen extends StatelessWidget {
  final Color primaryAccent;

  // এই প্যারামিটারগুলো ক্লাসে ঘোষণা করা হলো যাতে অন্য স্ক্রিন থেকে মান আনা যায়
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

    // Sample Data
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
      // আপনার কাস্টম অ্যাপবার
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

                          return _buildBookingCard(
                            booking,
                            isDark,
                            isCompleted,
                            theme,
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

      // কাস্টম বটম নেভিগেশন বার
      // এখানে currentIndex এবং onTap এর বদলে এই স্ক্রিনে থাকা ভেরিয়েবলগুলো পাস করা হলো
      bottomNavigationBar: !isWeb
          ? CustomBottomNav(
              currentIndex: selectedIndex,
              onTap: onDestinationSelected,
            )
          : null,
    );
  }

  // বুকিং কার্ড উইজেট
  Widget _buildBookingCard(
    Map<String, dynamic> booking,
    bool isDark,
    bool isCompleted,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking['status'],
                  style: TextStyle(
                    color: isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                booking['amount'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            booking['title'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: primaryAccent),
              const SizedBox(width: 5),
              Text(
                booking['photographer'],
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text(booking['date'], style: const TextStyle(fontSize: 13)),
              const Spacer(),
              Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text(booking['time'], style: const TextStyle(fontSize: 13)),
            ],
          ),

          if (isCompleted) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  // রিভিউ স্ক্রিন কল করার লজিক
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Give Review & Rating",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
