import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../responsive_review_list/review_sheet_widget.dart' show ReviewService;

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

    String paymentStatus = (booking['payment_status'] ?? "Pending")
        .toString()
        .trim()
        .toUpperCase();
    String bookingStatus = (booking['booking_status'] ?? "pending")
        .toString()
        .trim()
        .toLowerCase();
    String? driveLink = booking['drive_link_handover'];

    String upperBadgeText = "Upcoming";
    Color badgeColor = Colors.amber;
    try {
      if (booking['event_date'] != null) {
        String fullDateTimeStr = booking['event_date'].toString();
        if (booking['event_time'] != null && !fullDateTimeStr.contains(':')) {
          fullDateTimeStr =
              "${booking['event_date']} ${booking['event_time'].toString().trim()}";
        }
        DateTime eventDateTime = DateTime.parse(fullDateTimeStr);
        Duration difference = eventDateTime.difference(DateTime.now());

        if (difference.isNegative) {
          upperBadgeText = "Passed";
        } else {
          if (difference.inDays > 0) {
            upperBadgeText = "${difference.inDays} Days to Go";
          } else if (difference.inHours > 0) {
            upperBadgeText = "${difference.inHours} Hours to Go";
          } else {
            upperBadgeText = "Today";
          }
        }
      }
    } catch (_) {}

    int currentStep = 0;
    if (bookingStatus == "pending") {
      currentStep = 0;
    } else if (bookingStatus == "approved") {
      currentStep = 1;
    } else if (bookingStatus == "shooting") {
      currentStep = 2;
    } else if (bookingStatus == "final draft" || bookingStatus == "draft") {
      currentStep = 3;
    } else if (bookingStatus == "handover" ||
        bookingStatus == "delivered" ||
        bookingStatus == "completed") {
      currentStep = 4;
    }

    bool isHandoverStage = currentStep == 4;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          // 🎯 প্যাডিং কিছুটা কমানো হয়েছে (Top/Bottom 12)
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
                  Text(
                    "#$bookingId",
                    style: TextStyle(
                      color: primaryAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (upperBadgeText != "Passed")
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        upperBadgeText,
                        style: TextStyle(
                          color: badgeColor,
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
                      color: (isCompleted ? Colors.green : Colors.orange)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      paymentStatus,
                      style: TextStyle(
                        color: isCompleted ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6), // 🎯 8 থেকে 6 করা হয়েছে
              Text(
                packageTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6), // 🎯 8 থেকে 6 করা হয়েছে
              Row(
                children: [
                  const Icon(Icons.wallet, size: 15, color: Colors.grey),
                  const SizedBox(width: 5),
                  const Text(
                    "Payment: ",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    isCompleted ? "Fully Paid" : "Pending Verification",
                    style: TextStyle(
                      color: isCompleted ? Colors.green : Colors.blue,
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
              const Divider(
                height: 12,
                thickness: 0.5,
              ), // 🎯 20 থেকে 12 করা হয়েছে
              Row(
                children: [
                  Expanded(child: _infoTile(Icons.calendar_today, dateStr)),
                  const SizedBox(width: 10),
                  Expanded(child: _infoTile(Icons.access_time, timeStr)),
                ],
              ),
              const SizedBox(height: 6), // 🎯 8 থেকে 6 করা হয়েছে
              _infoTile(
                Icons.camera_alt_outlined,
                "Photographer: $photographerName",
              ),
              const SizedBox(height: 6), // 🎯 8 থেকে 6 করা হয়েছে
              _infoTile(Icons.location_on_outlined, locationStr),
              const Divider(
                height: 12,
                thickness: 0.5,
              ), // 🎯 20 থেকে 12 করা হয়েছে
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildTimelineStep("Pending", currentStep >= 0),
                  ),
                  _buildTimelineArrow(currentStep >= 1),
                  Expanded(
                    child: _buildTimelineStep("Approved", currentStep >= 1),
                  ),
                  _buildTimelineArrow(currentStep >= 2),
                  Expanded(
                    child: _buildTimelineStep("Shooting", currentStep >= 2),
                  ),
                  _buildTimelineArrow(currentStep >= 3),
                  Expanded(
                    child: _buildTimelineStep("Final Draft", currentStep >= 3),
                  ),
                  _buildTimelineArrow(currentStep >= 4),
                  Expanded(
                    child: _buildTimelineStep("Handover", currentStep >= 4),
                  ),
                ],
              ),
              const SizedBox(height: 10), // 🎯 12 থেকে 10 করা হয়েছে
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        if (isHandoverStage &&
                            driveLink != null &&
                            driveLink.isNotEmpty) {
                          final Uri url = Uri.parse(driveLink);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        } else {
                          if (onViewDetails != null) onViewDetails!();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryAccent),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ), // 🎯 10 থেকে 8 করা হয়েছে
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isHandoverStage ? "Drive Link" : "View Details",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: isHandoverStage
                        ? ElevatedButton(
                            onPressed: () {
                              ReviewService.showReviewSheet(
                                context,
                                booking: booking,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ), // 🎯 10 থেকে 8 করা হয়েছে
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 1,
                            ),
                            child: const Text(
                              "Review",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : OutlinedButton(
                            onPressed: onCancel,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ), // 🎯 10 থেকে 8 করা হয়েছে
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.redAccent,
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
