import 'package:flutter/material.dart';
import 'package_logic.dart';
import 'show_package_form.dart';

class PackagesListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onUpdate;
  const PackagesListItem({super.key, required this.item, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        // প্যাকেজের প্রোফাইল ইমেজ এখানে যুক্ত করা হয়েছে
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: item['image_url'] != null && item['image_url'].isNotEmpty
              ? Image.network(
            item['image_url'],
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
          )
              : const SizedBox(width: 50, height: 50, child: Icon(Icons.image)),
        ),
        title: Text(item['title'] ?? 'No Title'),
        subtitle: Text("Price: ${item['base_price']} | Cat: ${item['category']}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => showPackageForm(context, item: item, onComplete: onUpdate),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await PackageLogic.delete(item['id']);
                onUpdate();
              },
            ),
          ],
        ),
      ),
    );
  }
}