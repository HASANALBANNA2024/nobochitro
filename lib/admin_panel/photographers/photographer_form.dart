import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

import 'photographer_logic.dart';

Future<void> showPhotographerForm(
  BuildContext context, {
  Map<String, dynamic>? item,
}) async {
  final nameCtrl = TextEditingController(text: item?['name'] ?? '');
  final specCtrl = TextEditingController(text: item?['specialty'] ?? '');

  String? profilePath = item?['profile_image_path'];
  String? bannerPath = item?['banner_image_path'];
  List<String> gallery = List<String>.from(
    item?['recent_image_gallary_path'] ?? [],
  );

  // ডাটাবেস থেকে প্রাপ্ত ID বা নতুন ID
  final String currentId =
      item?['photographer_id'] ?? PhotographerLogic.generatePhotographerId();

  return showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialog) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: specCtrl,
                  decoration: const InputDecoration(labelText: "Specialty"),
                ),
                const SizedBox(height: 15),

                // ইমেজ বাটনসমূহ
                Wrap(
                  spacing: 10,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final file = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (file != null) {
                          final res = await DatabaseHelper.uploadImageBytes(
                            folder: 'photographers/profile/$currentId',
                            userId: 'profile',
                            bytes: await file.readAsBytes(),
                          );
                          profilePath = res?['path'];
                          setDialog(() {});
                        }
                      },
                      child: const Text("Profile"),
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        final file = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (file != null) {
                          final res = await DatabaseHelper.uploadImageBytes(
                            folder: 'photographers/profile/$currentId',
                            userId: 'banner',
                            bytes: await file.readAsBytes(),
                          );
                          bannerPath = res?['path'];
                          setDialog(() {});
                        }
                      },
                      child: const Text("Banner"),
                    ),
                  ],
                ),

                ElevatedButton(
                  onPressed: () async {
                    final files = await ImagePicker().pickMultiImage();
                    for (var f in files) {
                      final res = await DatabaseHelper.uploadImageBytes(
                        folder: 'photographers/profile/$currentId',
                        userId: 'gal_${DateTime.now().millisecondsSinceEpoch}',
                        bytes: await f.readAsBytes(),
                      );
                      if (res?['path'] != null) gallery.add(res!['path']!);
                    }
                    setDialog(() {});
                  },
                  child: const Text("Add Gallery Images"),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final data = {
                      'name': nameCtrl.text,
                      'specialty': specCtrl.text,
                      'profile_image_path': profilePath,
                      'banner_image_path': bannerPath,
                      'recent_image_gallary_path': gallery,
                      'photographer_id': currentId, // নতুন আইডি সেভ হচ্ছে
                    };

                    if (item == null) {
                      await PhotographerLogic.addPhotographer(data);
                    } else {
                      await PhotographerLogic.updatePhotographerFull(
                        id: item['id'],
                        data: data,
                        oldProfile: item['profile_image_path'],
                        oldBanner: item['banner_image_path'],
                        oldGallery: List<String>.from(
                          item['recent_image_gallary_path'] ?? [],
                        ),
                      );
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text("Save Data"),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
