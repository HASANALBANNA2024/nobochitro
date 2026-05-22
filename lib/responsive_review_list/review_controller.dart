import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class ReviewController {
  int rating = 0;
  final TextEditingController reviewController = TextEditingController();

  // ক্রস-প্লাটফর্ম সেফ XFile লিস্ট
  final List<XFile> selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  String displayName = "anonymous_user";
  String displayEmail = "";
  String? userPhotoUrl;
  String? customNsrId;

  /// 👤 বুকিং ডাটা থেকে সরাসরি নাম, ইমেইল এবং প্রোফাইল পিকচার কন্ট্রোলারে সেট করা
  void setManualUserInformation({
    required String name,
    required String email,
    String? avatarUrl,
  }) {
    if (name.trim().isNotEmpty) displayName = name;
    if (email.trim().isNotEmpty) displayEmail = email;
    if (avatarUrl != null && avatarUrl.trim().isNotEmpty)
      userPhotoUrl = avatarUrl;
  }

  /// 👤 ইউজারের প্রোফাইল ডাটা লোড করা (ফায়ারবেস ও লোকাল ডিবি থেকে)
  Future<void> loadUserInformation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      customNsrId = await DatabaseHelper.instance.getCurrentUserNsrId();

      if (displayName == "anonymous_user") {
        displayName =
            user.displayName ??
            (user.email != null ? user.email!.split('@')[0] : "anonymous_user");
      }
      if (displayEmail.isEmpty) {
        displayEmail = user.email ?? "";
      }

      if (customNsrId != null) {
        userPhotoUrl =
            "https://ijxtbmgvtwvpkbshunwf.supabase.co/storage/v1/object/public/user_assets/profile_user_image/$customNsrId.jpg";
      } else {
        userPhotoUrl ??= user.photoURL;
      }
    } else {
      if (displayName == "anonymous_user") displayName = "anonymous_user";
      if (displayEmail.isEmpty) displayEmail = "";
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

  /// 🚀 সুপাবেস টেবিলের ১৭টি কলামের সাথে ম্যাচ করা ফুল সাবমিট মেথড
  Future<bool> submitReview({
    required BuildContext context,
    Map<String, dynamic>? bookingData,
    required VoidCallback onLoadingToggle,
  }) async {
    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Please select a rating star!")),
      );
      return false;
    }

    isLoading = true;
    onLoadingToggle();

    try {
      List<String> uploadedUrls = [];
      List<String> uploadedPaths = []; // পাথ সেভ করার জন্য
      final userIdForUpload =
          customNsrId ??
          FirebaseAuth.instance.currentUser?.uid ??
          "anonymous_user";

      // 🔄 ইমেজ আপলোড প্রসেস
      if (selectedImages.isNotEmpty) {
        for (int i = 0; i < selectedImages.length; i++) {
          final bytes = await selectedImages[i].readAsBytes();

          // এখানে খেয়াল করো: আমরা Map গ্রহণ করছি
          final imageData = await DatabaseHelper.uploadImageBytes(
            folder: 'review_images',
            userId:
                "${userIdForUpload}_img_${DateTime.now().millisecondsSinceEpoch}_$i",
            bytes: bytes,
          );

          if (imageData != null && imageData.containsKey('url')) {
            uploadedUrls.add(imageData['url']!);
            uploadedPaths.add(imageData['path']!); // পাথটি সংগ্রহ করলাম
          }
        }
      }

      // 🎯 Supabase Array ফরম্যাট (PostgreSQL Array এর জন্য)
      dynamic finalReviewImages = uploadedUrls.isNotEmpty
          ? "{${uploadedUrls.join(',')}}"
          : null;
      dynamic finalReviewPaths = uploadedPaths.isNotEmpty
          ? "{${uploadedPaths.join(',')}}"
          : null;

      final Map<String, dynamic> reviewData = {
        'booking_id':
            bookingData?['booking_id']?.toString() ??
            bookingData?['id']?.toString(),
        'photographer_id': bookingData?['photographer_id']?.toString(),
        'user_id': userIdForUpload,
        'user_name': displayName,
        'rating': rating,
        'comment': reviewController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
        'package_id': bookingData?['package_id']?.toString(),
        'review_image_url': finalReviewImages,
        'review_image_path': finalReviewPaths, // 🟢 নতুন পাথ কলাম
        'package_name': bookingData?['package_name']?.toString(),
        'photographer_name': bookingData?['photographer_name']?.toString(),
        'category_name':
            bookingData?['package_category']?.toString() ??
            bookingData?['category_name']?.toString(),
        'user_avatar': userPhotoUrl,
        'user_email': displayEmail.isNotEmpty ? displayEmail : null,
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
