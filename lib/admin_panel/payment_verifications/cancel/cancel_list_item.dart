import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'cancel_controller.dart';

class CancelListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onUpdate;
  final CancelController _controller = CancelController();

  CancelListItem({super.key, required this.item, required this.onUpdate});

  // --- ডাটা ফিল্ড বিল্ডার ---
  List<Widget> _buildDataList() {
    List<Widget> widgets = [];
    item.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty &&
          !['booking_id', 'booking_status', 'refund_status', 'refund_transaction', 'refund_transaction_image', 'transaction_image_url', 'booking_amount', 'refund_amount'].contains(key)) {
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

  // --- রিফান্ড ডায়ালগ ---
  void _showRefundDialog(BuildContext context, String status) {
    TextEditingController transCtrl = TextEditingController(text: item['refund_transaction'] ?? "");
    File? selectedImage;

    showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
      return AlertDialog(
        title: Text("Confirm: ${status.toUpperCase()}"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: transCtrl, decoration: const InputDecoration(labelText: "Transaction ID")),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt), label: const Text("Pick Image"),
            onPressed: () async {
              final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (picked != null) setDialogState(() => selectedImage = File(picked.path));
            },
          ),
          if (selectedImage != null) const Text("Image Selected!", style: TextStyle(color: Colors.green)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () async {
            await _controller.saveRefund(item['booking_id'], item['user_id'].toString(), status, transCtrl.text, selectedImage, onUpdate);
            Navigator.pop(context);
          }, child: const Text("Confirm")),
        ],
      );
    }));
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

                  // অ্যাপ্রুভ বাটন
                  if (item['booking_status'] == 'cancellation pending')
                    SizedBox(width: double.infinity, child: ElevatedButton(
                        onPressed: () => _controller.approveCancellation(item['booking_id'], double.tryParse(item['booking_amount'].toString()) ?? 0.0, onUpdate),
                        child: const Text("Approve Cancellation")
                    )),

                  const SizedBox(height: 15),

                  // রেডিও চিপস
                  Wrap(spacing: 8, runSpacing: 8, children: steps.map((s) {
                    int i = steps.indexOf(s);
                    int cur = steps.indexOf(current);
                    return ChoiceChip(
                      label: Text(s.toUpperCase(), style: const TextStyle(fontSize: 11)),
                      selected: i <= cur,
                      selectedColor: isRefunded ? Colors.green : Colors.blue.shade200,
                      onSelected: (i < cur) ? null : (_) {
                        if (s == 'refunded') {
                          _showRefundDialog(context, s);
                        } else {
                          _controller.updateRefundStatusOnly(item['booking_id'], s, onUpdate);
                        }
                      },
                    );
                  }).toList()),

                  // ইমেজ ভিউ
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