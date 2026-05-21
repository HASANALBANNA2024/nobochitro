import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'addons_form.dart';
import 'addons_list_item.dart';

class AddonsView extends StatefulWidget {
  const AddonsView({super.key});

  @override
  State<AddonsView> createState() => _AddonsViewState();
}

class _AddonsViewState extends State<AddonsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            key: UniqueKey(),
            future: DatabaseHelper.instance.getAddons(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final items = snapshot.data!;
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) => AddonsListItem(item: items[i], onUpdate: () => setState(() {})),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddonsForm(context, onComplete: () => setState(() {})),
        child: const Icon(Icons.add),
      ),
    );
  }
}