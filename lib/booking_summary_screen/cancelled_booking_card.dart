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

    String refundStatus = (booking['refund_status'] ?? "")
        .toString()
        .trim()
        .toLowerCase();
    String bookingStatus = (booking['booking_status'] ?? "")
        .toString()
        .trim()
        .toLowerCase();

    // ⏳ ক্যানসেলেশন এজিং টাইম লজিক (cancelled_at থেকে)
    String upperBadgeText = "Cancelled";
    try {
      if (booking['cancelled_at'] != null) {
        DateTime cancelTime = DateTime.parse(
          booking['cancelled_at'].toString(),
        );
        Duration diff = DateTime.now().difference(cancelTime);
        if (diff.inDays > 0) {
          upperBadgeText = "${diff.inDays} Days Ago";
        } else if (diff.inHours > 0) {
          upperBadgeText = "${diff.inHours} Hours Ago";
        } else {
          upperBadgeText = "Just Now";
        }
      }
    } catch (_) {}

    // 🔄 ক্যানসেলেশন ৪-স্টেপ টাইমলাইন (refund_status এর ওপর নির্ভরশীল)
    int currentStep = 0;
    if (refundStatus == "pending" || bookingStatus == "cancellation pending") {
      currentStep = 0;
    } else if (refundStatus == "approved" ||
        bookingStatus == "cancellation approved") {
      currentStep = 1;
    } else if (refundStatus == "refund process" ||
        bookingStatus == "refund processing") {
      currentStep = 2;
    } else if (refundStatus == "refunded" ||
        refundStatus == "done" ||
        bookingStatus == "refund done" ||
        bookingStatus == "cancelled") {
      currentStep = 3;
    }

    String chipLabel = bookingStatus == "cancellation pending"
        ? "PENDING"
        : "APPROVED";

    // 🎯 মূল সমাধান: প্যারেন্ট কলাম যুক্ত করা হয়েছে
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12), // 🎯 16 থেকে 12
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ), // 🎯 18 থেকে কমানো হয়েছে
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(
              20,
            ), // 🎯 24 থেকে 20 (পূর্বের কার্ডের সাথে মিল রাখতে)
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    "#$bookingId",
                    style: TextStyle(
                      color: primaryAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      upperBadgeText,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (chipLabel == "PENDING"
                                  ? Colors.orange
                                  : Colors.green)
                              .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      chipLabel,
                      style: TextStyle(
                        color: chipLabel == "PENDING"
                            ? Colors.orange
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // 🎯 12 থেকে 8
              Text(
                packageTitle,
                style: const TextStyle(
                  fontSize:
                      18, // 🎯 20 থেকে 18 (পূর্বের কার্ডের সাথে মিল রাখতে)
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8), // 🎯 12 থেকে 8
              Row(
                children: [
                  const Icon(Icons.wallet, size: 15, color: Colors.grey),
                  const SizedBox(width: 5),
                  const Text(
                    "Payment: ",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Text(
                    "Cancellation Active",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    amountStr,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: primaryAccent,
                    ),
                  ),
                ],
              ),
              const Divider(height: 16, thickness: 0.5), // 🎯 30 থেকে 16
              Row(
                children: [
                  Expanded(
                    child: _infoTile(Icons.calendar_today, dateStr),
                  ), // 🎯 Expanded যুক্ত
                  const SizedBox(width: 10), // 🎯 20 থেকে 10
                  Expanded(
                    child: _infoTile(Icons.access_time, timeStr),
                  ), // 🎯 Expanded যুক্ত
                ],
              ),
              const SizedBox(height: 8), // 🎯 12 থেকে 8
              _infoTile(
                Icons.camera_alt_outlined,
                "Photographer: $photographerName",
              ),
              const SizedBox(height: 8), // 🎯 12 থেকে 8
              _infoTile(Icons.location_on_outlined, locationStr),
              const Divider(height: 16, thickness: 0.5), // 🎯 30 থেকে 16
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildTimelineStep("Request", currentStep >= 0),
                  ),
                  _buildTimelineArrow(currentStep >= 1),
                  Expanded(
                    child: _buildTimelineStep("Approved", currentStep >= 1),
                  ),
                  _buildTimelineArrow(currentStep >= 2),
                  Expanded(
                    child: _buildTimelineStep(
                      "Refund Process",
                      currentStep >= 2,
                    ),
                  ),
                  _buildTimelineArrow(currentStep >= 3),
                  Expanded(
                    child: _buildTimelineStep("Refunded", currentStep >= 3),
                  ),
                ],
              ),
              const SizedBox(height: 12), // 🎯 20 থেকে 12
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onViewDetails ?? () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryAccent),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ), // 🎯 11 থেকে 10
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // 🎯 12 থেকে 10
                        ),
                      ),
                      child: const Text(
                        "View Details",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🎯 পূর্বের ActiveBookingCard এর মতই আপডেট করা হয়েছে যেন ওভারফ্লো না হয়
  Widget _buildTimelineStep(String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isActive ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 10,
          color: isActive
              ? Colors.green
              : (isDark ? Colors.white30 : Colors.black26),
        ),
        const SizedBox(height: 1),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? (isDark ? Colors.white : Colors.black87)
                  : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  // 🎯 পূর্বের ActiveBookingCard এর মতই আপডেট করা হয়েছে
  Widget _buildTimelineArrow(bool isActive) {
    return Expanded(
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "➔",
            style: TextStyle(
              fontSize: 8,
              color: isActive ? Colors.green : Colors.grey.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  // 🎯 পূর্বের ActiveBookingCard এর মতই আপডেট করা হয়েছে
  Widget _infoTile(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 13, color: Colors.grey),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
