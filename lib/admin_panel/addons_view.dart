import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class AddonsView extends StatefulWidget {
  const AddonsView({super.key});

  @override
  State<AddonsView> createState() => _AddonsViewState();
}

class _AddonsViewState extends State<AddonsView> {
  final ImagePicker _picker = ImagePicker();

  /// Delete Operation
  Future<void> _delete(dynamic id) async {
    await DatabaseHelper.delete(table: 'addons', column: 'addon_id', value: id);
    setState(() {});
  }

  /// add or delete
  void _showForm({Map<String, dynamic>? item}) async {
    final titleCtrl = TextEditingController(text: item?['title'] ?? '');
    final priceCtrl = TextEditingController(
      text: item?['price']?.toString() ?? '',
    );
    final catCtrl = TextEditingController(text: item?['category'] ?? '');
    String? imageUrl = item?['iamge_url'];

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
                    final XFile? file = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (file != null) {
                      final bytes = await file.readAsBytes();
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
                    backgroundImage: imageUrl != null
                        ? NetworkImage(imageUrl!)
                        : null,
                    child: imageUrl == null
                        ? const Icon(Icons.add_a_photo)
                        : null,
                  ),
                ),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: catCtrl,
                  decoration: const InputDecoration(labelText: "Category"),
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
                  'is_active': true,
                };

                if (item == null) {
                  await DatabaseHelper.insert(table: 'addons', data: data);
                } else {
                  await DatabaseHelper.update(
                    table: 'addons',
                    column: 'addon_id',
                    value: item['addon_id'],
                    data: data,
                  );
                }
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // এখানে Center এবং ConstrainedBox ব্যবহার করা হয়েছে ওয়েব রেসপন্সিভনেসের জন্য
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseHelper.instance.getAddons(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data ?? [];
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, i) => Card(
                  child: ListTile(
                    leading: items[i]['image_url'] != null
                        ? Image.network(
                            items[i]['image_url'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image),
                    title: Text(items[i]['title']),
                    subtitle: Text(
                      "Price: ${items[i]['price']} | Cat: ${items[i]['category']}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showForm(item: items[i]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _delete(items[i]['addon_id']),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
