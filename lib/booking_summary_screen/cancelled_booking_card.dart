import 'package:flutter/material.dart';

class CancelledBookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool isDark;
  final Color primaryAccent;
  final VoidCallback? onViewDetails;

  const CancelledBookingCard({
    super.key,
    required this.booking,
    required this.isDark,
    required this.primaryAccent,
    this.onViewDetails,
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

    String refundStatus = (booking['refund_status'] ?? "").toString().trim().toLowerCase();
    String bookingStatus = (booking['booking_status'] ?? "").toString().trim().toLowerCase();

    // ⏳ ক্যানসেলেশন এজিং টাইম লজিক (cancelled_at থেকে)
    String upperBadgeText = "Cancelled";
    try {
      if (booking['cancelled_at'] != null) {
        DateTime cancelTime = DateTime.parse(booking['cancelled_at'].toString());
        Duration diff = DateTime.now().difference(cancelTime);
        if (diff.inDays > 0) upperBadgeText = "${diff.inDays} Days Ago";
        else if (diff.inHours > 0) upperBadgeText = "${diff.inHours} Hours Ago";
        else upperBadgeText = "Just Now";
      }
    } catch (_) {}

    // 🔄 ক্যানসেলেশন ৪-স্টেপ টাইমলাইন (refund_status এর ওপর নির্ভরশীল)
    int currentStep = 0;
    if (refundStatus == "pending" || bookingStatus == "cancellation pending") currentStep = 0;
    else if (refundStatus == "approved" || bookingStatus == "cancellation approved") currentStep = 1;
    else if (refundStatus == "refund process" || bookingStatus == "refund processing") currentStep = 2;
    else if (refundStatus == "refunded" || refundStatus == "done" || bookingStatus == "refund done" || bookingStatus == "cancelled") currentStep = 3;

    String chipLabel = bookingStatus == "cancellation pending" ? "PENDING" : "APPROVED";

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(upperBadgeText, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: (chipLabel == "PENDING" ? Colors.orange : Colors.green).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(chipLabel, style: TextStyle(color: chipLabel == "PENDING" ? Colors.orange : Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
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
              const Text("Cancellation Active", style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
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
              _buildTimelineStep("Request", currentStep >= 0),
              _buildTimelineArrow(currentStep >= 1),
              _buildTimelineStep("Approved", currentStep >= 1),
              _buildTimelineArrow(currentStep >= 2),
              _buildTimelineStep("Refund Process", currentStep >= 2),
              _buildTimelineArrow(currentStep >= 3),
              _buildTimelineStep("Refunded", currentStep >= 3),
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