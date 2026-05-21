import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class AddonsLogic {
  static Future<void> addAddon(Map<String, dynamic> data) async {
    await DatabaseHelper.insert(table: 'addons', data: data);
  }

  static Future<void> updateAddon(dynamic id, Map<String, dynamic> data) async {
    await DatabaseHelper.update(table: 'addons', column: 'id', value: id, data: data);
  }

  static Future<void> deleteAddon(dynamic id) async {
    await DatabaseHelper.delete(table: 'addons', column: 'id', value: id);
  }
}