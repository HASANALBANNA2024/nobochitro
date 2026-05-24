import 'package:supabase_flutter/supabase_flutter.dart';
class SuspendedService {
  static final _client = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> getSuspendedAppeals() async {
    return await _client.from('payment_verifications')
        .select('*')
        .eq('booking_status', 'suspended');
  }

  static Future<void> updateAppealData(String id, Map<String, dynamic> data) async {
    await _client.from('payment_verifications').update(data).eq('booking_id', id);
  }
}