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

  // নতুন: পাথ ট্র্যাক করার জন্য ভেরিয়েবল
  String? imageUrl = item?['image_url'];
  String? imagePath = item?['image_path'];

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

                    // DatabaseHelper থেকে এখন ম্যাপ রেজাল্ট পাবো
                    final result = await DatabaseHelper.uploadImageBytes(
                      folder: 'addons',
                      userId: 'admin_${DateTime.now().millisecondsSinceEpoch}',
                      bytes: bytes,
                    );

                    if (result != null) {
                      setDialog(() {
                        imageUrl = result['url'];
                        imagePath = result['path']; // 🟢 পাথটি সেভ হলো
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
              // ... টেক্সট ফিল্ডগুলো আগের মতোই থাকবে ...
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
                'image_path': imagePath, // 🟢 ডাটাবেসে পাথ পাঠানো হচ্ছে
                'is_active': true,
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
