import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package_logic.dart';

void showPackageForm(BuildContext context, {Map<String, dynamic>? item, required VoidCallback onComplete}) {
  final titleCtrl = TextEditingController(text: item?['title'] ?? '');
  final priceCtrl = TextEditingController(text: item?['base_price']?.toString() ?? '');
  final catCtrl = TextEditingController(text: item?['category'] ?? '');
  final featureCtrl = TextEditingController();
  final profileImgCtrl = TextEditingController(text: item?['image_url'] ?? '');

  List<String> features = (item?['features'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? [];
  List<String> galleryList = (item?['gallary_image_url'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? [];

  bool isActive = item?['is_active'] ?? true;
  bool isCustom = item?['is_customization'] ?? false;
  bool isUploading = false;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(builder: (context, setState) => AlertDialog(
      title: Text(item == null ? "Add Package" : "Edit Package"),
      content: SizedBox(width: 600, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
        TextField(controller: catCtrl, decoration: const InputDecoration(labelText: "Category")),
        TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
        const SizedBox(height: 10),

        // Features UI
        Row(children: [Expanded(child: TextField(controller: featureCtrl, decoration: const InputDecoration(labelText: "Add Feature"))),
          IconButton(icon: const Icon(Icons.add), onPressed: () { if(featureCtrl.text.isNotEmpty) setState(() { features.add(featureCtrl.text); featureCtrl.clear(); }); })
        ]),
        ...features.map((f) => ListTile(title: Text(f), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => features.remove(f))))),

        // Image Buttons
        ElevatedButton(onPressed: () async {
          final XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);
          if (img != null) {
            setState(() => isUploading = true);
            String? url = await DatabaseHelper.uploadImageBytes(folder: 'user_assets/package', userId: 'profile_image_${DateTime.now().millisecondsSinceEpoch}', bytes: await img.readAsBytes());
            if (url != null) setState(() { profileImgCtrl.text = url; isUploading = false; });
          }
        }, child: const Text("Select Profile Image")),
        ///image preview of package profile
        const SizedBox(height: 10),
        if (profileImgCtrl.text.isNotEmpty)
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(image: NetworkImage(profileImgCtrl.text), fit: BoxFit.cover),
            ),
          ),
        const SizedBox(height: 10),
       /// image gallery of packages
        Row(children: [const Text("Gallery:"), IconButton(icon: const Icon(Icons.add), onPressed: () async {
          final XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);
          if (img != null) {
            setState(() => isUploading = true);
            String? url = await DatabaseHelper.uploadImageBytes(folder: 'user_assets/package', userId: 'gallery_image_${DateTime.now().millisecondsSinceEpoch}', bytes: await img.readAsBytes());
            if (url != null) setState(() { galleryList.add(url); isUploading = false; });
          }
        })]),
        Wrap(children: galleryList.map((url) => Stack(children: [Image.network(url, width: 60, height: 60), IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setState(() => galleryList.remove(url)))])).toList()),

        SwitchListTile(title: const Text("Is Active"), value: isActive, onChanged: (v) => setState(() => isActive = v)),
        SwitchListTile(title: const Text("Is Customization"), value: isCustom, onChanged: (v) => setState(() => isCustom = v)),
        if (isUploading) const LinearProgressIndicator(),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
        ElevatedButton(onPressed: () async {
          final data = { 'title': titleCtrl.text, 'category': catCtrl.text, 'base_price': int.tryParse(priceCtrl.text) ?? 0, 'features': features.join(','), 'image_url': profileImgCtrl.text, 'gallary_image_url': galleryList.join(','), 'is_active': isActive, 'is_customization': isCustom };
          item == null ? await PackageLogic.add(data) : await PackageLogic.update(item['id'], data);
          onComplete(); Navigator.pop(ctx);
        }, child: const Text("Save"))
      ],
    )),
  );
}