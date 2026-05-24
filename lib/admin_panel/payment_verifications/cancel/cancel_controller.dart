import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb; // ওয়েব ডিটেক্ট করার জন্য
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cancel_service.dart';

class CancelController {

  // লিস্ট ফেচ করার জন্য
  Future<List<Map<String, dynamic>>> fetchCancelled() async =>
      await CancelService.getCancelledPayments();

  // ১. Cancellation Approved লজিক (সাথে অটো ১২% কাটছাট ক্যালকুলেশন)
  Future<void> approveCancellation(String id, double basePrice, double paymentAmount, VoidCallback onUpdate) async {
    print("Attempting to approve booking: $id");
    double deduction = basePrice * 0.12;

    double refundAmount = paymentAmount - deduction;

    try {
      await CancelService.updateRefundData(id, {
        'booking_status': 'cancellation approved',
        'refund_status': 'request',
        'refund_amount': refundAmount.toString(),
      });
      print("Update successful!"); // এটি প্রিন্ট হলে বুঝবে ডাটাবেস আপডেট হয়েছে
      onUpdate();
    } catch (e) {
      print("Error during update: $e"); // কোন এরর থাকলে এখানে দেখা যাবে
    }
  }

  // ২. রিফান্ড স্ট্যাটাস আপডেট লজিক (ইমেজ এবং ট্রানজ্যাকশন সহ)
  Future<void> saveRefund(String id, String userId, String status, String trans, dynamic image, VoidCallback onDone) async {
    String? imageUrl;

    if (image != null) {
      final now = DateTime.now();
      final fileName = '$userId-${now.millisecondsSinceEpoch}.jpg';
      final path = 'refunded/images/$fileName';

      if (kIsWeb) {
        // --- ওয়েবের জন্য লজিক ---
        await Supabase.instance.client.storage.from('user_assets').uploadBinary(
            path,
            image as Uint8List, // ওয়েব থেকে বাইট আসছে
            fileOptions: const FileOptions(upsert: true)
        );
      } else {
        // --- মোবাইলের জন্য লজিক ---
        await Supabase.instance.client.storage.from('user_assets').upload(
            path,
            image as File, // মোবাইল থেকে ফাইল আসছে
            fileOptions: const FileOptions(upsert: true)
        );
      }

      imageUrl = Supabase.instance.client.storage.from('user_assets').getPublicUrl(path);
    }

    // ডাটাবেস আপডেট
    await CancelService.updateRefundData(id, {
      'refund_status': status.toLowerCase(),
      'refund_transaction': trans,
      if (imageUrl != null) 'refund_transaction_image': imageUrl,
    });

    onDone();
  }

  // ৩. সাধারণ রিফান্ড স্ট্যাটাস আপডেট (ম্যানুয়াল ক্লিকের জন্য)
  Future<void> updateRefundStatusOnly(String id, String status, VoidCallback onDone) async {
    await CancelService.updateRefundData(id, {
      'refund_status': status.toLowerCase(),
    });
    onDone();
  }
}