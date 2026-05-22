import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

import 'photographer_form.dart';
import 'photographer_list_item.dart';

class PhotographerView extends StatefulWidget {
  const PhotographerView({super.key});
  @override
  State<PhotographerView> createState() => _PhotographerViewState();
}

class _PhotographerViewState extends State<PhotographerView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseHelper.instance.getData(table: 'photographers'),
            builder: (ctx, snap) {
              if (!snap.hasData) return const CircularProgressIndicator();
              return ListView.builder(
                itemCount: snap.data!.length,
                itemBuilder: (ctx, i) => PhotographerListItem(
                  item: snap.data![i],
                  onUpdate: () => setState(() {}),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showPhotographerForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
