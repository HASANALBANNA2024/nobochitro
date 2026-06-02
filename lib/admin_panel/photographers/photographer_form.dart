import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

import 'photographer_logic.dart';

Future<void> showPhotographerForm(
  BuildContext context, {
  Map<String, dynamic>? item,
}) async {
  /// all field controller
  final nameCtrl = TextEditingController(text: item?['name'] ?? '');
  final specCtrl = TextEditingController(text: item?['specialty'] ?? '');
  final bioCtrl = TextEditingController(text: item?['bio'] ?? '');
  final locCtrl = TextEditingController(text: item?['location'] ?? '');
  final feeCtrl = TextEditingController(
    text: item?['per_hours_fee']?.toString() ?? '',
  );
  final expCtrl = TextEditingController(
    text: item?['experience_years']?.toString() ?? '',
  );
  final techCtrl = TextEditingController(
    text: item?['technical_arsenal'] ?? '',
  );

  String? profilePath = item?['profile_image_path'];
  String? bannerPath = item?['banner_image_path'];

  ///gallery image
  List<String> gallery = [];
  var rawGallery = item?['recent_image_gallary_path'];
  if (rawGallery is String) {
    try {
      gallery = List<String>.from(jsonDecode(rawGallery));
    } catch (e) {
      gallery = [];
    }
  } else if (rawGallery is List) {
    gallery = List<String>.from(rawGallery);
  }

  bool isAvailable = item?['is_available'] ?? true;
  bool isActive = item?['is_active'] ?? true;
  final currentId =
      item?['photographer_id'] ?? PhotographerLogic.generatePhotographerId();

  return showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialog) => AlertDialog(
        title: Text(item == null ? "Add Photographer" : "Edit Photographer"),
        content: SizedBox(
          width: MediaQuery.of(ctx).size.width > 600 ? 500 : double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: specCtrl,
                  decoration: const InputDecoration(labelText: "Specialty"),
                ),
                TextField(
                  controller: techCtrl,
                  decoration: const InputDecoration(
                    labelText: "Technical Arsenal",
                  ),
                ),
                TextField(
                  controller: bioCtrl,
                  decoration: const InputDecoration(labelText: "Bio"),
                  maxLines: 2,
                ),
                TextField(
                  controller: locCtrl,
                  decoration: const InputDecoration(labelText: "Location"),
                ),
                TextField(
                  controller: feeCtrl,
                  decoration: const InputDecoration(labelText: "Fee/Hour"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: expCtrl,
                  decoration: const InputDecoration(
                    labelText: "Experience (Years)",
                  ),
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  title: const Text("Is Available"),
                  value: isAvailable,
                  onChanged: (v) => setDialog(() => isAvailable = v),
                ),
                SwitchListTile(
                  title: const Text("Is Active"),
                  value: isActive,
                  onChanged: (v) => setDialog(() => isActive = v),
                ),

                /// profile image
                const Divider(),
                ListTile(
                  title: const Text("Profile Image"),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final file = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (file == null) return;
                      final res = await DatabaseHelper.uploadImageBytes(
                        folder: 'photographers/$currentId',
                        userId: 'prof',
                        bytes: await file.readAsBytes(),
                      );
                      setDialog(() => profilePath = res?['path']);
                    },
                    child: const Text("Upload"),
                  ),
                ),
                if (profilePath != null)
                  Image.network(
                    DatabaseHelper.client.storage
                        .from('user_assets')
                        .getPublicUrl(profilePath!),
                    height: 80,
                  ),

                /// banner image
                ListTile(
                  title: const Text("Banner Image"),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final file = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (file == null) return;
                      final res = await DatabaseHelper.uploadImageBytes(
                        folder: 'photographers/$currentId',
                        userId: 'banner',
                        bytes: await file.readAsBytes(),
                      );
                      setDialog(() => bannerPath = res?['path']);
                    },
                    child: const Text("Upload"),
                  ),
                ),
                if (bannerPath != null)
                  Image.network(
                    DatabaseHelper.client.storage
                        .from('user_assets')
                        .getPublicUrl(bannerPath!),
                    height: 80,
                  ),

                /// Gallery image
                const ListTile(title: Text("Gallery Images")),
                Wrap(
                  spacing: 10,
                  children: gallery
                      .map(
                        (path) => Stack(
                          children: [
                            if (path.isNotEmpty)
                              Image.network(
                                DatabaseHelper.client.storage
                                    .from('user_assets')
                                    .getPublicUrl(path),
                                width: 60,
                                height: 60,
                              ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  setDialog(() => gallery.remove(path)),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final files = await ImagePicker().pickMultiImage();
                    for (var f in files) {
                      final res = await DatabaseHelper.uploadImageBytes(
                        folder: 'photographers/$currentId',
                        userId: 'gal_${DateTime.now().millisecondsSinceEpoch}',
                        bytes: await f.readAsBytes(),
                      );
                      if (res != null)
                        setDialog(() => gallery.add(res['path']!));
                    }
                  },
                  child: const Text("Add Gallery Images"),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final data = {
                      'name': nameCtrl.text,
                      'specialty': specCtrl.text,
                      'bio': bioCtrl.text,
                      'location': locCtrl.text,
                      'per_hours_fee': int.tryParse(feeCtrl.text) ?? 0,
                      'experience_years': int.tryParse(expCtrl.text) ?? 0,
                      'technical_arsenal': techCtrl.text,
                      'is_available': isAvailable,
                      'is_active': isActive,
                      'profile_image_path': profilePath,
                      'banner_image_path': bannerPath,
                      'recent_image_gallary_path': gallery,
                      'photographer_id': currentId,
                    };

                    if (item == null) {
                      await PhotographerLogic.addPhotographer(data);
                    } else {
                      var rawOldGallery = item!['recent_image_gallary_path'];
                      List<String> oldGalleryList = [];

                      if (rawOldGallery is String) {
                        try {
                          oldGalleryList = List<String>.from(
                            jsonDecode(rawOldGallery),
                          );
                        } catch (e) {
                          oldGalleryList = [];
                        }
                      } else if (rawOldGallery is List) {
                        oldGalleryList = List<String>.from(rawOldGallery);
                      }

                      await PhotographerLogic.updatePhotographerFull(
                        id: item!['id'],
                        data: data,
                        oldProfile: item!['profile_image_path'],
                        oldBanner: item!['banner_image_path'],
                        oldGallery: oldGalleryList,
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
