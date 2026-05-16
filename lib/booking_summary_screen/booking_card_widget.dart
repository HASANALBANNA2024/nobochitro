import 'package:flutter/material.dart';
import 'package:nobochitro/responsive_review_list/_review_sheet_widget.dart';

class BookingCardWidget extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool isDark;
  final bool isCompleted;
  final Color primaryAccent;
  final VoidCallback? onViewDetails;
  final VoidCallback? onCancel;

  const BookingCardWidget({
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
    // 📦 ডেটা এক্সট্র্যাক্ট করা হচ্ছে
    String bookingId = booking['booking_id'] ?? "NB-00000";
    String packageTitle = booking['package_name'] ?? "Photography Session";
    String dateStr = booking['event_date'] ?? "N/A";
    String timeStr = booking['event_time'] ?? "N/A";
    String locationStr = booking['event_location'] ?? "N/A";
    String amountStr = "${booking['total_amount']?.toString() ?? '0'} BDT";
    String photographerName = booking['photographer_name'] ?? "Not Assigned";

    String paymentStatus = booking['payment_status'] ?? "Pending";
    String bookingStatus = booking['booking_status'] ?? "pending";
    String cleanedBookingStatus = bookingStatus.trim().toLowerCase();

    // 🔍 ক্যানসেলেশন স্টেট চেকিং
    bool isCancellationState = [
      "cancelled", "cancellation pending", "cancellation approved", "refund processing", "refund done"
    ].contains(cleanedBookingStatus);

    // ⏳ টাইমিং কাউন্টার লজিক
    String upperBadgeText = "Upcoming";
    Color badgeColor = Colors.amber;

    if (isCancellationState) {
      // 🕒 ক্যানসেলেশন ট্যাবের জন্য: রিকোয়েস্ট দেওয়ার পর থেকে কত সময় পার হয়েছে (Ageing)
      try {
        if (booking['cancelled_at'] != null) {
          DateTime cancelDateTime = DateTime.parse(booking['cancelled_at'].toString());
          DateTime now = DateTime.now();
          Duration diff = now.difference(cancelDateTime);

          if (diff.inDays > 0) {
            upperBadgeText = "${diff.inDays} Days Ago";
          } else if (diff.inHours > 0) {
            upperBadgeText = "${diff.inHours} Hours Ago";
          } else if (diff.inMinutes > 0) {
            upperBadgeText = "${diff.inMinutes} Mins Ago";
          } else {
            upperBadgeText = "Just Now";
          }
          badgeColor = Colors.redAccent; // ক্যানসেলেশনের জন্য রেড/ক্রিমসন থিম
        } else {
          upperBadgeText = "Requested";
          badgeColor = Colors.redAccent;
        }
      } catch (_) {
        upperBadgeText = "Requested";
        badgeColor = Colors.redAccent;
      }
    } else {
      // 📅 রেগুলার ট্যাবের জন্য: ইভেন্টের আর কতদিন বাকি (Days to Go)
      try {
        if (booking['event_date'] != null) {
          String fullDateTimeStr = booking['event_date'].toString();
          if (booking['event_time'] != null && !fullDateTimeStr.contains(':')) {
            String rawTime = booking['event_time'].toString().trim();
            fullDateTimeStr = "${booking['event_date']} $rawTime";
          }
          DateTime eventDateTime = DateTime.parse(fullDateTimeStr);
          DateTime now = DateTime.now();
          Duration difference = eventDateTime.difference(now);

          if (difference.isNegative) {
            upperBadgeText = "Passed";
          } else {
            if (difference.inDays > 0) upperBadgeText = "${difference.inDays} Days to Go";
            else if (difference.inHours > 0) upperBadgeText = "${difference.inHours} Hours to Go";
            else upperBadgeText = "Today";
          }
        }
      } catch (_) {}
    }

    // 🏁 ডায়নামিক টাইমলাইন স্টেপ ক্যালকুলেশন
    int currentStep = 0;
    if (isCancellationState) {
      // 🔄 ক্যানসেলেশন স্টেপ: Request(0) -> Approved(1) -> Refund Process(2) -> Refunded(3)
      if (cleanedBookingStatus == "cancellation pending") currentStep = 0;
      else if (cleanedBookingStatus == "cancellation approved") currentStep = 1;
      else if (cleanedBookingStatus == "refund processing") currentStep = 2;
      else if (cleanedBookingStatus == "refund done" || cleanedBookingStatus == "cancelled") currentStep = 3;
    } else {
      // 📸 রেগুলার স্টেপ
      if (cleanedBookingStatus == "pending") currentStep = 0;
      else if (cleanedBookingStatus == "approved") currentStep = 1;
      else if (cleanedBookingStatus == "shooting") currentStep = 2;
      else if (cleanedBookingStatus == "final draft" || cleanedBookingStatus == "draft") currentStep = 3;
      else if (cleanedBookingStatus == "handover" || cleanedBookingStatus == "delivered" || cleanedBookingStatus == "completed") currentStep = 4;
    }

    // 🏷️ স্ট্যাটাস চিপের টেক্সট নির্ধারণ (ক্যানসেলেশন স্ট্যাটাস বনাম পেমেন্ট স্ট্যাটাস)
    String chipLabel = isCancellationState
        ? (cleanedBookingStatus == "cancellation pending" ? "Pending" : "Approved")
        : paymentStatus;

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
          // 🏷️ আইডি, টাইম কাউন্টার এবং চিপ বার
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
              _statusChip(chipLabel, isCompleted, isCancellationState),
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
                isCancellationState ? "Cancellation Active" : (isCompleted ? "Fully Paid" : "Pending Verification"),
                style: TextStyle(color: isCancellationState ? Colors.redAccent : (isCompleted ? Colors.green : Colors.blue), fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(amountStr, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: primaryAccent)),
            ],
          ),

          const Divider(height: 30, thickness: 0.5),

          Row(
            children: [
              _infoTile(Icons.calendar_today, dateStr, isDark),
              const SizedBox(width: 20),
              _infoTile(Icons.access_time, timeStr, isDark),
            ],
          ),
          const SizedBox(height: 12),
          _infoTile(Icons.camera_alt_outlined, "Photographer: $photographerName", isDark),
          const SizedBox(height: 12),
          _infoTile(Icons.location_on_outlined, locationStr, isDark),

          const Divider(height: 30, thickness: 0.5),

          // 🏁 ডায়নামিক টাইমলাইন এক্সচেঞ্জ সেকশন
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: isCancellationState
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimelineStep("Request", currentStep >= 0, isDark),
                _buildTimelineArrow(currentStep >= 1),
                _buildTimelineStep("Approved", currentStep >= 1, isDark),
                _buildTimelineArrow(currentStep >= 2),
                _buildTimelineStep("Refund Process", currentStep >= 2, isDark),
                _buildTimelineArrow(currentStep >= 3),
                _buildTimelineStep("Refunded", currentStep >= 3, isDark),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimelineStep("Pending", currentStep >= 0, isDark),
                _buildTimelineArrow(currentStep >= 1),
                _buildTimelineStep("Approved", currentStep >= 1, isDark),
                _buildTimelineArrow(currentStep >= 2),
                _buildTimelineStep("Shooting", currentStep >= 2, isDark),
                _buildTimelineArrow(currentStep >= 3),
                _buildTimelineStep("Final Draft", currentStep >= 3, isDark),
                _buildTimelineArrow(currentStep >= 4),
                _buildTimelineStep("Handover", currentStep >= 4, isDark),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 🔴 বোতাম অ্যাকশনস সেকশন (ডায়নামিক বাটন লজিক)
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
              // 🪄 যদি ক্যানসেলেশন স্টেট হয়, তবে ক্যান্সেল বাটনটি আর দেখাবে না (খালি স্পেসও নিবে না)
              if (!isCancellationState) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: cleanedBookingStatus == "completed" || cleanedBookingStatus == "delivered" || cleanedBookingStatus == "handover"
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String label, bool isActive, bool isDark) {
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

  Widget _infoTile(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey),
        const SizedBox(width: 5),
        Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87))),
      ],
    );
  }

  Widget _statusChip(String status, bool isCompleted, bool isCancelled) {
    Color baseColor = isCompleted ? Colors.green : Colors.orange;
    if (isCancelled) {
      baseColor = status.toLowerCase() == "pending" ? Colors.orange : Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: baseColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(), style: TextStyle(color: baseColor, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}