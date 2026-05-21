import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'addons_logic.dart';

void showAddonsForm(BuildContext context, {Map<String, dynamic>? item, required VoidCallback onComplete}) {
  final titleCtrl = TextEditingController(text: item?['title'] ?? '');
  final priceCtrl = TextEditingController(text: item?['price']?.toString() ?? '');
  final catCtrl = TextEditingController(text: item?['category'] ?? '');
  String? imageUrl = item?['image_url'];
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
              // ইমেজ আপলোড সেকশন
              GestureDetector(
                onTap: () async {
                  final XFile? file = await picker.pickImage(source: ImageSource.gallery);
                  if (file != null) {
                    final bytes = await file.readAsBytes();
                    // ইমেজ আপলোড করা
                    final url = await DatabaseHelper.uploadImageBytes(
                      folder: 'addons',
                      userId: 'admin',
                      bytes: bytes,
                    );
                    setDialog(() => imageUrl = url);
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                  child: imageUrl == null ? const Icon(Icons.add_a_photo) : null,
                ),
              ),
              const SizedBox(height: 10),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: "Category")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'title': titleCtrl.text,
                'price': int.tryParse(priceCtrl.text) ?? 0,
                'category': catCtrl.text,
                'image_url': imageUrl, // ডাটাবেসের সঠিক কলাম নাম
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