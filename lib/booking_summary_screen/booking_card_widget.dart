import 'package:flutter/material.dart';

import 'active_booking_card.dart';
import 'cancelled_booking_card.dart';
import 'suspended_booking_card.dart';

class BookingCardWidget extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool isDark;
  final bool isCompleted;
  final Color primaryAccent;
  final VoidCallback? onViewDetails;
  final VoidCallback? onCancel;
  final VoidCallback? onAppeal;

  const BookingCardWidget({
    super.key,
    required this.booking,
    required this.isDark,
    required this.isCompleted,
    required this.primaryAccent,
    this.onViewDetails,
    this.onCancel,
    this.onAppeal,
  });

  @override
  Widget build(BuildContext context) {
    String paymentStatus = (booking['payment_status'] ?? "Pending")
        .toString()
        .trim()
        .toLowerCase();
    String bookingStatus = (booking['booking_status'] ?? "pending")
        .toString()
        .trim()
        .toLowerCase();

    bool isSuspendedState =
        bookingStatus == "suspended" ||
        bookingStatus == "appealed" ||
        paymentStatus == "suspended" ||
        paymentStatus == "appealed";

    if (isSuspendedState) {
      return SuspendedBookingCard(
        booking: booking,
        isDark: isDark,
        primaryAccent: primaryAccent,
        onViewDetails: onViewDetails,
        onAppeal: onAppeal,
      );
    }

    bool isCancellationState = [
      "cancelled",
      "cancellation pending",
      "cancellation approved",
      "refund processing",
      "refund done",
    ].contains(bookingStatus);

    if (isCancellationState) {
      return CancelledBookingCard(
        booking: booking,
        isDark: isDark,
        primaryAccent: primaryAccent,
        onViewDetails: onViewDetails,
      );
    }

    return ActiveBookingCard(
      booking: booking,
      isDark: isDark,
      isCompleted: isCompleted,
      primaryAccent: primaryAccent,
      onViewDetails: onViewDetails,
      onCancel: onCancel,
    );
  }
}
