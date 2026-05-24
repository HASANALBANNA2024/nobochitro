import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ActiveService {
  static final _client = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> getActivePayments() async {
    try {
      final response = await _client
          .from('payment_verifications')
          .select('*')
          .not('booking_status', 'in', '("cancelled", "suspended")')
          .not('payment_status', 'in', '("cancelled", "suspended")')
          .order('submitted_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("❌ Database Error: $e");
      return [];
    }
  }

  static Future<void> updatePaymentStatus(String id, String status) async {
    try {
      await _client.from('payment_verifications').update({
        'booking_status': status,
        'payment_status': status,
      }).eq('booking_id', id);
    } catch (e) {
      debugPrint("❌ Update Error: $e");
    }
  }

  static Future<void> suspendPayment(String id, String note) async {
    try {
      await _client.from('payment_verifications').update({
        'booking_status': 'suspended',
        'payment_status': 'suspended',
        'suspended_note': note,
        'suspended_at': DateTime.now().toIso8601String(),
      }).eq('booking_id', id);
    } catch (e) {
      debugPrint("❌ Suspend Error: $e");
    }
  }

  // এখানে static করে দিয়েছি যেন কন্ট্রোলার থেকে কল করা যায়
  static Future<void> updateHandover(String id, String link) async {
    try {
      await _client.from('payment_verifications').update({
        'booking_status': 'handover', // এই লাইনটিই booking_status এ 'handover' লিখছে
        'drive_link_handover': link,
      }).eq('booking_id', id);
    } catch (e) {
      debugPrint("❌ Handover Error: $e");
    }
  }

  static Future<void> updateBookingStatusOnly(String id, String status) async {
    try {
      await _client.from('payment_verifications').update({
        'booking_status': status,
      }).eq('booking_id', id);
    } catch (e) {
      debugPrint("❌ Booking Status Update Error: $e");
    }
  }
}