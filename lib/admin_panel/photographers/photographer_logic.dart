import 'dart:math';

import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class PhotographerLogic {
  static String generatePhotographerId() =>
      'N-${100000 + Random().nextInt(899999)}';

  static Future<void> addPhotographer(Map<String, dynamic> data) async {
    final Map<String, dynamic> finalData = Map.from(data);
    finalData['photographer_id'] = generatePhotographerId();
    await DatabaseHelper.insert(table: 'photographers', data: finalData);
  }

  // আপডেট লজিক: এখানে আগের ইমেজ পাথগুলো পাঠিয়ে ডিলিট করতে হবে
  static Future<void> updatePhotographerFull({
    required dynamic id,
    required Map<String, dynamic> data,
    String? oldProfile,
    String? oldBanner,
    List<String>? oldGallery,
  }) async {
    // প্রোফাইল ও ব্যানার চেক
    if (oldProfile != null && data['profile_image_path'] != oldProfile) {
      await DatabaseHelper.deleteWithStorage(
        table: 'photographers',
        column: 'id',
        value: id,
        bucketName: 'user_assets',
        imagePath: oldProfile,
      );
    }
    if (oldBanner != null && data['banner_image_path'] != oldBanner) {
      await DatabaseHelper.deleteWithStorage(
        table: 'photographers',
        column: 'id',
        value: id,
        bucketName: 'user_assets',
        imagePath: oldBanner,
      );
    }

    // গ্যালারি চেক
    if (oldGallery != null) {
      for (var path in oldGallery) {
        if (!(data['recent_image_gallary_path'] as List).contains(path)) {
          await DatabaseHelper.deleteWithStorage(
            table: 'photographers',
            column: 'id',
            value: id,
            bucketName: 'user_assets',
            imagePath: path,
          );
        }
      }
    }
    await DatabaseHelper.update(
      table: 'photographers',
      column: 'id',
      value: id,
      data: data,
    );
  }

  static Future<void> deletePhotographer(Map<String, dynamic> item) async {
    final String folderPath =
        'photographers/profile/${item['photographer_id']}';
    await DatabaseHelper.deleteFolder(folderPath);
    await DatabaseHelper.delete(
      table: 'photographers',
      column: 'id',
      value: item['id'],
    );
  }
}
