import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class ReviewController {
  int rating = 0;
  final TextEditingController reviewController = TextEditingController();

  // 🟢 XFile ব্যবহার করা হলো যা মোবাইল ও ওয়েব দুই জায়গাতেই প্রিভিউ ফ্রেন্ডলি
  final List<XFile> selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  String displayName = "Anonymous";
  String? userPhotoUrl;
  String? customNsrId;

  /// 👤 ইউজারের প্রোফাইল ডাটা লোড করা
  Future<void> loadUserInformation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      customNsrId = await DatabaseHelper.instance.getCurrentUserNsrId();
      displayName =
          user.displayName ??
          (user.email != null ? user.email!.split('@')[0] : "Anonymous");

      if (customNsrId != null) {
        userPhotoUrl =
            "https://ijxtbmgvtwvpkbshunwf.supabase.co/storage/v1/object/public/user_assets/profile_user_image/$customNsrId.jpg";
      } else {
        userPhotoUrl = user.photoURL;
      }
    }
  }

  /// 📸 গ্যালারি থেকে ছবি সিলেক্ট করা
  Future<void> pickImage(VoidCallback onUpdate) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) {
      selectedImages.add(image);
      onUpdate();
    }
  }

  /// ❌ লিস্ট থেকে নির্দিষ্ট ছবি রিমুভ করা
  void removeImage(int index, VoidCallback onUpdate) {
    selectedImages.removeAt(index);
    onUpdate();
  }

  /// 🚀 মাল্টি-ইমেজসহ রিভিউ সাবমিট করার লজিক
  Future<bool> submitReview({
    required BuildContext context,
    Map<String, dynamic>? bookingData,
    required VoidCallback onLoadingToggle,
  }) async {
    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please select a rating star!")),
      );
      return false;
    }

    isLoading = true;
    onLoadingToggle();

    try {
      List<String> uploadedUrls = [];
      final userIdForUpload =
          customNsrId ??
          FirebaseAuth.instance.currentUser?.uid ??
          "anonymous_user";

      // 🔄 সুপাবেস বাকেটের 'review_images' ফোল্ডারে আপলোড
      if (selectedImages.isNotEmpty) {
        for (int i = 0; i < selectedImages.length; i++) {
          final bytes = await selectedImages[i].readAsBytes();
          String? url = await DatabaseHelper.uploadImageBytes(
            folder: 'review_images',
            userId:
                "${userIdForUpload}_img_${DateTime.now().millisecondsSinceEpoch}_$i",
            bytes: bytes,
          );
          if (url != null) {
            uploadedUrls.add(url);
          }
        }
      }

      final String packageName =
          bookingData?['package_name'] ?? "General App Review";
      final String photographerName =
          bookingData?['photographer_name'] ?? "NoboChitro Team";
      final String? bookingId = bookingData?['booking_id'];

      final Map<String, dynamic> reviewData = {
        'user_id': userIdForUpload,
        'user_name': displayName,
        'comment': reviewController.text.trim(),
        'rating': rating,
        'image_urls': uploadedUrls,
        'package_name': packageName,
        'photographer_name': photographerName,
        'booking_id': bookingId,
        'created_at': DateTime.now().toIso8601String(),
      };

      await DatabaseHelper.insertReview(reviewData);
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to post review: $e"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } finally {
      isLoading = false;
      onLoadingToggle();
    }
  }
}
