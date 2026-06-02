import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cancel_service.dart';

class CancelController {
  /// list fetch
  Future<List<Map<String, dynamic>>> fetchCancelled() async =>
      await CancelService.getCancelledPayments();

  /// Cancellation Approved logic with 12% deduction
  Future<void> approveCancellation(
    String id,
    double basePrice,
    double paymentAmount,
    VoidCallback onUpdate,
  ) async {
    print("Attempting to approve booking: $id");
    double deduction = basePrice * 0.12;

    double refundAmount = paymentAmount - deduction;

    try {
      await CancelService.updateRefundData(id, {
        'booking_status': 'cancellation approved',
        'refund_status': 'request',
        'refund_amount': refundAmount.toString(),
      });
      print("Update successful!");
      onUpdate();
    } catch (e) {
      print("Error during update: $e");
    }
  }

  /// refund status update logic with image and transaction
  Future<void> saveRefund(
    String id,
    String userId,
    String status,
    String trans,
    dynamic image,
    VoidCallback onDone,
  ) async {
    String? imageUrl;

    if (image != null) {
      final now = DateTime.now();
      final fileName = '$userId-${now.millisecondsSinceEpoch}.jpg';
      final path = 'refunded/images/$fileName';

      if (kIsWeb) {
        /// -- web logic  ---
        await Supabase.instance.client.storage
            .from('user_assets')
            .uploadBinary(
              path,
              image as Uint8List,
              fileOptions: const FileOptions(upsert: true),
            );
      } else {
        /// mobile logic  ---
        await Supabase.instance.client.storage
            .from('user_assets')
            .upload(
              path,
              image as File,
              fileOptions: const FileOptions(upsert: true),
            );
      }

      imageUrl = Supabase.instance.client.storage
          .from('user_assets')
          .getPublicUrl(path);
    }

    /// database update
    await CancelService.updateRefundData(id, {
      'refund_status': status.toLowerCase(),
      'refund_transaction': trans,
      if (imageUrl != null) 'refund_transaction_image': imageUrl,
    });

    onDone();
  }

  /// refund status update
  Future<void> updateRefundStatusOnly(
    String id,
    String status,
    VoidCallback onDone,
  ) async {
    await CancelService.updateRefundData(id, {
      'refund_status': status.toLowerCase(),
    });
    onDone();
  }
}
