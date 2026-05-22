import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

import 'campaigns_logic.dart';
import 'date_picker_helper.dart';
import 'dropdown_data_logic.dart';

void showCampaignForm(
  BuildContext context, {
  Map<String, dynamic>? item,
  required VoidCallback onComplete,
}) {
  final titleCtrl = TextEditingController(text: item?['title'] ?? '');
  final bannerCtrl = TextEditingController(text: item?['banner_url'] ?? '');
  final discountCtrl = TextEditingController(
    text: item?['discount_pct']?.toString() ?? '',
  );
  final categoryCtrl = TextEditingController(
    text: item?['targeted_category'] ?? '',
  );
  final packageCtrl = TextEditingController(
    text: item?['targeted_package_id'] ?? '',
  );
  final startDateCtrl = TextEditingController(text: item?['start_date'] ?? '');
  final endDateCtrl = TextEditingController(text: item?['end_date'] ?? '');

  /// path variable
  String bannerPath = item?['image_path'] ?? '';

  bool isActive = item?['is_active'] ?? true;
  bool isUploading = false;
  final ImagePicker picker = ImagePicker();

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => FutureBuilder(
        future: Future.wait([
          DropdownDataLogic.getUniqueCategories(),
          DropdownDataLogic.getUniquePackageTitles(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const AlertDialog(
              content: SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          final List<String> categories = snapshot.data![0];
          final List<String> packages = snapshot.data![1];

          return AlertDialog(
            title: const Text(
              "Campaign Form",
              style: TextStyle(color: Colors.black),
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: bannerCtrl,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              labelText: "Banner URL",
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        IconButton(
                          icon: const Icon(Icons.image, color: Colors.black),
                          onPressed: () async {
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              setState(() => isUploading = true);
                              try {
                                final bytes = await image.readAsBytes();

                                // ফাংশন কল করা হচ্ছে
                                final result =
                                    await DatabaseHelper.uploadImageBytes(
                                      folder: 'campaigns',
                                      userId:
                                          'admin_${DateTime.now().millisecondsSinceEpoch}',
                                      bytes: bytes,
                                    );

                                // 🟢 ম্যাপ থেকে ডাটা নেওয়া হচ্ছে
                                if (result != null) {
                                  setState(() {
                                    bannerCtrl.text =
                                        result['url']!; // URL টি সেট হলো
                                    bannerPath =
                                        result['path']!; // পাথটি এখানে সেট হলো
                                  });
                                }
                              } catch (e) {
                                debugPrint("Error: $e");
                              } finally {
                                setState(() => isUploading = false);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: discountCtrl,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: "Discount %",
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: categories.contains(categoryCtrl.text)
                          ? categoryCtrl.text
                          : null,
                      decoration: const InputDecoration(
                        labelText: "Targeted Categories",
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      items: categories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => categoryCtrl.text = val!),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: packages.contains(packageCtrl.text)
                          ? packageCtrl.text
                          : null,
                      decoration: const InputDecoration(
                        labelText: "Targeted Package",
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      items: packages
                          .map(
                            (pkg) =>
                                DropdownMenuItem(value: pkg, child: Text(pkg)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => packageCtrl.text = val!),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: startDateCtrl,
                      style: const TextStyle(color: Colors.black),
                      readOnly: true,
                      onTap: () =>
                          DatePickerHelper.pickDate(context, startDateCtrl),
                      decoration: const InputDecoration(
                        labelText: "Start Date (YYYY-MM-DD)",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: endDateCtrl,
                      style: const TextStyle(color: Colors.black),
                      readOnly: true,
                      onTap: () =>
                          DatePickerHelper.pickDate(context, endDateCtrl),
                      decoration: const InputDecoration(
                        labelText: "End Date (YYYY-MM-DD)",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text(
                        "Is Active",
                        style: TextStyle(color: Colors.black),
                      ),
                      value: isActive,
                      onChanged: (val) => setState(() => isActive = val),
                    ),
                    if (isUploading) const LinearProgressIndicator(),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isUploading
                    ? null
                    : () async {
                        String generateId() {
                          String randomDigits = DateTime.now()
                              .millisecondsSinceEpoch
                              .toString();
                          return 'NSRB${randomDigits.substring(randomDigits.length - 4)}';
                        }

                        final data = {
                          'campaign_id': item == null
                              ? generateId()
                              : item['campaign_id'],
                          'title': titleCtrl.text,
                          'banner_url': bannerCtrl.text,
                          'image_path': bannerPath,
                          'discount_pct': int.tryParse(discountCtrl.text) ?? 0,
                          'targeted_category': categoryCtrl.text,
                          'targeted_package_id': packageCtrl.text.isEmpty
                              ? null
                              : packageCtrl.text,
                          'start_date': startDateCtrl.text,
                          'end_date': endDateCtrl.text,
                          'is_active': isActive,
                        };
                        item == null
                            ? await CampaignsLogic.add(data)
                            : await CampaignsLogic.update(item['id'], data);
                        onComplete();
                        Navigator.pop(ctx);
                      },
                child: Text(item == null ? "Add" : "Update"),
              ),
            ],
          );
        },
      ),
    ),
  );
}
