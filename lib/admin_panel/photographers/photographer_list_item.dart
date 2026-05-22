import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'photographer_form.dart';
import 'photographer_logic.dart';

class PhotographerListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onUpdate;

  const PhotographerListItem({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  String getStorageUrl(String path) {
    if (path.isEmpty) return '';
    return DatabaseHelper.client.storage.from('user_assets').getPublicUrl(path);
  }

  @override
  Widget build(BuildContext context) {
    // ডাটাবেস থেকে পাওয়া গ্যালারি পাথ হ্যান্ডেল করা
    List<dynamic> gallery = [];
    var rawGallery = item['recent_image_gallary_path'];

    if (rawGallery is String) {
      try {
        gallery = jsonDecode(rawGallery); // স্ট্রিং থেকে লিস্টে কনভার্ট
      } catch (e) {
        gallery = [];
      }
    } else if (rawGallery is List) {
      gallery = rawGallery;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: item['profile_image_path'] != null && item['profile_image_path'].isNotEmpty
              ? NetworkImage(getStorageUrl(item['profile_image_path']))
              : null,
          child: (item['profile_image_path'] == null || item['profile_image_path'].isEmpty)
              ? const Icon(Icons.person) : null,
        ),
        title: Text(item['name'] ?? 'No Name'),
        subtitle: Text(item['specialty'] ?? 'N/A'),
        children: [
          // ব্যানার ইমেজ
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: (item['banner_image_path'] != null && item['banner_image_path'].isNotEmpty)
                ? Image.network(
              getStorageUrl(item['banner_image_path']),
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(height: 100, child: Center(child: Icon(Icons.broken_image))),
            )
                : const SizedBox(height: 50, child: Center(child: Text("No Banner"))),
          ),

          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Recent Work Gallery:", style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          // গ্যালারি গ্রিড
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemCount: gallery.length,
            itemBuilder: (ctx, i) => Image.network(
              getStorageUrl(gallery[i].toString()),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.error),
            ),
          ),

          // এডিট ও ডিলিট বাটন
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => showPhotographerForm(context, item: item),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Confirm Delete"),
                        content: const Text("Are you sure you want to delete this photographer?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
                        ],
                      )
                  );
                  if (confirm == true) {
                    await PhotographerLogic.deletePhotographer(item);
                    onUpdate();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}