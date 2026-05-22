import 'dart:convert'; // এটি অবশ্যই লাগবে
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class PhotographerLogic {

  static String generatePhotographerId() => 'PH-${DateTime.now().millisecondsSinceEpoch}';

  static Future<void> addPhotographer(Map<String, dynamic> data) async {
    // ডাটা সেভ করার সময় লিস্টকে স্ট্রিংয়ে রূপান্তর করা হচ্ছে
    final Map<String, dynamic> preparedData = Map<String, dynamic>.from(data);
    if (preparedData['recent_image_gallary_path'] is List) {
      preparedData['recent_image_gallary_path'] = jsonEncode(preparedData['recent_image_gallary_path']);
    }

    await DatabaseHelper.insert(table: 'photographers', data: preparedData);
  }

  static Future<void> updatePhotographerFull({
    required dynamic id,
    required Map<String, dynamic> data,
    required String? oldProfile,
    required String? oldBanner,
    required List<String> oldGallery,
  }) async {
    const String bucketName = 'user_assets';
    final storage = DatabaseHelper.client.storage.from(bucketName);

    // ইমেজ ডিলিট লজিক (আগের মতোই)
    if (oldProfile != null && oldProfile != data['profile_image_path'] && oldProfile.isNotEmpty) {
      await storage.remove([oldProfile]);
    }
    if (oldBanner != null && oldBanner != data['banner_image_path'] && oldBanner.isNotEmpty) {
      await storage.remove([oldBanner]);
    }
    List<String> newGallery = List<String>.from(data['recent_image_gallary_path'] ?? []);
    for (var path in oldGallery) {
      if (!newGallery.contains(path) && path.isNotEmpty) {
        await storage.remove([path]);
      }
    }

    // ডাটা আপডেট করার সময় লিস্টকে স্ট্রিংয়ে রূপান্তর
    final Map<String, dynamic> preparedData = Map<String, dynamic>.from(data);
    if (preparedData['recent_image_gallary_path'] is List) {
      preparedData['recent_image_gallary_path'] = jsonEncode(preparedData['recent_image_gallary_path']);
    }

    await DatabaseHelper.update(table: 'photographers', column: 'id', value: id, data: preparedData);
  }

  static Future<void> deletePhotographer(Map<String, dynamic> item) async {
    final String currentId = item['photographer_id'] ?? '';
    if (currentId.isEmpty) return;

    await DatabaseHelper.delete(table: 'photographers', column: 'id', value: item['id']);
    await DatabaseHelper.deleteFolder('photographers/$currentId');
  }
}