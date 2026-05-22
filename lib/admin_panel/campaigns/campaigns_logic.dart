import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class CampaignsLogic {
  static Future<void> add(Map<String, dynamic> data) async =>
      await DatabaseHelper.insert(table: 'campaigns', data: data);

  static Future<void> update(dynamic id, Map<String, dynamic> data) async =>
      await DatabaseHelper.update(
        table: 'campaigns',
        column: 'id',
        value: id,
        data: data,
      );

  // ডিলিট করার সময় ছবি ডিলিট লজিক
  static Future<void> deleteCampaign(Map<String, dynamic> item) async {
    // যদি ইমেজ পাথ থাকে, তবে আগে স্টোরেজ থেকে ডিলিট করো
    if (item['image_path'] != null &&
        item['image_path'].toString().isNotEmpty) {
      await DatabaseHelper.instance.deleteWithStorage(
        table: 'campaigns',
        column: 'id',
        value: item['id'],
        bucketName: 'user_assets', // তোমার বাকেট নাম নিশ্চিত করো
        imagePath: item['image_path'],
      );
    }
    // তারপর ডাটাবেস থেকে ডিলিট করো
    await DatabaseHelper.delete(
      table: 'campaigns',
      column: 'id',
      value: item['id'],
    );
  }
}
