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

    // 🎯 পেমেন্ট এবং রিফান্ড অ্যামাউন্ট লজিক
    String paymentAmount = booking['payment_amount']?.toString() ?? "0";
    String refundAmount = booking['refund_amount']?.toString() ?? "0";
    String amountStr = "$refundAmount BDT";

    String photographerName = booking['photographer_name'] ?? "Not Assigned";

    String refundStatus = (booking['refund_status'] ?? "").toString().trim().toLowerCase();
    String bookingStatus = (booking['booking_status'] ?? "").toString().trim().toLowerCase();

    // ⏳ ক্যানসেলেশন এজিং টাইম লজিক
    String upperBadgeText = "Cancelled";
    try {
      if (booking['cancelled_at'] != null) {
        DateTime cancelTime = DateTime.parse(booking['cancelled_at'].toString());
        Duration diff = DateTime.now().difference(cancelTime);
        upperBadgeText = diff.inDays > 0 ? "${diff.inDays} Days Ago" : (diff.inHours > 0 ? "${diff.inHours} Hours Ago" : "Just Now");
      }
    } catch (_) {}

    // 🎯 চিপ লজিক (booking_status এর ওপর নির্ভরশীল)
    String chipLabel = (bookingStatus == "cancellation approved") ? "Cancellation APPROVED" : "Cancellation PENDING";
    Color chipColor = (chipLabel == "APPROVED" ? Colors.blue : Colors.orange);

    // 🔄 টাইমলাইন লজিক (refund_status এর ওপর নির্ভরশীল)
    int currentStep = (refundStatus == "refunded") ? 3 : (refundStatus == "processing") ? 2 : (refundStatus == "approved") ? 1 : 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
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
                    decoration: BoxDecoration(color: chipColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(chipLabel, style: TextStyle(color: chipColor, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(packageTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),

              // 🎯 Booking Amount & Refund Amount
              Row(
                children: [
                  const Icon(Icons.wallet, size: 15, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text("Booking Payment: $paymentAmount BDT | Refundable Payment: $amountStr ", style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
              ),

              const Divider(height: 16, thickness: 0.5),
              Row(
                children: [
                  Expanded(child: _infoTile(Icons.calendar_today, dateStr)),
                  const SizedBox(width: 10),
                  Expanded(child: _infoTile(Icons.access_time, timeStr)),
                ],
              ),
              const SizedBox(height: 8),
              _infoTile(Icons.camera_alt_outlined, "Photographer: $photographerName"),
              const SizedBox(height: 8),
              _infoTile(Icons.location_on_outlined, locationStr),
              const Divider(height: 16, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildTimelineStep("Request", currentStep >= 0)),
                  _buildTimelineArrow(currentStep >= 1),
                  Expanded(child: _buildTimelineStep("Approved", currentStep >= 1)),
                  _buildTimelineArrow(currentStep >= 2),
                  Expanded(child: _buildTimelineStep("Refund Process", currentStep >= 2)),
                  _buildTimelineArrow(currentStep >= 3),
                  Expanded(child: _buildTimelineStep("Refunded", currentStep >= 3)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onViewDetails ?? () {},
                      style: OutlinedButton.styleFrom(side: BorderSide(color: primaryAccent), padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text("View Details", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStep(String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isActive ? Icons.check_circle : Icons.radio_button_unchecked, size: 10, color: isActive ? Colors.green : (isDark ? Colors.white30 : Colors.black26)),
        const SizedBox(height: 1),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 8, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? (isDark ? Colors.white : Colors.black87) : Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildTimelineArrow(bool isActive) {
    return Expanded(
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text("➔", style: TextStyle(fontSize: 8, color: isActive ? Colors.green : Colors.grey.withOpacity(0.3))),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 13, color: Colors.grey),
        const SizedBox(width: 5),
        Expanded(
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87)),
        ),
      ],
    );
  }
}