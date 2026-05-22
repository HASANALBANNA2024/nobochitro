import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class AddonsLogic {
  static String generateAddonId() {
    String randomDigits = DateTime.now().millisecondsSinceEpoch.toString();
    return 'NSRADD${randomDigits.substring(randomDigits.length - 3)}';
  }

  static Future<void> addAddon(Map<String, dynamic> data) async {
    // ID জেনারেট করে ডাটাবেসে পাঠানো
    final Map<String, dynamic> finalData = Map<String, dynamic>.from(data);
    finalData['addon_id'] = generateAddonId();

    // DatabaseHelper.insert সরাসরি কল করা হচ্ছে
    await DatabaseHelper.insert(table: 'addons', data: finalData);
  }

  static Future<void> updateAddon(dynamic id, Map<String, dynamic> data) async {
    await DatabaseHelper.update(
      table: 'addons',
      column: 'id',
      value: id,
      data: data,
    );
  }

  static Future<void> deleteAddon(Map<String, dynamic> item) async {
    // ডাটাবেস এবং স্টোরেজ একসাথে ডিলিট
    await DatabaseHelper.deleteWithStorage(
      table: 'addons',
      column: 'id',
      value: item['id'],
      bucketName: 'user_assets',
      imagePath: item['image_path']?.toString(),
    );
  }
}
