import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class AddonsLogic {
  static String generateAddonId() {
    String randomDigits = DateTime.now().millisecondsSinceEpoch.toString();
    return 'NSRADD${randomDigits.substring(randomDigits.length - 3)}';
  }

  static Future<void> addAddon(Map<String, dynamic> data) async {
    /// Id Generate and passed to database
    final Map<String, dynamic> finalData = Map<String, dynamic>.from(data);
    finalData['addon_id'] = generateAddonId();

    /// database helper insert
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
    /// database storage delete
    await DatabaseHelper.deleteWithStorage(
      table: 'addons',
      column: 'id',
      value: item['id'],
      bucketName: 'user_assets',
      imagePath: item['image_path']?.toString(),
    );
  }
}
