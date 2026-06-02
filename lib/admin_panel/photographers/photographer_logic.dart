import 'dart:convert';
import 'dart:math';

import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotographerLogic {
  static String generatePhotographerId() {
    final random = Random().nextInt(900000) + 100000;
    return 'PH-$random';
  }

  /// add photographer
  static Future<void> addPhotographer(Map<String, dynamic> data) async {
    final Map<String, dynamic> preparedData = Map<String, dynamic>.from(data);
    if (preparedData['recent_image_gallary_path'] is List) {
      preparedData['recent_image_gallary_path'] = jsonEncode(
        preparedData['recent_image_gallary_path'],
      );
    }

    await DatabaseHelper.insert(table: 'photographers', data: preparedData);
  }

  /// update photographer
  static Future<void> updatePhotographerFull({
    required dynamic id,
    required Map<String, dynamic> data,
    required String? oldProfile,
    required String? oldBanner,
    required List<String> oldGallery,
  }) async {
    const String bucketName = 'user_assets';
    final storage = DatabaseHelper.client.storage.from(bucketName);

    /// image logic
    if (oldProfile != null &&
        oldProfile.isNotEmpty &&
        oldProfile != data['profile_image_path']) {
      try {
        await storage.remove([oldProfile]);
      } catch (e) {
        print("Profile delete error: $e");
      }
    }

    /// banner image change
    if (oldBanner != null &&
        oldBanner.isNotEmpty &&
        oldBanner != data['banner_image_path']) {
      try {
        await storage.remove([oldBanner]);
      } catch (e) {
        print("Banner delete error: $e");
      }
    }

    /// gallery image delete
    List<String> newGallery = List<String>.from(
      data['recent_image_gallary_path'] ?? [],
    );
    for (var path in oldGallery) {
      if (!newGallery.contains(path) && path.isNotEmpty) {
        try {
          await storage.remove([path]);
        } catch (e) {
          print("Gallery delete error: $e");
        }
      }
    }

    ///data preparation and declaration
    final Map<String, dynamic> preparedData = Map<String, dynamic>.from(data);

    /// before string convert to send database
    if (preparedData['recent_image_gallary_path'] is List) {
      preparedData['recent_image_gallary_path'] = jsonEncode(
        preparedData['recent_image_gallary_path'],
      );
    }

    /// database update
    await DatabaseHelper.update(
      table: 'photographers',
      column: 'id',
      value: id,
      data: preparedData,
    );
  }

  ///delete photographer
  static Future<void> deletePhotographer(Map<String, dynamic> item) async {
    final String currentId = item['photographer_id'] ?? '';

    /// id path
    if (currentId.isEmpty) return;

    /// database row delete
    await DatabaseHelper.delete(
      table: 'photographers',
      column: 'id',
      value: item['id'],
    );

    /// delete of storage of logic
    final storage = DatabaseHelper.client.storage.from('user_assets');

    try {
      /// folders
      final List<FileObject> files = await storage.list(
        path: 'photographers/$currentId',
      );

      if (files.isNotEmpty) {
        /// remove list
        List<String> pathsToDelete = files
            .map((file) => 'photographers/$currentId/${file.name}')
            .toList();

        /// remove
        await storage.remove(pathsToDelete);
      }
    } catch (e) {
      print("File delete error: $e");
    }
  }
}
