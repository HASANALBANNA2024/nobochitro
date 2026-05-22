import 'package:flutter/material.dart';

import 'package_logic.dart';
import 'show_package_form.dart';

class PackagesListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onUpdate;
  const PackagesListItem({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: item['image_url'] != null && item['image_url'].isNotEmpty
              ? Image.network(
                  item['image_url'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported),
                )
              : const SizedBox(width: 50, height: 50, child: Icon(Icons.image)),
        ),
        title: Text(item['title'] ?? 'No Title'),
        subtitle: Text(
          "Price: ${item['base_price']} | Cat: ${item['category']}",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () =>
                  showPackageForm(context, item: item, onComplete: onUpdate),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                // কনফার্মেশন ডায়ালগ যোগ করা ভালো (নিরাপত্তার জন্য)
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Package"),
                    content: const Text(
                      "Are you sure you want to delete this package and its images?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  // এখানে item পাস করো, কারণ এটাই তোমার ডাটা ম্যাপ
                  await PackageLogic.deletePackage(item);
                  onUpdate();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
