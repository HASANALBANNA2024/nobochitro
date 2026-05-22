import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class PackageLogic {
  static Future<void> add(Map<String, dynamic> data) async =>
      await DatabaseHelper.insert(table: 'packages', data: data);

  static Future<void> update(dynamic id, Map<String, dynamic> data) async =>
      await DatabaseHelper.update(
        table: 'packages',
        column: 'id',
        value: id,
        data: data,
      );

  /// প্যাকেজ এবং তার ছবিগুলো ডিলিট করার নতুন লজিক
  static Future<void> deletePackage(Map<String, dynamic> package) async {
    // ১. প্রোফাইল ইমেজ ডিলিট
    if (package['image_path'] != null) {
      await DatabaseHelper.instance.deleteWithStorage(
        table: 'packages',
        column: 'id',
        value: package['id'],
        bucketName: 'user_assets',
        imagePath: package['image_path'],
      );
    }

    // ২. গ্যালারি ইমেজগুলো ডিলিট
    if (package['gallery_paths'] != null) {
      List<String> paths = package['gallery_paths'].toString().split(',');
      for (String path in paths) {
        if (path.isNotEmpty) {
          await DatabaseHelper.instance.deleteWithStorage(
            table: 'packages',
            column: 'id',
            value: package['id'],
            bucketName: 'user_assets',
            imagePath: path,
          );
        }
      }
    }

    // ৩. ফাইনাল ডিলিট (যদি উপরেরগুলো বাদে শুধু ডাটা ডিলিট করতে চাও)
    await DatabaseHelper.delete(
      table: 'packages',
      column: 'id',
      value: package['id'],
    );
  }

  static Future<void> updatePackage(
    dynamic id,
    Map<String, dynamic> newData,
    Map<String, dynamic> oldData,
  ) async {
    final String bucketName = 'user_assets';

    // ১. প্রোফাইল ইমেজ পরিবর্তন হলে পুরোনোটি ডিলিট করো
    if (newData['image_path'] != null &&
        newData['image_path'] != oldData['image_path']) {
      if (oldData['image_path'] != null) {
        await DatabaseHelper.instance.deleteWithStorage(
          table: 'packages',
          column: 'id',
          value: id,
          bucketName: bucketName,
          imagePath: oldData['image_path'],
        );
      }
    }

    // ২. গ্যালারি ইমেজ পরিবর্তন হলে পুরোনোগুলো ডিলিট করো
    if (newData['gallery_paths'] != null &&
        newData['gallery_paths'] != oldData['gallery_paths']) {
      if (oldData['gallery_paths'] != null) {
        List<String> oldPaths = oldData['gallery_paths'].toString().split(',');
        for (String path in oldPaths) {
          if (path.isNotEmpty) {
            await DatabaseHelper.instance.deleteWithStorage(
              table: 'packages',
              column: 'id',
              value: id,
              bucketName: bucketName,
              imagePath: path,
            );
          }
        }
      }
    }

    // ৩. ফাইনাল ডাটাবেস আপডেট
    await DatabaseHelper.update(
      table: 'packages',
      column: 'id',
      value: id,
      data: newData,
    );
  }
}
