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
  String displayEmail = ""; // 🟢 ডিফল্ট ইমেইল একদম খালি রাখা হলো
  String? userPhotoUrl;
  String? customNsrId;

  /// 👤 ইউজারের প্রোফাইল ডাটা লোড করা
  Future<void> loadUserInformation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      customNsrId = await DatabaseHelper.instance.getCurrentUserNsrId();

      // ইউজার লগইন থাকলে তার নাম ও ইমেইল সেট করা
      displayName =
          user.displayName ??
          (user.email != null ? user.email!.split('@')[0] : "anonymous_user");
      displayEmail = user.email ?? ""; // লগইন থাকলে রিয়াল ইমেইল

      if (customNsrId != null) {
        userPhotoUrl =
            "https://ijxtbmgvtwvpkbshunwf.supabase.co/storage/v1/object/public/user_assets/profile_user_image/$customNsrId.jpg";
      } else {
        userPhotoUrl = user.photoURL;
      }
    } else {
      // 🟢 ইউজার লগইন না থাকলে নাম anonymous_user এবং ইমেইল সম্পূর্ণ ফাকা/খালি থাকবে
      displayName = "anonymous_user";
      displayEmail = "";
      userPhotoUrl = null;
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

  /// 🚀 মাল্টি-ইমেজ কমা সেপারেটেড লিংকসহ রিভিউ পোস্ট করার মেথড
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

      // 🔄 ইমেজ আপলোড সাইকেল (ওয়েব সেফ বাইটস রিড)
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

      // 📎 সব ইমেজ লিংক একসাথে করে কমা দিয়ে সেপারেট করা স্ট্রিং জেনারেশন
      String commaSeparatedImageUrls = uploadedUrls.isNotEmpty
          ? uploadedUrls.join(',')
          : "";

      // 🟢 ডাইনামিক বুকিং ও ক্যাটাগরি ডাটা ফিল্টারিং (ড্যাশবোর্ড মোডে অটোমেশন নাল হ্যান্ডেল করবে)
      final String? packageName = bookingData?['package_name'];
      final String? photographerName = bookingData?['photographer_name'];
      final String? categoryName = bookingData?['category_name'];
      final String? bookingId = bookingData?['booking_id'];

      final Map<String, dynamic> reviewData = {
        'user_id': userIdForUpload,
        'user_name':
            displayName, // লগইন থাকলে অরিজিনাল নাম, না থাকলে anonymous_user
        'user_email':
            displayEmail, // লগইন থাকলে অরিজিনাল ইমেইল, না থাকলে একদম খালি ""
        'comment': reviewController.text.trim(),
        'rating': rating,
        'review_image_url':
            commaSeparatedImageUrls, // কমা দিয়ে সাজানো ছবির স্ট্রিং
        'package_name': packageName,
        'photographer_name': photographerName,
        'category_name': categoryName, // 🎯 ডাইনামিক ক্যাটাগরি নেম সাপোর্ট
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
