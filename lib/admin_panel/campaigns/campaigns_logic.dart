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

  /// delete with image
  static Future<void> deleteCampaign(Map<String, dynamic> item) async {
    if (item['image_path'] != null &&
        item['image_path'].toString().isNotEmpty) {
      await DatabaseHelper.deleteWithStorage(
        table: 'campaigns',
        column: 'id',
        value: item['id'],
        bucketName: 'user_assets',
        imagePath: item['image_path'],
      );
    }

    /// delete database
    await DatabaseHelper.delete(
      table: 'campaigns',
      column: 'id',
      value: item['id'],
    );
  }
}
