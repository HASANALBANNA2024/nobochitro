import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

import 'photographer_logic.dart';

void showPhotographerForm(BuildContext context, {Map<String, dynamic>? item}) {
  final nameCtrl = TextEditingController(text: item?['name'] ?? '');
  String? profilePath = item?['profile_image_path'];

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item == null ? "Add Photographer" : "Edit Photographer",
                style: const TextStyle(fontSize: 20),
              ),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: Text(
                  profilePath == null ? "Upload Profile Image" : "Change Image",
                ),
                onPressed: () async {
                  final file = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (file != null) {
                    final bytes = await file.readAsBytes();
                    final photographerId =
                        item?['photographer_id'] ??
                        'temp_${DateTime.now().millisecondsSinceEpoch}';
                    final res = await DatabaseHelper.uploadImageBytes(
                      folder: 'photographers/profile/$photographerId',
                      userId: 'profile',
                      bytes: bytes,
                    );
                    profilePath = res?['path'];
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final data = {
                    'name': nameCtrl.text,
                    'profile_image_path': profilePath,
                  };
                  if (item == null) {
                    await PhotographerLogic.addPhotographer(data);
                  } else {
                    await PhotographerLogic.updatePhotographerWithImage(
                      id: item['id'],
                      data: data,
                      oldProfilePath: item['profile_image_path'],
                    );
                  }
                  Navigator.pop(ctx);
                },
                child: Text(item == null ? "Save" : "Update"),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
