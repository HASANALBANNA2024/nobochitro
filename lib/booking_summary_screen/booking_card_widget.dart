import 'package:flutter/material.dart';
// 📂 আপনার প্রজেক্টের পাথ অনুযায়ী এই ৩টি ইম্পোর্ট ঠিক করে নেবেন
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
  final VoidCallback? onAppeal; // 👈 আপিল শিট ওপেন করার ডেডিকেটেড কলব্যাক

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
    // 🔄 স্ট্যাটাস কলামগুলো এক্সট্র্যাক্ট করে লোয়ারকেস করে নেওয়া
    String paymentStatus = (booking['payment_status'] ?? "Pending").toString().trim().toLowerCase();
    String bookingStatus = (booking['booking_status'] ?? "pending").toString().trim().toLowerCase();

    // 🔍 ১. সাসপেন্ডেড স্টেট চেক (যেকোনো একটি কলামে হিট করলেই হবে)
    bool isSuspendedState = bookingStatus == "suspended" ||
        bookingStatus == "appealed" ||
        paymentStatus == "suspended" ||
        paymentStatus == "appealed";

    if (isSuspendedState) {
      return SuspendedBookingCard(
        booking: booking,
        isDark: isDark,
        primaryAccent: primaryAccent,
        onViewDetails: onViewDetails,
        onAppeal: onAppeal, // 🎯 কোনো লজিক ছাড়াই ডিরেক্ট ক্লিক পাস হবে এখানে
      );
    }

    // 🔍 ২. ক্যানসেলেশন স্টেট চেক
    bool isCancellationState = [
      "cancelled", "cancellation pending", "cancellation approved", "refund processing", "refund done"
    ].contains(bookingStatus);

    if (isCancellationState) {
      return CancelledBookingCard(
        booking: booking,
        isDark: isDark,
        primaryAccent: primaryAccent,
        onViewDetails: onViewDetails,
      );
    }

    // 🔍 ৩. ডিফল্ট অ্যাক্টিভ/আপকামিং স্টেট
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