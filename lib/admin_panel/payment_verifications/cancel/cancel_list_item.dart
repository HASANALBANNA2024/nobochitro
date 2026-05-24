import 'dart:io';
import 'package:flutter/foundation.dart';
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

    // ওয়েব এবং মোবাইলের জন্য আলাদা ভেরিয়েবল
    Uint8List? webImage;
    File? mobileFile;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Confirm: ${status.toUpperCase()}"),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            content: Container(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                        final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          if (kIsWeb) {
                            var bytes = await picked.readAsBytes();
                            setDialogState(() => webImage = bytes);
                          } else {
                            setDialogState(() => mobileFile = File(picked.path));
                          }
                        }
                      },
                    ),

                    // ইমেজ প্রিভিউ লজিক
                    if (webImage != null || mobileFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? Image.memory(webImage!, height: 150, width: double.infinity, fit: BoxFit.cover)
                              : Image.file(mobileFile!, height: 150, width: double.infinity, fit: BoxFit.cover),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")
              ),
              ElevatedButton(
                onPressed: () async {
                  if (transCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter Transaction ID")));
                    return;
                  }

                  // প্ল্যাটফর্ম অনুযায়ী ইমেজ পাঠানো হচ্ছে
                  dynamic finalImage = kIsWeb ? webImage : mobileFile;

                  await _controller.saveRefund(
                      item['booking_id'],
                      item['user_id'].toString(),
                      status,
                      transCtrl.text,
                      finalImage, // এখানে ইমেজটি পাস করা হচ্ছে
                          () {
                        onUpdate();
                        Navigator.pop(context);
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
  /// main context
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

                  Wrap(
                    spacing: 20,
                    children: [
                      // যদি ইমেজ থাকে তবেই দেখাবে, নাহলে কিছুই হবে না
                      if (item['transaction_image_url'] != null && item['transaction_image_url'].toString().isNotEmpty)
                        _buildImagePreview(context, item['transaction_image_url'], "User Payment Receipt:"),

                      if (item['refund_transaction_image'] != null && item['refund_transaction_image'].toString().isNotEmpty)
                        _buildImagePreview(context, item['refund_transaction_image'], "Refund Transaction Receipt:"),
                    ],
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


                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// build image preview of transaction and refund transaction image
  Widget _buildImagePreview(BuildContext context, String imageUrl, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => showDialog(
              context: context,
              builder: (_) => Dialog(child: InteractiveViewer(child: Image.network(imageUrl)))
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              height: 120, // মিডিয়াম সাইজ
              width: 180,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

