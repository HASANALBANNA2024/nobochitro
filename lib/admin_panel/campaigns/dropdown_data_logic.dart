import 'package:nobochitro/DatabaseHelper/database_helper.dart';
class DropdownDataLogic {
  /// unique category
  static Future<List<String>> getUniqueCategories() async {
    final allPackages = await DatabaseHelper.instance.getData(table: 'packages');
    final categories = allPackages
        .map((e) => e['category'].toString())
        .where((cat) => cat.isNotEmpty)
        .toSet()
        .toList();
    return categories;
  }
  //unique package
  static Future<List<String>> getUniquePackageTitles() async {
    final allPackages = await DatabaseHelper.instance.getData(table: 'packages');
    final titles = allPackages
        .map((e) => e['title'].toString())
        .where((title) => title.isNotEmpty)
        .toSet()
        .toList();
    return titles;
  }
}