import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:nobochitro/admin_panel/photographers/photographer_form.dart';

import 'photographer_list_item.dart';

class PhotographerView extends StatefulWidget {
  const PhotographerView({super.key});

  @override
  State<PhotographerView> createState() => _PhotographerViewState();
}

class _PhotographerViewState extends State<PhotographerView> {
  // ডাটা রিফ্রেশ করার জন্য একটি ফাংশন
  void _refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Photographers"),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            // ডাটাবেস থেকে ডাটা আনা
            future: DatabaseHelper.instance.getData(table: 'photographers'),
            builder: (ctx, snap) {
              // লোডিং স্টেট
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // এরর হ্যান্ডলিং
              if (snap.hasError) {
                return Center(child: Text("Error: ${snap.error}"));
              }

              // ডাটা না থাকলে
              if (!snap.hasData || snap.data!.isEmpty) {
                return const Center(
                  child: Text("No photographers found. Add one!"),
                );
              }

              // লিস্ট ভিউ
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: snap.data!.length,
                itemBuilder: (ctx, i) => PhotographerListItem(
                  item: snap.data![i],
                  onUpdate:
                      _refreshData, // ডিলিট বা এডিটের পর ইউআই রিফ্রেশ করবে
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // নতুন ফটোগ্রাফার যোগ করার পর লিস্ট আপডেট হবে
          await showPhotographerForm(context);
          _refreshData();
        },
        label: const Text("Add New"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
