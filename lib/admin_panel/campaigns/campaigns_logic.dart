import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class CampaignsLogic {
  static Future<void> add(Map<String, dynamic> data) async =>
      await DatabaseHelper.insert(table: 'campaigns', data: data);

  static Future<void> update(dynamic id, Map<String, dynamic> data) async =>
      await DatabaseHelper.update(table: 'campaigns', column: 'id', value: id, data: data);

  static Future<void> delete(dynamic id) async =>
      await DatabaseHelper.delete(table: 'campaigns', column: 'id', value: id);
}