import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

import 'package_logic.dart';

void showPackageForm(
  BuildContext context, {
  Map<String, dynamic>? item,
  required VoidCallback onComplete,
}) {
  final titleCtrl = TextEditingController(text: item?['title'] ?? '');
  final priceCtrl = TextEditingController(
    text: item?['base_price']?.toString() ?? '',
  );
  final catCtrl = TextEditingController(text: item?['category'] ?? '');
  final featureCtrl = TextEditingController();
  final hoursCtrl = TextEditingController();

  /// url and path check state
  String profileUrl = item?['image_url'] ?? '';
  String profilePath = item?['image_path'] ?? '';
  List<String> galleryUrls =
      (item?['gallary_image_url'] as String?)
          ?.split(',')
          .where((e) => e.isNotEmpty)
          .toList() ??
      [];
  List<String> galleryPaths =
      (item?['gallery_paths'] as String?)
          ?.split(',')
          .where((e) => e.isNotEmpty)
          .toList() ??
      [];

  List<String> features =
      (item?['features'] as String?)
          ?.split(',')
          .where((e) => e.isNotEmpty)
          .toList() ??
      [];
  List<String> hoursList =
      (item?['base_hours']
          ?.toString()
          .split(',')
          .where((e) => e.isNotEmpty)
          .toList() ??
      []);

  bool isActive = item?['is_active'] ?? true;
  bool isCustom = item?['is_customization'] ?? false;
  bool isUploading = false;

  String generatePackageId(String category) {
    String catShort = category.length >= 3
        ? category.substring(0, 3).toUpperCase()
        : category.padRight(3, 'X').toUpperCase();
    String randomDigits = (DateTime.now().millisecondsSinceEpoch % 1000)
        .toString()
        .padLeft(3, '0');
    return 'PKG-$catShort-$randomDigits';
  }

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(item == null ? "Add Package" : "Edit Package"),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: catCtrl,
                  decoration: const InputDecoration(labelText: "Category"),
                ),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: featureCtrl,
                        decoration: const InputDecoration(
                          labelText: "Add Feature",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (featureCtrl.text.isNotEmpty) {
                          setState(() {
                            features.add(featureCtrl.text);
                            featureCtrl.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                ...features.map(
                  (f) => ListTile(
                    title: Text(f),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => features.remove(f)),
                    ),
                  ),
                ),

                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: hoursCtrl,
                        decoration: const InputDecoration(
                          labelText: "Add Hours (e.g. 2)",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (hoursCtrl.text.isNotEmpty) {
                          setState(() {
                            hoursList.add(hoursCtrl.text);
                            hoursCtrl.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: hoursList
                      .map(
                        (h) => Chip(
                          label: Text("$h Hours"),
                          onDeleted: () => setState(() => hoursList.remove(h)),
                        ),
                      )
                      .toList(),
                ),
                const Divider(),

                ElevatedButton(
                  onPressed: () async {
                    final XFile? img = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (img != null) {
                      setState(() => isUploading = true);
                      final res = await DatabaseHelper.uploadImageBytes(
                        folder: 'user_assets/package',
                        userId: 'p_${DateTime.now().millisecondsSinceEpoch}',
                        bytes: await img.readAsBytes(),
                      );
                      if (res != null) {
                        setState(() {
                          profileUrl = res['url']!;
                          profilePath = res['path']!;
                          isUploading = false;
                        });
                      }
                    }
                  },
                  child: const Text("Select Profile Image"),
                ),
                if (profileUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(profileUrl, width: 80, height: 80),
                  ),

                Row(
                  children: [
                    const Text("Gallery:"),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final XFile? img = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (img != null) {
                          setState(() => isUploading = true);
                          final res = await DatabaseHelper.uploadImageBytes(
                            folder: 'user_assets/package',
                            userId:
                                'g_${DateTime.now().millisecondsSinceEpoch}',
                            bytes: await img.readAsBytes(),
                          );
                          if (res != null) {
                            setState(() {
                              galleryUrls.add(res['url']!);
                              galleryPaths.add(res['path']!);
                              isUploading = false;
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),
                Wrap(
                  children: galleryUrls
                      .asMap()
                      .entries
                      .map(
                        (e) => Stack(
                          children: [
                            Image.network(e.value, width: 60, height: 60),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => setState(() {
                                galleryUrls.removeAt(e.key);
                                galleryPaths.removeAt(e.key);
                              }),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),

                SwitchListTile(
                  title: const Text("Is Active"),
                  value: isActive,
                  onChanged: (v) => setState(() => isActive = v),
                ),
                SwitchListTile(
                  title: const Text("Is Customization"),
                  value: isCustom,
                  onChanged: (v) => setState(() => isCustom = v),
                ),
              ],
            ),
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
                'package_id': item == null
                    ? generatePackageId(catCtrl.text)
                    : item['package_id'],
                'title': titleCtrl.text,
                'category': catCtrl.text,
                'base_price': int.tryParse(priceCtrl.text) ?? 0,
                'features': features.join(','),
                'base_hours': hoursList.join(','),
                'image_url': profileUrl,
                'image_path': profilePath,
                'gallary_image_url': galleryUrls.join(','),
                'gallary_paths': galleryPaths.join(','),
                'is_active': isActive,
                'is_customization': isCustom,
              };
              item == null
                  ? await PackageLogic.add(data)
                  : await PackageLogic.update(item['id'], data);
              onComplete();
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    ),
  );
}
