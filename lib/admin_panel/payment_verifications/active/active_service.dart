import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ActiveService {
  static final _client = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> getActivePayments() async {
    try {
      final response = await _client
          .from('payment_verifications')
          .select('*')
      // status চেক
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
}