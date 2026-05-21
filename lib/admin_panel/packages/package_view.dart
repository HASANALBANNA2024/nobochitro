import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package_list_item.dar.dart';
import 'show_package_form.dart';

class PackagesView extends StatefulWidget {
  const PackagesView({super.key});
  @override
  State<PackagesView> createState() => _PackagesViewState();
}

class _PackagesViewState extends State<PackagesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            key: UniqueKey(), // ডাটা রিফ্রেশ করার জন্য
            future: DatabaseHelper.instance.getData(table: 'packages'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("কোনো প্যাকেজ পাওয়া যায়নি!"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, i) => PackagesListItem(
                  item: snapshot.data![i],
                  onUpdate: () => setState(() {}),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showPackageForm(context, onComplete: () => setState(() {})),
        child: const Icon(Icons.add),
      ),
    );
  }
}