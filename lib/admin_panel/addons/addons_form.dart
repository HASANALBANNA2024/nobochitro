import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

import 'addons_logic.dart';

void showAddonsForm(
  BuildContext context, {
  Map<String, dynamic>? item,
  required VoidCallback onComplete,
}) {
  final titleCtrl = TextEditingController(text: item?['title'] ?? '');
  final priceCtrl = TextEditingController(
    text: item?['price']?.toString() ?? '',
  );
  final catCtrl = TextEditingController(text: item?['category'] ?? '');

  String? imageUrl = item?['image_url'];
  String? imagePath = item?['image_path'];

  /// switch status variable
  bool isActive = item?['is_active'] ?? true;

  final ImagePicker picker = ImagePicker();

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setDialog) => AlertDialog(
        title: Text(item == null ? "Add New Addon" : "Edit Addon"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final XFile? file = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (file != null) {
                    final bytes = await file.readAsBytes();
                    final result = await DatabaseHelper.uploadImageBytes(
                      folder: 'addons',
                      userId: 'admin_${DateTime.now().millisecondsSinceEpoch}',
                      bytes: bytes,
                    );
                    if (result != null) {
                      setDialog(() {
                        imageUrl = result['url'];
                        imagePath = result['path'];
                      });
                    }
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl!)
                      : null,
                  child: imageUrl == null
                      ? const Icon(Icons.add_a_photo)
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: catCtrl,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
              ),

              /// switch list title
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Is Active"),
                value: isActive,
                onChanged: (bool value) {
                  setDialog(() => isActive = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'title': titleCtrl.text,
                'price': int.tryParse(priceCtrl.text) ?? 0,
                'category': catCtrl.text,
                'image_url': imageUrl,
                'image_path': imagePath,
                'is_active': isActive,
              };

              if (item == null) {
                await AddonsLogic.addAddon(data);
              } else {
                await AddonsLogic.updateAddon(item['id'], data);
              }
              onComplete();
              Navigator.pop(ctx);
            },
            child: Text(item == null ? "Save" : "Update"),
          ),
        ],
      ),
    ),
  );
}
