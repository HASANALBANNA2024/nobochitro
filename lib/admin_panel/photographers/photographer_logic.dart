import 'dart:math';

import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class PhotographerLogic {
  static String generatePhotographerId() =>
      'N-${100000 + Random().nextInt(899999)}';

  // নতুন ডাটা যোগ
  static Future<void> addPhotographer(Map<String, dynamic> data) async {
    final Map<String, dynamic> finalData = Map.from(data);
    finalData['photographer_id'] = generatePhotographerId();
    await DatabaseHelper.insert(table: 'photographers', data: finalData);
  }

  // আপডেট: নতুন ইমেজ আসলে পুরানোটা মুছে ফেলবে
  static Future<void> updatePhotographerWithImage({
    required dynamic id,
    required Map<String, dynamic> data,
    String? oldProfilePath,
    String? oldBannerPath,
  }) async {
    // প্রোফাইল ইমেজ পরিবর্তন হলে পুরানোটা ডিলিট
    if (oldProfilePath != null &&
        data['profile_image_path'] != oldProfilePath) {
      await DatabaseHelper.deleteWithStorage(
        table: 'photographers',
        column: 'id',
        value: id,
        bucketName: 'user_assets',
        imagePath: oldProfilePath,
      );
    }
    // ব্যানার ইমেজ পরিবর্তন হলে পুরানোটা ডিলিট
    if (oldBannerPath != null && data['banner_image_path'] != oldBannerPath) {
      await DatabaseHelper.deleteWithStorage(
        table: 'photographers',
        column: 'id',
        value: id,
        bucketName: 'user_assets',
        imagePath: oldBannerPath,
      );
    }

    await DatabaseHelper.update(
      table: 'photographers',
      column: 'id',
      value: id,
      data: data,
    );
  }

  // ডিলিট: ফোল্ডারসহ সব মুছে ফেলা
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
