import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class PackageLogic {
  static Future<void> add(Map<String, dynamic> data) async => await DatabaseHelper.insert(table: 'packages', data: data);
  static Future<void> update(dynamic id, Map<String, dynamic> data) async => await DatabaseHelper.update(table: 'packages', column: 'id', value: id, data: data);
  static Future<void> delete(dynamic id) async => await DatabaseHelper.delete(table: 'packages', column: 'id', value: id);
}