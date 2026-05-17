import 'package:flutter/material.dart';
import 'package:nobochitro/responsive_review_list/_review_sheet_widget.dart';

class ActiveBookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool isDark;
  final bool isCompleted;
  final Color primaryAccent;
  final VoidCallback? onViewDetails;
  final VoidCallback? onCancel;

  const ActiveBookingCard({
    super.key,
    required this.booking,
    required this.isDark,
    required this.isCompleted,
    required this.primaryAccent,
    this.onViewDetails,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    String bookingId = booking['booking_id'] ?? "NB-00000";
    String packageTitle = booking['package_name'] ?? "Photography Session";
    String dateStr = booking['event_date'] ?? "N/A";
    String timeStr = booking['event_time'] ?? "N/A";
    String locationStr = booking['event_location'] ?? "N/A";
    String amountStr = "${booking['total_amount']?.toString() ?? '0'} BDT";
    String photographerName = booking['photographer_name'] ?? "Not Assigned";

    String paymentStatus = (booking['payment_status'] ?? "Pending").toString().trim().toUpperCase();
    String bookingStatus = (booking['booking_status'] ?? "pending").toString().trim().toLowerCase();

    // 📅 Days to Go টাইমিং লজিক
    String upperBadgeText = "Upcoming";
    Color badgeColor = Colors.amber;
    try {
      if (booking['event_date'] != null) {
        String fullDateTimeStr = booking['event_date'].toString();
        if (booking['event_time'] != null && !fullDateTimeStr.contains(':')) {
          fullDateTimeStr = "${booking['event_date']} ${booking['event_time'].toString().trim()}";
        }
        DateTime eventDateTime = DateTime.parse(fullDateTimeStr);
        Duration difference = eventDateTime.difference(DateTime.now());

        if (difference.isNegative) {
          upperBadgeText = "Passed";
        } else {
          if (difference.inDays > 0) upperBadgeText = "${difference.inDays} Days to Go";
          else if (difference.inHours > 0) upperBadgeText = "${difference.inHours} Hours to Go";
          else upperBadgeText = "Today";
        }
      }
    } catch (_) {}

    // 📸 রেগুলার টাইমলাইন ট্র্যাকিং (booking_status এর ওপর নির্ভরশীল)
    int currentStep = 0;
    if (bookingStatus == "pending") currentStep = 0;
    else if (bookingStatus == "approved") currentStep = 1;
    else if (bookingStatus == "shooting") currentStep = 2;
    else if (bookingStatus == "final draft" || bookingStatus == "draft") currentStep = 3;
    else if (bookingStatus == "handover" || bookingStatus == "delivered" || bookingStatus == "completed") currentStep = 4;

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text("#$bookingId", style: TextStyle(color: primaryAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              if (upperBadgeText != "Passed")
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(color: badgeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(upperBadgeText, style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: (isCompleted ? Colors.green : Colors.orange).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(paymentStatus, style: TextStyle(color: isCompleted ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(packageTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.wallet, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              const Text("Payment: ", style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text(
                isCompleted ? "Fully Paid" : "Pending Verification",
                style: TextStyle(color: isCompleted ? Colors.green : Colors.blue, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(amountStr, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: primaryAccent)),
            ],
          ),
          const Divider(height: 30, thickness: 0.5),
          Row(
            children: [
              _infoTile(Icons.calendar_today, dateStr),
              const SizedBox(width: 20),
              _infoTile(Icons.access_time, timeStr),
            ],
          ),
          const SizedBox(height: 12),
          _infoTile(Icons.camera_alt_outlined, "Photographer: $photographerName"),
          const SizedBox(height: 12),
          _infoTile(Icons.location_on_outlined, locationStr),
          const Divider(height: 30, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimelineStep("Pending", currentStep >= 0),
              _buildTimelineArrow(currentStep >= 1),
              _buildTimelineStep("Approved", currentStep >= 1),
              _buildTimelineArrow(currentStep >= 2),
              _buildTimelineStep("Shooting", currentStep >= 2),
              _buildTimelineArrow(currentStep >= 3),
              _buildTimelineStep("Final Draft", currentStep >= 3),
              _buildTimelineArrow(currentStep >= 4),
              _buildTimelineStep("Handover", currentStep >= 4),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewDetails ?? () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryAccent),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("View Details", style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: bookingStatus == "completed" || bookingStatus == "delivered" || bookingStatus == "handover"
                    ? ElevatedButton(
                  onPressed: () => ReviewService.showReviewSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text("Review", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                )
                    : OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Cancel", style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isActive ? Icons.check_circle : Icons.radio_button_unchecked, size: 12, color: isActive ? Colors.green : (isDark ? Colors.white30 : Colors.black26)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? (isDark ? Colors.white : Colors.black87) : Colors.grey)),
      ],
    );
  }

  Widget _buildTimelineArrow(bool isActive) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("➔", style: TextStyle(fontSize: 9, color: isActive ? Colors.green : Colors.grey.withOpacity(0.3))),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey),
        const SizedBox(width: 5),
        Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87))),
      ],
    );
  }
}