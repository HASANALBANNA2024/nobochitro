import 'package:flutter/material.dart';
import 'addons_logic.dart';
import 'addons_form.dart';

class AddonsListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onUpdate;

  const AddonsListItem({super.key, required this.item, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // ইমেজ সেকশন
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: item['image_url'] != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(item['image_url'], fit: BoxFit.cover),
          )
              : const Icon(Icons.image, color: Colors.grey),
        ),
        // টাইটেল এবং সাব-টাইটেল (Price & Category)
        title: Text(item['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Price: ${item['price']}৳ | Cat: ${item['category'] ?? 'N/A'}"),

        // বাটন সেকশন
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => showAddonsForm(context, item: item, onComplete: onUpdate),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await AddonsLogic.deleteAddon(item['id']);
                onUpdate();
              },
            ),
          ],
        ),
      ),
    );
  }
}