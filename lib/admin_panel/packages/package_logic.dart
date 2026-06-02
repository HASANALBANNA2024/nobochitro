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

  /// package and with picture delete
  static Future<void> deletePackage(Map<String, dynamic> package) async {
    /// Profile image delete
    if (package['image_path'] != null) {
      await DatabaseHelper.deleteWithStorage(
        table: 'packages',
        column: 'id',
        value: package['id'],
        bucketName: 'user_assets',
        imagePath: package['image_path'],
      );
    }

    /// gallery image delete
    if (package['gallery_paths'] != null) {
      List<String> paths = package['gallery_paths'].toString().split(',');
      for (String path in paths) {
        if (path.isNotEmpty) {
          await DatabaseHelper.deleteWithStorage(
            table: 'packages',
            column: 'id',
            value: package['id'],
            bucketName: 'user_assets',
            imagePath: path,
          );
        }
      }
    }

    /// final delete
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

    /// profile image change then old picture delete
    if (newData['image_path'] != null &&
        newData['image_path'] != oldData['image_path']) {
      if (oldData['image_path'] != null) {
        await DatabaseHelper.deleteWithStorage(
          table: 'packages',
          column: 'id',
          value: id,
          bucketName: bucketName,
          imagePath: oldData['image_path'],
        );
      }
    }

    /// if gallery image change and old gallery is delete
    if (newData['gallery_paths'] != null &&
        newData['gallery_paths'] != oldData['gallery_paths']) {
      if (oldData['gallery_paths'] != null) {
        List<String> oldPaths = oldData['gallery_paths'].toString().split(',');
        for (String path in oldPaths) {
          if (path.isNotEmpty) {
            await DatabaseHelper.deleteWithStorage(
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

    /// final database update
    await DatabaseHelper.update(
      table: 'packages',
      column: 'id',
      value: id,
      data: newData,
    );
  }
}
