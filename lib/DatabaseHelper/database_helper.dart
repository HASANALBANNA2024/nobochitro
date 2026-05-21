import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  // get categories of under of banner
  Future<List<String>> getUniqueCategories() async {
    try {
      final response = await _client.from('packages').select('category');

      final List<dynamic> data = response as List;
      final categories = data
          .map((item) => item['category'].toString())
          .where((cat) => cat.isNotEmpty)
          .toSet()
          .toList();

      return categories;
    } catch (e) {
      debugPrint("Error fetching unique categories: $e");
      return [];
    }
  }

  static final _client = Supabase.instance.client;

  // ১. ডাটা ইনসার্ট করা (Create)
  static Future<void> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _client.from(table).insert(data);
    } catch (e) {
      throw Exception("Insert Error in $table: $e");
    }
  }

  // ২. ডাটা আপডেট করা (Update)
  static Future<void> update({
    required String table,
    required String column,
    required dynamic value,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _client.from(table).update(data).eq(column, value);
    } catch (e) {
      throw Exception("Update Error in $table: $e");
    }
  }

  // ৩. ডাটা ডিলিট করা (Delete)
  static Future<void> delete({
    required String table,
    required String column,
    required dynamic value,
  }) async {
    try {
      await _client.from(table).delete().eq(column, value);
    } catch (e) {
      throw Exception("Delete Error in $table: $e");
    }
  }

  // ৪. এক টেবিল থেকে অন্য টেবিলে ডাটা ট্রান্সফার (Replace Logic)
  static Future<void> moveRow({
    required String fromTable,
    required String toTable,
    required String column,
    required dynamic value,
  }) async {
    try {
      final data = await _client
          .from(fromTable)
          .select()
          .eq(column, value)
          .single();

      if (data != null) {
        await _client.from(toTable).insert(data);
        await _client.from(fromTable).delete().eq(column, value);
      }
    } catch (e) {
      throw Exception("Move Row Error: $e");
    }
  }

  // ৫. ইমেজ আপলোড সার্ভিস (Storage)
  static Future<String?> uploadImage({
    required String folder,
    required String userId,
    required dynamic file,
  }) async {
    try {
      final String fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = await _client.storage
          .from('user_assets')
          .upload('$folder/$fileName', file);

      return _client.storage
          .from('user_assets')
          .getPublicUrl('$folder/$fileName');
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }

  // ডাটা রিয়েল-টাইম পাওয়ার জন্য স্ট্রিম মেথড
  static Stream<List<Map<String, dynamic>>> getPhotographerStream() {
    return _client
        .from('photographers')
        .stream(primaryKey: ['photographer_id']);
  }

  Future<List<Map<String, dynamic>>> getPackages() async {
    try {
      final response = await _client
          .from('packages')
          .select()
          .order('id', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching packages: $e");
      return [];
    }
  }

  // get photographers
  Future<List<Map<String, dynamic>>> getPhotographers() async {
    final response = await _client.from('photographers').select();
    return List<Map<String, dynamic>>.from(response);
  }

  // result screen for cateogry by use packages
  Future<List<Map<String, dynamic>>> getPackagesByCategory(
    String categoryName,
  ) async {
    final response = await _client
        .from('packages')
        .select()
        .eq('category', categoryName);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> insertBookingWithTransactionImage(
    Map<String, dynamic> bookingData,
  ) async {
    try {
      String? imageUrl;
      String? imageName = bookingData['transaction_image_name'];
      const String bucketName = 'user_assets';

      if (kIsWeb) {
        final bytes = bookingData['transaction_image_file'];
        if (bytes != null && imageName != null) {
          final String path =
              'payment_transaction/web_${DateTime.now().millisecondsSinceEpoch}_$imageName';

          await _client.storage.from(bucketName).uploadBinary(path, bytes);
          imageUrl = _client.storage.from(bucketName).getPublicUrl(path);
        }
      } else {
        final file = bookingData['transaction_image_file'] as File?;
        if (file != null && imageName != null) {
          final String path =
              'payment_transaction/mobile_${DateTime.now().millisecondsSinceEpoch}_$imageName';

          await _client.storage.from(bucketName).upload(path, file);
          imageUrl = _client.storage.from(bucketName).getPublicUrl(path);
        }
      }

      final Map<String, dynamic> dbData = Map<String, dynamic>.from(
        bookingData,
      );
      dbData.remove('transaction_image_file');
      dbData['transaction_image_url'] = imageUrl;

      await _client.from('payment_verifications').insert(dbData);
      debugPrint("✅ Booking and Payment Data Successfully Saved!");
    } catch (e) {
      debugPrint("❌ Error in insertBookingWithTransactionImage: $e");
      rethrow;
    }
  }

  // My Bookings screen and user ar list
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      print("Log: Fetching bookings for User ID: $userId");

      final List<dynamic> response = await Supabase.instance.client
          .from('payment_verifications')
          .select()
          .eq('user_id', userId);

      print("Log: Real Booking Data from Database: $response");
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Log: Severe Database Error in getUserBookings: $e");
      return [];
    }
  }

  Future<String?> getCurrentUserNsrId() async {
    try {
      final String? firebaseUid = FirebaseAuth.instance.currentUser?.uid;
      if (firebaseUid == null) {
        debugPrint("Helper Log: No Firebase User logged in.");
        return null;
      }

      final docSnap = await _client
          .from('users')
          .select('id')
          .eq('user_id', firebaseUid)
          .maybeSingle();

      if (docSnap != null && docSnap['id'] != null) {
        return docSnap['id'].toString();
      }

      debugPrint(
        "Helper Log: Firebase UID matched no user in Supabase 'users' table.",
      );
      return null;
    } catch (e) {
      debugPrint(
        "Helper Log: Severe Error fetching NSR ID from global utility: $e",
      );
      return null;
    }
  }

  Future<void> updateBookingCancellation({
    required String bookingId,
    required String cancellationNotes,
    required String newStatus,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('payment_verifications')
          .update({
            'booking_status': newStatus,
            'cancellation_notes': cancellationNotes,
            'cancelled_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('booking_id', bookingId);
    } catch (e) {
      throw Exception(
        "Database Error: Failed to update cancellation. Details: $e",
      );
    }
  }

  // 📥 ১. আপিল ইমেজ/স্ক্রিনশট 'user_assets' বাকেটের আন্ডারে আপলোড করার মেথড
  Future<String?> uploadAppealImage(
    dynamic file,
    String imageName,
    String bookingId,
  ) async {
    try {
      const String bucketName = 'user_assets';
      final String path =
          'appeals/${bookingId}_${DateTime.now().millisecondsSinceEpoch}_$imageName';

      if (kIsWeb) {
        await _client.storage.from(bucketName).uploadBinary(path, file);
      } else {
        await _client.storage.from(bucketName).upload(path, file as File);
      }

      return _client.storage.from(bucketName).getPublicUrl(path);
    } catch (e) {
      debugPrint("❌ Error uploading appeal image: $e");
      return null;
    }
  }

  Future<String> getCurrentUserId() async {
    try {
      final String? nsrId = await getCurrentUserNsrId();
      if (nsrId != null) {
        return nsrId;
      }

      final String? firebaseUid = FirebaseAuth.instance.currentUser?.uid;
      if (firebaseUid != null) {
        return firebaseUid;
      }

      throw Exception("User not logged in!");
    } catch (e) {
      throw Exception("Failed to get User ID: $e");
    }
  }

  Future<String?> uploadAppealImageWithPath(
    dynamic fileToUpload,
    String storagePath,
  ) async {
    try {
      const String bucketName = 'user_assets';

      if (kIsWeb) {
        await _client.storage
            .from(bucketName)
            .uploadBinary(storagePath, fileToUpload as Uint8List);
      } else {
        await _client.storage
            .from(bucketName)
            .upload(storagePath, fileToUpload as File);
      }

      return _client.storage.from(bucketName).getPublicUrl(storagePath);
    } catch (e) {
      debugPrint("❌ Bucket Upload Error: $e");
      return null;
    }
  }

  Future<void> submitSuspensionAppeal({
    required String bookingId,
    required String appealNote,
    String? appealImageUrl,
    required int appealCount,
  }) async {
    try {
      await _client
          .from('payment_verifications')
          .update({
            'booking_status': 'suspended',
            'appeal_status': null,
            'appeal_note': appealNote,
            'appeal_image_url': appealImageUrl,
            'appeal_count': appealCount,
            'appeal_cancel_notes': null,
            'appeal_time_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('booking_id', bookingId);

      debugPrint(
        "✅ Appeal submitted & appeal_status set to null for #$bookingId",
      );
    } catch (e) {
      throw Exception("Database Error: Failed to submit appeal. Details: $e");
    }
  }

  /// Review Sheet insert
  static Future<void> insertReview(Map<String, dynamic> reviewData) async {
    try {
      await _client.from('reviews').insert(reviewData);
      debugPrint("✅ Review successfully saved to Supabase!");
    } catch (e) {
      debugPrint("❌ Error in insertReview: $e");
      throw Exception("Failed to save review: $e");
    }
  }

  static Future<String?> uploadImageBytes({
    required String folder,
    required String userId,
    required Uint8List bytes,
  }) async {
    try {
      final String fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      const String bucketName = 'user_assets';

      await _client.storage
          .from(bucketName)
          .uploadBinary('$folder/$fileName', bytes);

      return _client.storage.from(bucketName).getPublicUrl('$folder/$fileName');
    } catch (e) {
      debugPrint("❌ Error in uploadImageBytes: $e");
      return null;
    }
  }

  // ==========================================
  // 📸 NEW METHODS ADDED BELOW FOR REVIEWS
  // ==========================================

  /// Fetch all reviews from Supabase 'reviews' table
  Future<List<Map<String, dynamic>>> getReviews() async {
    try {
      final response = await _client.from('reviews').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("❌ Error fetching reviews: $e");
      return [];
    }
  }

  /// Delete a specific review by its unique identifier (e.g., review_id or id)
  Future<void> deleteReview({
    required String column,
    required dynamic value,
  }) async {
    try {
      await _client.from('reviews').delete().eq(column, value);
      debugPrint("✅ Review successfully deleted from Supabase!");
    } catch (e) {
      debugPrint("❌ Error deleting review: $e");
      throw Exception("Failed to delete review: $e");
    }
  }

  // campaign
  // Get active campaign from Supabase
  Future<Map<String, dynamic>?> getActiveCampaign() async {
    try {
      final response = await _client
          .from('campaigns')
          .select()
          .eq('is_active', true) // শুধুমাত্র অ্যাক্টিভ ক্যাম্পেইন
          .order('created_at', ascending: false) // সবচেয়ে লেটেস্ট
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint("❌ Error fetching active campaign: $e");
      return null;
    }
  }

  // campaign data(dummy)
  static Future<void> insertDemoCampaignOnStart() async {
    try {
      // ১. প্রথমে চেক করে দেখা অলরেডি কোনো একটিভ ক্যাম্পেইন আছে কি না
      final activeCampaign = await instance.getActiveCampaign();

      if (activeCampaign != null) {
        debugPrint(
          "ℹ️ Supabase-এ অলরেডি একটিভ ক্যাম্পেইন আছে। নতুন করে ডামি ডাটা লাগবে না।",
        );
        return;
      }

      // ২. জেনেরিক এবং র‍্যান্ডম campaign_id তৈরি লজিক (NSRB + ৪ ডিজিট)
      final random = Random();
      final int randomNumber = 1000 + random.nextInt(9000);
      final String generatedCampaignId = "NSRB$randomNumber";

      // ৩. আজকের তারিখ এবং ২ দিন পরের তারিখ তৈরি
      final now = DateTime.now();

      // 🎯 YYYY-MM-DD ফরম্যাটে রূপান্তর (সুপাবেস date কলামের জন্য পারফেক্ট)
      final String formattedStartDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final endDate = now.add(const Duration(days: 2));
      final String formattedEndDate =
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

      // ৪. ডামি ডাটা স্ট্রাকচার (টেবিলের প্রতিটি কলামের নাম ও টাইপ হুবহু মেইনটেইন করা হয়েছে)
      final Map<String, dynamic> demoCampaign = {
        'campaign_id': generatedCampaignId, // text কলাম
        'title': 'EXCLUSIVE CAMPAIGN! 50% OFF', // text কলাম
        'banner_url':
            'https://images.pexels.com/photos/1036622/pexels-photo-1036622.jpeg', // text কলাম
        'discount_pct': 50, // int4 কলাম
        // 🎯 নতুন লজিক অনুযায়ী কমা দিয়ে আলাদা করা মাল্টিপল ক্যাটাগরি দেওয়া হলো
        'targeted_category': 'Portrait, Wedding, Event', // text কলাম

        'is_active': true, // bool কলাম
        'start_date': formattedStartDate, // date কলাম
        'end_date': formattedEndDate, // date কলাম
        'created_at': now.toIso8601String(), // timestamptz কলাম
      };

      // ৫. ডাটাবেজে ইনসার্ট করা
      await insert(table: 'campaigns', data: demoCampaign);

      debugPrint("✅ সফলভাবে সব কলাম মেইনটেইন করে ডামি ডাটা ইনসার্ট হয়েছে!");
      debugPrint(
        "🎟️ কুপন কোড: $generatedCampaignId | ক্যাটাগরি: Portrait, Wedding, Event",
      );
    } catch (e) {
      debugPrint("❌ DatabaseHelper ডামি ডাটা ইনসার্ট এরর: $e");
    }
  }

  // addons
  // ==========================================
  // 📸 ADDONS OPERATIONS (CRUD)
  // ==========================================

  /// ১. Addons লিস্ট পাওয়ার জন্য
  Future<List<Map<String, dynamic>>> getAddons() async {
    try {
      // তুমি যদি সব ডাটা চাও, তবে .eq('is_active', true) অংশটুকু বাদ দিতে পারো
      final response = await _client
          .from('addons')
          .select()
          .order('addon_id', ascending: true); // আইডি অনুযায়ী সাজিয়ে আনবে

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("❌ Error fetching addons: $e");
      return [];
    }
  }

  /// ২. নতুন Addon যোগ করার জন্য (ইমেজ আপলোডসহ ডাটা ইনসার্ট)
  Future<void> insertAddon(Map<String, dynamic> addonData) async {
    try {
      await _client.from('addons').insert(addonData);
      debugPrint("✅ Addon successfully inserted!");
    } catch (e) {
      debugPrint("❌ Error inserting addon: $e");
      throw Exception("Failed to insert addon: $e");
    }
  }

  /// ৩. নির্দিষ্ট Addon আপডেট করার জন্য (সঠিক করা হয়েছে)
  Future<void> updateAddon({
    required dynamic id, // এখানে 'addon_id' এর বদলে 'id' দিয়েছি
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      await _client
          .from('addons')
          .update(updatedData)
          .eq('id', id); // এখানে 'addon_id' এর বদলে 'id' ব্যবহার করেছি
      debugPrint("✅ Addon successfully updated!");
    } catch (e) {
      debugPrint("❌ Error updating addon: $e");
      throw Exception("Failed to update addon: $e");
    }
  }

  /// ৪. নির্দিষ্ট Addon ডিলিট করার জন্য (সঠিক করা হয়েছে)
  Future<void> deleteAddon(dynamic id) async {
    try {
      await _client
          .from('addons')
          .delete()
          .eq('id', id); // এখানেও 'addon_id' এর বদলে 'id' ব্যবহার করেছি
      debugPrint("✅ Addon successfully deleted!");
    } catch (e) {
      debugPrint("❌ Error deleting addon: $e");
      throw Exception("Failed to delete addon: $e");
    }
  }
}
