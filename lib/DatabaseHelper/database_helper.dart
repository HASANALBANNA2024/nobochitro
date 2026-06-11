import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseHelper {
  DatabaseHelper();
  static final DatabaseHelper instance = DatabaseHelper();

  static final _client = Supabase.instance.client;

  /// to client use
  static SupabaseClient get client => _client;

  static Future<void> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _client.from(table).insert(data);
    } catch (e) {
      throw Exception("Insert Error: $e");
    }
  }

  static Future<void> update({
    required String table,
    required String column,
    required dynamic value,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _client.from(table).update(data).eq(column, value);
    } catch (e) {
      throw Exception("Update Error: $e");
    }
  }

  static Future<void> delete({
    required String table,
    required String column,
    required dynamic value,
  }) async {
    try {
      await _client.from(table).delete().eq(column, value);
    } catch (e) {
      throw Exception("Delete Error: $e");
    }
  }

  static Future<Map<String, String>?> uploadImageBytes({
    required String folder,
    required String userId,
    required Uint8List bytes,
  }) async {
    try {
      final String fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String fullPath = '$folder/$fileName';
      await _client.storage.from('user_assets').uploadBinary(fullPath, bytes);
      final String url = _client.storage
          .from('user_assets')
          .getPublicUrl(fullPath);
      return {'url': url, 'path': fullPath};
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteFolder(String folderPath) async {
    try {
      final List<FileObject> list = await _client.storage
          .from('user_assets')
          .list(path: folderPath);

      for (var file in list) {
        await _client.storage.from('user_assets').remove([
          '$folderPath/${file.name}',
        ]);
      }
      debugPrint("✅ Folder deleted: $folderPath");
    } catch (e) {
      debugPrint("Folder delete error: $e");
    }
  }

  ///Get Unique categories

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

  /// get photographer data receive
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

  ///  Get Photographers
  Future<List<Map<String, dynamic>>> getPhotographers() async {
    final response = await _client.from('photographers').select();
    return List<Map<String, dynamic>>.from(response);
  }

  /// result screen for category by use packages
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
      debugPrint("Error in insertBookingWithTransactionImage: $e");
      rethrow;
    }
  }

  /// My Bookings screen and user ar list
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

  /// Appeal image initiative initialization
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
      debugPrint("Error uploading appeal image: $e");
      return null;
    }
  }

  /// Get getCurrentUserId
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
      debugPrint("Bucket Upload Error: $e");
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
            'appeal_status': "request",
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
      debugPrint("Error in insertReview: $e");
      throw Exception("Failed to save review: $e");
    }
  }

  /// Fetch all reviews from Supabase 'reviews' table
  Future<List<Map<String, dynamic>>> getReviews() async {
    try {
      final response = await _client.from('reviews').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
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
      debugPrint("Error deleting review: $e");
      throw Exception("Failed to delete review: $e");
    }
  }

  /// Active Campaigns
  Future<Map<String, dynamic>?> getActiveCampaign() async {
    try {
      final response = await _client
          .from('campaigns')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint("Error fetching active campaign: $e");
      return null;
    }
  }

  /// Addons list receive for display
  Future<List<Map<String, dynamic>>> getAddons() async {
    try {
      final response = await _client
          .from('addons')
          .select()
          .order('addon_id', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching addons: $e");
      return [];
    }
  }

  ///getData
  Future<List<Map<String, dynamic>>> getData({required String table}) async {
    try {
      final response = await _client.from(table).select();
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint("Error fetching $table: $e");
      return [];
    }
  }

  /// all table data deleted with images

  static Future<void> deleteWithStorage({
    required String table,
    required String column,
    required dynamic value,
    required String bucketName,
    required String? imagePath,
  }) async {
    try {
      /// image delete of storage
      if (imagePath != null && imagePath.isNotEmpty) {
        await _client.storage.from(bucketName).remove([imagePath]);
        debugPrint("✅ Storage Image deleted: $imagePath");
      }

      /// delete
      await _client.from(table).delete().eq(column, value);
      debugPrint("✅ Data deleted from $table");
    } catch (e) {
      debugPrint("Delete Error: $e");
      throw Exception("Delete Operation Failed: $e");
    }
  }

  /// review image delete
  static Future<void> deleteFileFromStorage(String path) async {
    try {
      /// Supabase storage delete logic
      await _client.storage.from('review_images').remove([path]);
    } catch (e) {
      debugPrint("Storage Delete Error: $e");
    }
  }

  /// Community Gallery

  /// Dashboard screen ar function all image of category and all package gallery
  Future<List<String>> getAllCommunityImages() async {
    try {
      final pkgRes = await _client.from('packages').select('gallary_image_url');
      final phRes = await _client
          .from('photographers')
          .select('recent_image_gallary_path');

      List<String> allImages = [];

      /// package image processing
      for (var p in pkgRes as List) {
        final rawData = p['gallary_image_url'];
        if (rawData != null) {
          allImages.addAll(_parseStringToList(rawData));
        }
      }

      /// photographer image processing
      for (var ph in phRes as List) {
        final rawData = ph['recent_image_gallary_path'];
        if (rawData != null) {
          allImages.addAll(_parseStringToList(rawData));
        }
      }

      return allImages.toSet().toList();
    } catch (e) {
      print("Error fetching community images: $e");
      return [];
    }
  }

  /// string to list converter
  List<String> _parseStringToList(dynamic rawData) {
    if (rawData is List) {
      return List<String>.from(rawData);
    } else if (rawData is String) {
      // কমা দিয়ে আলাদা করা থাকলে স্প্লিট করবে
      return rawData
          .split(',')
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Package
  Future<List<String>> getPackageGallery(String packageId) async {
    final response = await _client
        .from('packages')
        .select('gallary_image_url')
        .eq('package_id', packageId)
        .maybeSingle();
    return response != null && response['gallary_image_url'] != null
        ? List<String>.from(response['gallary_image_url'])
        : [];
  }

  /// Photographers
  Future<List<String>> getPhotographerGallery(String photographerId) async {
    final response = await _client
        .from('photographers')
        .select('recent_image_gallary_path')
        .eq('photographer_id', photographerId)
        .maybeSingle();
    return response != null && response['recent_image_gallary_path'] != null
        ? List<String>.from(response['recent_image_gallary_path'])
        : [];
  }

  /// Categories
  Future<List<String>> getCategoryGallery(String categoryName) async {
    final response = await _client
        .from('packages')
        .select('gallary_image_url')
        .eq('category', categoryName);
    List<String> allImages = [];
    for (var p in response as List) {
      if (p['gallary_image_url'] != null)
        allImages.addAll(List<String>.from(p['gallary_image_url']));
    }
    return allImages;
  }
}
