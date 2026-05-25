import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'suspended_service.dart';

class SuspendedController {
  Future<List<Map<String, dynamic>>> fetchSuspended() async =>
      await SuspendedService.getSuspendedAppeals();


  Future<void> updateAppealStatus(String id, String userId, String status, {String? notes, dynamic image, VoidCallback? onDone}) async {
    Map<String, dynamic> updateData = {'appeal_status': status};

    if (image != null) {
      final path = 'appeal_files/NSR-$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      if (kIsWeb) {
        await Supabase.instance.client.storage.from('user_assets').uploadBinary(path, image as Uint8List);
      } else {
        await Supabase.instance.client.storage.from('user_assets').upload(path, image as File);
      }
      updateData['appeal_cancel_image'] = Supabase.instance.client.storage.from('user_assets').getPublicUrl(path);
    }

    if (notes != null) updateData['appeal_cancel_notes'] = notes;

    await SuspendedService.updateAppealData(id, updateData);
    if (onDone != null) onDone();
  }

  Future<void> updateFinalApproval(String id, String bookingStatus, String paymentStatus, {required VoidCallback onDone}) async {
    Map<String, dynamic> updateData = {
      'appeal_status': 'approved',
      'booking_status': bookingStatus,
      'payment_status': paymentStatus,
    };

    await SuspendedService.updateAppealData(id, updateData);
    onDone();
  }
}