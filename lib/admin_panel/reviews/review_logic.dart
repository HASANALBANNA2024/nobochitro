import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class ReviewLogic {
  /// Review Delete Logic (Database + Storage)
  static Future<void> deleteReview(Map<String, dynamic> review) async {
    await DatabaseHelper.deleteWithStorage(
      table: 'reviews',
      column: 'id',
      value: review['id'],
      bucketName: 'user_assets',
      imagePath: review['review_image_path'],
    );
  }
}
