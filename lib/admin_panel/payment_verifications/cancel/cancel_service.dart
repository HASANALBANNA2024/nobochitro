import 'package:supabase_flutter/supabase_flutter.dart';

class CancelService {
  static final _client = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> getCancelledPayments() async {
    return await _client.from('payment_verifications')
        .select('*')
        .or('booking_status.in.(cancelled,cancellation pending,cancellation approved)')
        .order('refund_status', ascending: true);
  }

  static Future<void> updateBookingStatus(String id, String status) async {
    await _client.from('payment_verifications').update({'booking_status': status}).eq('booking_id', id);
  }

  static Future<void> updateRefundData(String id, Map<String, dynamic> data) async {
    await _client.from('payment_verifications').update(data).eq('booking_id', id);
  }
}