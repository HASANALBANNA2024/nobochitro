import 'package:flutter/material.dart';

class BookingGlanceSection extends StatelessWidget {
  final AsyncSnapshot<List<Map<String, dynamic>>> snapshot;
  final bool isDark;
  final bool isWeb;

  const BookingGlanceSection({
    super.key,
    required this.snapshot,
    required this.isDark,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    if (!snapshot.hasData || snapshot.data == null) {
      return _buildVisualGlanceRow(0, 0, 0);
    }

    final List<Map<String, dynamic>> databaseBookings = snapshot.data!;
    int totalCount = databaseBookings.length;
    int upcomingCount = 0;
    int completedCount = 0;

    for (var booking in databaseBookings) {
      String bookingStatus = (booking['booking_status'] ?? 'pending').toString().trim().toLowerCase();

      if (bookingStatus == 'completed' || bookingStatus == 'delivered' || bookingStatus == 'handover') {
        completedCount++;
      } else if (bookingStatus != 'cancelled') {
        upcomingCount++;
      }
    }

    return _buildVisualGlanceRow(totalCount, upcomingCount, completedCount);
  }

  Widget _buildVisualGlanceRow(int total, int upcoming, int completed) {
    final List<Widget> cards = [
      _glanceCard("Total Bookings", "$total", Icons.grid_view_rounded, Colors.blue),
      _glanceCard("Upcoming", "$upcoming", Icons.hourglass_top_rounded, Colors.orange),
      _glanceCard("Completed", "$completed", Icons.check_circle_rounded, Colors.green),
    ];

    if (isWeb) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: cards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: card))).toList(),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: cards),
    );
  }

  Widget _glanceCard(String title, String count, IconData icon, Color color) {
    return Container(
      width: isWeb ? null : 160,
      margin: isWeb ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundColor: color.withOpacity(0.15), child: Icon(icon, size: 18, color: color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}