import 'package:flutter/material.dart';
import 'package:nobochitro/admin_panel/payment_verifications/active/paymnet_controller.dart';

class PaymentListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onUpdate;
  final PaymentController _controller = PaymentController();

  PaymentListItem({super.key, required this.item, required this.onUpdate});

  List<Widget> _buildDataList() {
    List<Widget> widgets = [];
    item.forEach((key, value) {
      if (value != null &&
          value.toString().isNotEmpty &&
          key != 'transaction_image_url' &&
          key != 'id' &&
          key != 'selected_addons_breakdown') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    key.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    ": $value",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          "Booking ID: ${item['booking_id'] ?? 'N/A'}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Chip(
          label: Text(item['booking_status'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 10)),
          backgroundColor: (item['booking_status'] == 'approved') ? Colors.green : Colors.orange,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildDataList(),

                if (item['transaction_image_url'] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(item['transaction_image_url'], height: 250),
                      ),
                    ),
                  ),

                const Divider(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check, color: Colors.white),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                        onPressed: () => _controller.updateStatus(item['booking_id'], 'approved', onUpdate),
                        label: const Text("Approve", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 12)),
                        onPressed: () => _controller.updateStatus(item['booking_id'], 'suspended', onUpdate),
                        label: const Text("Suspend", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}