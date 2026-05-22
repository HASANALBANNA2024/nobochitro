import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    List<dynamic> gallery = item['recent_work_urls'] ?? [];

    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(item['profile_image_path'] ?? ''),
        ),
        title: Text(item['name'] ?? ''),
        subtitle: Text(item['specialty'] ?? ''),
        children: [
          Image.network(item['banner_image_path'] ?? ''),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Recent Work Gallery:"),
          ),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: gallery.length,
            itemBuilder: (ctx, i) => Image.network(gallery[i]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => showPhotographerForm(context, item: item),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await PhotographerLogic.deletePhotographer(item);
                  onUpdate();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
