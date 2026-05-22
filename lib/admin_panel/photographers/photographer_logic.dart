import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class PhotographerLogic {
  // ১. নতুন ফটোগ্রাফার আইডি জেনারেটর
  static String generatePhotographerId() {
    return 'PH-${DateTime.now().millisecondsSinceEpoch}';
  }

  // ২. নতুন ডাটা ইনসার্ট
  static Future<void> addPhotographer(Map<String, dynamic> data) async {
    await DatabaseHelper.insert(table: 'photographers', data: data);
  }

  // ৩. আপডেট এবং পুরনো ছবি ডিলিট করার লজিক
  static Future<void> updatePhotographerFull({
    required dynamic id,
    required Map<String, dynamic> data,
    required String? oldProfile,
    required String? oldBanner,
    required List<String> oldGallery,
  }) async {
    const String bucketName = 'user_assets';

    // যদি নতুন প্রোফাইল ইমেজ আপলোড করা হয় (অর্থাৎ পাথ ভিন্ন হয়), পুরনোটি ডিলিট করুন
    if (oldProfile != null && oldProfile != data['profile_image_path']) {
      await DatabaseHelper.deleteWithStorage(
        table: 'photographers',
        column: 'id',
        value: id,
        bucketName: bucketName,
        imagePath: oldProfile,
      );
    }

    // যদি নতুন ব্যানার ইমেজ আপলোড করা হয়, পুরনোটি ডিলিট করুন
    if (oldBanner != null && oldBanner != data['banner_image_path']) {
      await DatabaseHelper.deleteWithStorage(
        table: 'photographers',
        column: 'id',
        value: id,
        bucketName: bucketName,
        imagePath: oldBanner,
      );
    }

    // পুরনো গ্যালারি ইমেজগুলো ডিলিট করুন (যেগুলো নতুন লিস্টে নেই)
    List<String> newGallery = List<String>.from(
      data['recent_image_gallary_path'] ?? [],
    );
    for (var path in oldGallery) {
      if (!newGallery.contains(path)) {
        await DatabaseHelper.deleteWithStorage(
          table: 'photographers',
          column: 'id',
          value: id,
          bucketName: bucketName,
          imagePath: path,
        );
      }
    }

    // সবশেষে ডাটাবেস আপডেট
    await DatabaseHelper.update(
      table: 'photographers',
      column: 'id',
      value: id,
      data: data,
    );
  }

  // ৪. ডিলিট ফটোগ্রাফার (সব ছবিসহ)
  static Future<void> deletePhotographer(Map<String, dynamic> item) async {
    final String bucketName = 'user_assets';

    // ১. প্রোফাইল ইমেজ ডিলিট
    if (item['profile_image_path'] != null &&
        item['profile_image_path'].toString().isNotEmpty) {
      await DatabaseHelper.deleteWithStorage(
        table: 'photographers',
        column: 'id',
        value: item['id'],
        bucketName: bucketName,
        imagePath: item['profile_image_path'],
      );
    }

    // ২. ব্যানার ইমেজ ডিলিট
    if (item['banner_image_path'] != null &&
        item['banner_image_path'].toString().isNotEmpty) {
      await DatabaseHelper.deleteWithStorage(
        table: 'photographers',
        column: 'id',
        value: item['id'],
        bucketName: bucketName,
        imagePath: item['banner_image_path'],
      );
    }

    // ৩. গ্যালারি ইমেজগুলো (লিস্ট আকারে থাকলে লুপ চালিয়ে) ডিলিট
    if (item['recent_image_gallary_path'] != null) {
      // যদি ডাটাবেসে লিস্ট হিসেবে থাকে, তবে সেটাকে লিস্টে কনভার্ট করা
      List<dynamic> galleryPaths = [];
      if (item['recent_image_gallary_path'] is String) {
        galleryPaths = item['recent_image_gallary_path'].toString().split(',');
      } else {
        galleryPaths = List<dynamic>.from(item['recent_image_gallary_path']);
      }

      for (var path in galleryPaths) {
        if (path.toString().isNotEmpty) {
          await DatabaseHelper.deleteWithStorage(
            table: 'photographers',
            column: 'id',
            value: item['id'],
            bucketName: bucketName,
            imagePath: path.toString(),
          );
        }
      }
    }

    // ৪. সব ইমেজ ডিলিট হওয়ার পর মূল ডাটাবেস এন্ট্রি ডিলিট করা
    await DatabaseHelper.delete(
      table: 'photographers',
      column: 'id',
      value: item['id'],
    );
  }
}
