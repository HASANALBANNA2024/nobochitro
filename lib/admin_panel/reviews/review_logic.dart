import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class ReviewLogic {
  /// Review Logic
  static Future<void> deleteReview(dynamic id) async {
    await DatabaseHelper.delete(table: 'reviews', column: 'id', value: id);
  }
}