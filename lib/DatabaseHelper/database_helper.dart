import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart'; // 👈 কাস্টম NSR ID মেথডের জন্য ফায়ারবেস অথ ইম্পোর্ট করা হলো
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseHelper {
  DatabaseHelper._();

  // ২. instance মেম্বারটি ডিফাইন করুন (এটি না থাকলে রেড লাইন আসবে)
  static final DatabaseHelper instance = DatabaseHelper._();

  // getcategoris of under of banner
  // database_helper.dart
  Future<List<String>> getUniqueCategories() async {
    try {
      final response = await _client.from('packages').select('category');

      final List<dynamic> data = response as List;
      // Set ব্যবহার করে ডুপ্লিকেট নাম বাদ দেওয়া হয়েছে
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

  // ৩. সুপাবেস ক্লায়েন্ট (আপনার আগের কোড অনুযায়ী)
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
  // উদাহরণ: বুকিং ক্যান্সেল হলে 'bookings' থেকে 'cancelled_bookings' 에 পাঠানো
  static Future<void> moveRow({
    required String fromTable,
    required String toTable,
    required String column,
    required dynamic value,
  }) async {
    try {
      // প্রথমে ডাটাটি খুঁজে বের করা
      final data = await _client
          .from(fromTable)
          .select()
          .eq(column, value)
          .single();

      if (data != null) {
        // নতুন টেবিলে ইনসার্ট করা
        await _client.from(toTable).insert(data);
        // আগের টেবিল থেকে ডিলিট করা
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
    required dynamic file, // File type
  }) async {
    try {
      final String fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = await _client.storage
          .from('user_assets')
          .upload('$folder/$fileName', file);

      // পাবলিক ইউআরএল গেট করা
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

  // database_helper.dart ফাইলের ভেতরে এটি যোগ করুন
  Future<List<Map<String, dynamic>>> getPackages() async {
    try {
      // Supabase বা SQLite থেকে packages টেবিলের সব ডাটা আনা হচ্ছে
      final response = await _client
          .from('packages') // আপনার টেবিল নাম
          .select() // সব কলাম সিলেক্ট করা হচ্ছে
          .order('id', ascending: true); // 𦿗মিকানুসারে সাজানোর জন্য (ঐচ্ছিক)

      // ডাটাগুলোকে লিস্ট হিসেবে রিটার্ন করা
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching packages: $e");
      return []; // কোনো এরর হলে খালি লিস্ট রিটার্ন করবে যাতে অ্যাপ ক্র্যাশ না করে
    }
  }

  // get photographers
  Future<List<Map<String, dynamic>>> getPhotographers() async {
    final response = await _client
        .from('photographers') // আপনার টেবিলের নাম
        .select();
    return List<Map<String, dynamic>>.from(response);
  }

  // get addons
  Future<List<Map<String, dynamic>>> getAddons() async {
    try {
      final response = await _client
          .from('addons') // আপনার সুপাবেস টেবিলের নাম
          .select()
          .eq('is_active', true); // শুধুমাত্র একটিভ আইটেমগুলো নিতে

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching addons: $e");
      return [];
    }
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

  /// payment transaction / verifications table insert data from bookings summary and payment sheet

  // ------------------------------------------------------------------------------------
  Future<void> insertBookingWithTransactionImage(
    Map<String, dynamic> bookingData,
  ) async {
    try {
      String? imageUrl;
      String? imageName = bookingData['transaction_image_name'];

      // 🔴 এখানে 'nobochitro' কেটে 'user_assets' করে দিন (হুবহু নিচের মতো)
      const String bucketName = 'user_assets';

      // ১. ইমেজ ফাইল বা বাইটস চেক করে বাকেটের ভেতর payment_transaction ফোল্ডারে আপলোড করা
      if (kIsWeb) {
        // ওয়েবের জন্য (Uint8List Bytes)
        final bytes = bookingData['transaction_image_file'];
        if (bytes != null && imageName != null) {
          // পাথের শুরুতে ফোল্ডারের নাম জুড়ে দেওয়া হলো
          final String path =
              'payment_transaction/web_${DateTime.now().millisecondsSinceEpoch}_$imageName';

          await _client.storage.from(bucketName).uploadBinary(path, bytes);

          imageUrl = _client.storage.from(bucketName).getPublicUrl(path);
        }
      } else {
        // অ্যান্ডরয়েড/আইওএস এর জন্য (File Object)
        final file = bookingData['transaction_image_file'] as File?;
        if (file != null && imageName != null) {
          // পাথের শুরুতে ফোল্ডারের নাম জুড়ে দেওয়া হলো
          final String path =
              'payment_transaction/mobile_${DateTime.now().millisecondsSinceEpoch}_$imageName';

          await _client.storage.from(bucketName).upload(path, file);

          imageUrl = _client.storage.from(bucketName).getPublicUrl(path);
        }
      }

      // ২. ডাটাবেস টেবিল ফরমেট অনুযায়ী ম্যাপ ক্লিনিং ও প্রিপারেশন
      final Map<String, dynamic> dbData = Map<String, dynamic>.from(
        bookingData,
      );
      dbData.remove('transaction_image_file');

      // টেবিলের কলামে ইমেজের পাবলিক URL সেট করা
      dbData['transaction_image_url'] = imageUrl;

      // 🔴 এখানে নিশ্চিত হয়ে নিন আপনার টেবিলের নাম 'payment_verifications' নাকি 'bookings'
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

      // 🟢 নিশ্চিত করুন এখানে টেবিলের নাম হুবহু 'payment_verifications' আছে
      final List<dynamic> response = await Supabase.instance.client
          .from('payment_verifications') // 👈 এই নামটা চেক করুন
          .select()
          .eq('user_id', userId);

      print("Log: Real Booking Data from Database: $response");

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Log: Severe Database Error in getUserBookings: $e");
      return [];
    }
  }

  // ====================================================================================

  Future<String?> getCurrentUserNsrId() async {
    try {
      final String? firebaseUid = FirebaseAuth.instance.currentUser?.uid;
      if (firebaseUid == null) {
        debugPrint("Helper Log: No Firebase User logged in.");
        return null;
      }

      final docSnap = await _client
          .from('users')
          .select('id') // আপনার সুপাবেস 'users' টেবিলের কাস্টম NSR ID কলাম
          .eq('user_id', firebaseUid)
          .maybeSingle();

      if (docSnap != null && docSnap['id'] != null) {
        return docSnap['id']
            .toString(); // সফল হলে রিটার্ন করবে (যেমন: NSR-995814)
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

  /// booking cancelletion notes ok
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

  /// apealed
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
        // ওয়েবের জন্য (Uint8List bytes)
        await _client.storage.from(bucketName).uploadBinary(path, file);
      } else {
        // অ্যান্ডরয়েড/আইওএস এর জন্য (File object)
        await _client.storage.from(bucketName).upload(path, file as File);
      }

      // আপলোড শেষে পাবলিক URL রিটার্ন
      return _client.storage.from(bucketName).getPublicUrl(path);
    } catch (e) {
      debugPrint("❌ Error uploading appeal image: $e");
      return null;
    }
  }

  // ====================================================================================
  // 🔑 ৩. নতুন আপিল রিকোয়ারমেন্টস এর জন্য প্রয়োজনীয় মেথডসমূহ (আগের সব ঠিক থাকবে)
  // ====================================================================================

  /// 👤 ১. কারেন্ট ইউজারের NSR ID তুলে আনার মেথড (ফাইল পাথে ব্যবহার করার জন্য)
  Future<String> getCurrentUserId() async {
    try {
      final String? nsrId = await getCurrentUserNsrId();
      if (nsrId != null) {
        return nsrId; // সফল হলে কাস্টম NSR ID রিটার্ন করবে (যেমন: NSR-995814)
      }

      // ব্যাকআপ হিসেবে যদি NSR ID না থাকে, ফায়ারবেস UID ব্যবহার করবে
      final String? firebaseUid = FirebaseAuth.instance.currentUser?.uid;
      if (firebaseUid != null) {
        return firebaseUid;
      }

      throw Exception("User not logged in!");
    } catch (e) {
      throw Exception("Failed to get User ID: $e");
    }
  }

  /// 📥 ২. ডাইনামিক কাস্টম পাথে ইমেজ 'user_assets' বাকেটে আপলোড করার মেথড
  Future<String?> uploadAppealImageWithPath(
    dynamic fileToUpload,
    String storagePath,
  ) async {
    try {
      const String bucketName = 'user_assets';

      if (kIsWeb) {
        // ওয়েবের জন্য (Uint8List Bytes)
        await _client.storage
            .from(bucketName)
            .uploadBinary(storagePath, fileToUpload as Uint8List);
      } else {
        // অ্যান্ডরয়েড/আইওএস এর জন্য (File Object)
        await _client.storage
            .from(bucketName)
            .upload(storagePath, fileToUpload as File);
      }

      // আপলোড হওয়া ফাইলের পাবলিক ইউআরএল রিটার্ন করা
      return _client.storage.from(bucketName).getPublicUrl(storagePath);
    } catch (e) {
      debugPrint("❌ Bucket Upload Error: $e");
      return null;
    }
  }

  ///  ডাটাবেজে আপিল নোট, ইমেজ ইউআরএল এবং কাউন্ট (১, ২, ৩) আপডেট করার মেথড

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
            'booking_status': 'suspended', // মেইন স্ট্যাটাস লক থাকবে
            'appeal_status': null,
            'appeal_note': appealNote,
            'appeal_image_url': appealImageUrl,
            'appeal_count': appealCount, // ডাটাবেজে নতুন কাউন্ট সেভ হবে
            'appeal_cancel_notes':
                null, // রি-আপিল করলে আগের রিজেকশন নোট মুছে ক্লিন হয়ে যাবে
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

  // ==========================================
  // 📸 নিচে এই নতুন মেথডটি হুবহু যোগ করুন
  // ==========================================
  static Future<String?> uploadImageBytes({
    required String folder,
    required String userId,
    required Uint8List bytes,
  }) async {
    try {
      final String fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      const String bucketName =
          'user_assets'; // 🟢 আপনার প্রজেক্টের সঠিক বাকেট নাম

      await _client.storage
          .from(bucketName)
          .uploadBinary('$folder/$fileName', bytes);

      return _client.storage.from(bucketName).getPublicUrl('$folder/$fileName');
    } catch (e) {
      debugPrint("❌ Error in uploadImageBytes: $e");
      return null;
    }
  }
}
