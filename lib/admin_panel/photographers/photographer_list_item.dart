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
    return Card(
      child: ListTile(
        title: Text(item['name'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
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
      ),
    );
  }
}
