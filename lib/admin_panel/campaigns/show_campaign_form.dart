import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // image_picker ইমপোর্ট
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'campaigns_logic.dart';

void showCampaignForm(BuildContext context, {Map<String, dynamic>? item, required VoidCallback onComplete}) {
  final titleCtrl = TextEditingController(text: item?['title'] ?? '');
  final bannerCtrl = TextEditingController(text: item?['banner_url'] ?? '');
  final discountCtrl = TextEditingController(text: item?['discount_pct']?.toString() ?? '');
  final categoryCtrl = TextEditingController(text: item?['targeted_category'] ?? '');
  final packageCtrl = TextEditingController(text: item?['targeted_package_id'] ?? '');
  final startDateCtrl = TextEditingController(text: item?['start_date'] ?? '');
  final endDateCtrl = TextEditingController(text: item?['end_date'] ?? '');

  bool isActive = item?['is_active'] ?? true;
  bool isUploading = false;
  final ImagePicker picker = ImagePicker(); // ImagePicker ইনস্ট্যান্স

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(item == null ? "Add Campaign" : "Edit Campaign"),
        content: SizedBox(
          width: 500, // উইডথ কিছুটা বাড়িয়ে দিলাম
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // প্রতিটি টেক্সট ফিল্ডের জন্য SizedBox দিয়ে গ্যাপ তৈরি করছি যাতে কন্টেন্ট দেখা যায়
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder())),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(child: TextField(controller: bannerCtrl, decoration: const InputDecoration(labelText: "Banner URL", border: OutlineInputBorder()))),
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: () async {
                        // ইমেজ পিকার লজিক...
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),

                TextField(controller: discountCtrl, decoration: const InputDecoration(labelText: "Discount %", border: OutlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: "Targeted Categories", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: packageCtrl, decoration: const InputDecoration(labelText: "Targeted Package ID", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: startDateCtrl, decoration: const InputDecoration(labelText: "Start Date (YYYY-MM-DD)", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: endDateCtrl, decoration: const InputDecoration(labelText: "End Date (YYYY-MM-DD)", border: OutlineInputBorder())),

                SwitchListTile(
                  title: const Text("Is Active"),
                  value: isActive,
                  onChanged: (val) => setState(() => isActive = val),
                ),
                if (isUploading) const LinearProgressIndicator(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
              onPressed: isUploading ? null : () async {
                final data = {
                  'title': titleCtrl.text,
                  'banner_url': bannerCtrl.text,
                  'discount_pct': int.tryParse(discountCtrl.text) ?? 0,
                  'targeted_category': categoryCtrl.text,
                  'targeted_package_id': packageCtrl.text.isEmpty ? null : packageCtrl.text,
                  'start_date': startDateCtrl.text,
                  'end_date': endDateCtrl.text,
                  'is_active': isActive,
                };
                item == null ? await CampaignsLogic.add(data) : await CampaignsLogic.update(item['id'], data);
                onComplete();
                Navigator.pop(ctx);
              },
              child: Text(item == null ? "Add" : "Update")
          ),
        ],
      ),
    ),
  );
}