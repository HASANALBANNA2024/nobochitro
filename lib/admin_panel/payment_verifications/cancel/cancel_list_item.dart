import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'cancel_controller.dart';

class CancelListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onUpdate;
  final CancelController _controller = CancelController();

  CancelListItem({super.key, required this.item, required this.onUpdate});

  /// data filed builder
  List<Widget> _buildDataList() {
    List<Widget> widgets = [];
    item.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty &&
          !['booking_id', 'booking_status', 'refund_status', 'refund_transaction', 'refund_transaction_image', 'transaction_image_url', 'booking_amount', 'refund_amount', 'user_id'].contains(key)) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Expanded(flex: 2, child: Text(key.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
            Expanded(flex: 3, child: Text(": $value", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          ]),
        ));
      }
    });
    return widgets;
  }
  /// refunded dialogue box
  void _showRefundDialog(BuildContext context, String status) {
    TextEditingController transCtrl = TextEditingController(text: item['refund_transaction'] ?? "");
    Uint8List? webImage; // Web এর জন্য বাইট লিস্ট

    showDialog(
      context: context,
      // ডায়ালগের বাইরের অংশে ক্লিক করলে যেন বন্ধ না হয় (ইমেজ পিক করার সময় যেন সমস্যা না হয়)
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Confirm: ${status.toUpperCase()}"),
            // ডায়ালগ যেন পুরো স্ক্রিন না নিয়ে নেয়
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            // --- কন্টেন্ট অংশ (সবচেয়ে গুরুত্বপূর্ণ পরিবর্তন) ---
            content: Container(
              // কন্টেন্টের একটা নির্দিষ্ট প্রস্থ দিন
              width: 400,
              // SingleChildScrollView ব্যবহার করছি যাতে কন্টেন্ট বেশি হলে স্ক্রল করা যায়
              child: SingleChildScrollView(
                child: Column(
                  // কন্টেন্ট অনুযায়ী প্রস্থ সেট হবে
                  mainAxisSize: MainAxisSize.min,
                  // বাম দিক থেকে অ্যালাইন
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                        controller: transCtrl,
                        decoration: const InputDecoration(labelText: "Transaction ID")
                    ),
                    const SizedBox(height: 15),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Pick Receipt Image"),
                      onPressed: () async {
                        try {
                          final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            // ওয়েব এর জন্য বাইট হিসেবে রিড করা
                            var f = await picked.readAsBytes();
                            setDialogState(() {
                              webImage = f;
                            });
                          }
                        } catch (e) {
                          print("Error picking image: $e");
                          // ব্যবহারকারীকে এরর মেসেজ দেখান
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Could not pick image: $e")),
                          );
                        }
                      },
                    ),

                    // --- ইমেজ প্রিভিউ অংশ (এটি স্ক্রিনশটে হিডেন ছিল) ---
                    if (webImage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Receipt Preview:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              // Image.memory ব্যবহার করছি Web এর জন্য
                              child: Image.memory(
                                webImage!,
                                height: 150, // একটি নির্দিষ্ট উচ্চতা দিন
                                width: double.infinity, // কন্টেনারের সমান প্রস্থ
                                fit: BoxFit.cover, // ইমেজটিকে কন্টেনারের ভেতর ফিট করবে
                              ),
                            ),
                          ],
                        ),
                      ),
                    // একটি স্পেস যাতে বাটনগুলো কন্টেন্টের সাথে লেগে না থাকে
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            // --- বাটন অংশ ---
            actions: [
              TextButton(
                  onPressed: () {
                    // কন্ট্রোলার রিলিজ করে দিন ডায়ালগ বন্ধ করার আগে
                    // transCtrl.dispose();
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel")
              ),
              ElevatedButton(
                onPressed: () async {
                  if (transCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter Transaction ID"))
                    );
                    return;
                  }

                  // সেভ কল করছি। লক্ষ্য করুন, আমি null পাঠাচ্ছি selectedImage এর বদলে।
                  // আপনার কন্ট্রোলার Uint8List (webImage) গ্রহণ করার জন্য আপডেট করতে হবে।
                  await _controller.saveRefund(
                      item['booking_id'],
                      item['user_id'].toString(),
                      status,
                      transCtrl.text,
                      null, // কন্ট্রোলারের Uint8List সাপোর্টের জন্য এটি চেক করুন
                          () {
                        // transCtrl.dispose();
                        onUpdate(); // লিস্ট রিফ্রেশ হবে
                        Navigator.pop(context); // ডায়লগ বন্ধ হবে
                      }
                  );
                },
                child: const Text("Confirm"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final steps = ['request', 'approved', 'processing', 'refunded'];
    String current = (item['refund_status']?.toString().toLowerCase()) ?? 'request';
    bool isRefunded = current == 'refunded';

    return Center(
      child: Container(
        width: screenWidth > 1000 ? 1000 : double.infinity,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("ID: ${item['booking_id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                if (isRefunded) const Chip(label: Text("REFUNDED", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
              ],
            ),
            subtitle: Text("Status: ${item['booking_status']?.toUpperCase() ?? ''} | Refund Amount: ${item['refund_amount'] ?? 0}"),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ..._buildDataList(),
                  const Divider(height: 30),

                  // শুধুমাত্র এখানে বাটনটি রাখা হয়েছে
                  if (item['booking_status'] == 'cancellation pending')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: SizedBox(width: double.infinity, child: ElevatedButton(
                          onPressed: () async {
                            double basePrice = double.tryParse(item['base_price']?.toString() ?? "0") ?? 0.0;
                            double paymentAmount = double.tryParse(item['payment_amount']?.toString() ?? "0") ?? 0.0;
                                await _controller.approveCancellation(
                                item['booking_id'],
                                basePrice,
                                paymentAmount,
                                onUpdate
                            );
                          },
                          child: const Text("Approve Cancellation")
                      )),
                    ),

                  Wrap(spacing: 8, runSpacing: 8, children: steps.map((s) {
                    int i = steps.indexOf(s);
                    int cur = steps.indexOf(current);
                    return ChoiceChip(
                      label: Text(s.toUpperCase(), style: const TextStyle(fontSize: 11)),
                      selected: i <= cur,
                      selectedColor: isRefunded ? Colors.green : Colors.blue.shade200,
                      onSelected: (i < cur) ? null : (_) async {
                        if (s == 'refunded') {
                          _showRefundDialog(context, s);
                        } else {
                          await _controller.updateRefundStatusOnly(item['booking_id'], s, onUpdate);
                        }
                      },
                    );
                  }).toList()),

                  if (item['refund_transaction_image'] != null) ...[
                    const SizedBox(height: 20),
                    const Text("Refund Transaction Receipt:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Image.network(item['refund_transaction_image'], width: double.infinity, fit: BoxFit.cover),
                  ]
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}

