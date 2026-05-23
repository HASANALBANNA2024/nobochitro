import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewController {
  int rating = 0;
  final TextEditingController reviewController = TextEditingController();
  final List<XFile> selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  String displayName = "anonymous_user";
  String displayEmail = "";
  String? userPhotoUrl;
  String? customNsrId;

  void setManualUserInformation({required String name, required String email, String? avatarUrl}) {
    if (name.trim().isNotEmpty) displayName = name;
    if (email.trim().isNotEmpty) displayEmail = email;
    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) userPhotoUrl = avatarUrl;
  }

  Future<void> loadUserInformation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      customNsrId = await DatabaseHelper.instance.getCurrentUserNsrId();
      displayName = user.displayName ?? (user.email != null ? user.email!.split('@')[0] : "anonymous_user");
      displayEmail = user.email ?? "";
      userPhotoUrl = customNsrId != null
          ? "https://ijxtbmgvtwvpkbshunwf.supabase.co/storage/v1/object/public/user_assets/profile_user_image/$customNsrId.jpg"
          : user.photoURL;
    }
  }

  Future<void> pickImage(VoidCallback onUpdate) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) { selectedImages.add(image); onUpdate(); }
  }

  void removeImage(int index, VoidCallback onUpdate) {
    selectedImages.removeAt(index);
    onUpdate();
  }

  // রিভিউ সাবমিট মেথড
  Future<bool> submitReview({
    required BuildContext context,
    Map<String, dynamic>? bookingData,
    required VoidCallback onLoadingToggle,
  }) async {
    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ Please select a rating star!")));
      return false;
    }
    isLoading = true; onLoadingToggle();
    try {
      List<String> uploadedUrls = [];
      List<String> uploadedPaths = []; // পাথ লিস্ট

      for (int i = 0; i < selectedImages.length; i++) {
        final bytes = await selectedImages[i].readAsBytes();
        final String fileName = "${FirebaseAuth.instance.currentUser?.uid ?? 'anon'}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg";
        final String fullPath = 'review_images/$fileName';

        final imageData = await DatabaseHelper.uploadImageBytes(
          folder: 'review_images',
          userId: fileName,
          bytes: bytes,
        );
        if (imageData != null && imageData.containsKey('url')) {
          uploadedUrls.add(imageData['url']!);
          uploadedPaths.add(fullPath); // পাথ সেভ হচ্ছে
        }
      }

      final Map<String, dynamic> reviewData = {
        'user_id': customNsrId ?? FirebaseAuth.instance.currentUser?.uid ?? "anonymous",
        'user_name': displayName,
        'rating': rating,
        'comment': reviewController.text.trim(),
        'review_image_url': uploadedUrls,
        'review_image_path': uploadedPaths, // এখানে পাথ লিস্ট যাচ্ছে
        'package_name': bookingData?['package_name'],
        'category_name': bookingData?['package_category'] ?? bookingData?['category_name'],
        'photographer_name': bookingData?['photographer_name'],
        'created_at': DateTime.now().toIso8601String(),
      };

      await DatabaseHelper.insertReview(reviewData);
      return true;
    } catch (e) {
      debugPrint("Post Error: $e");
      return false;
    } finally {
      isLoading = false; onLoadingToggle();
    }
  }
  // 🗑️ ডিলিট মেথড (ইমেজ সহ ডিলিট)
  static Future<void> deleteReviewWithImages(Map<String, dynamic> review) async {
    try {
      // স্টোরেজ থেকে ফাইল ডিলিট
      final storage = DatabaseHelper.client.storage.from('user_assets');

      // ডাটাবেস থেকে পাথ লিস্ট নিন
      final dynamic rawPaths = review['review_image_path'];

      if (rawPaths != null && rawPaths is List) {
        List<String> pathsToDelete = List<String>.from(rawPaths);

        if (pathsToDelete.isNotEmpty) {
          await storage.remove(pathsToDelete);
          print("Storage files deleted successfully!");
        }
      }

      // সবশেষে ডাটাবেস রো ডিলিট করুন
      await DatabaseHelper.delete(table: 'reviews', column: 'id', value: review['id']);
      print("Review deleted from database!");

    } catch (e) {
      print("Delete Error: $e");
    }
  }
}