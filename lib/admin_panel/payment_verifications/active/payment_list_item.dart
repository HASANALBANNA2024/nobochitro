import 'package:flutter/material.dart';
import 'package:nobochitro/admin_panel/payment_verifications/active/paymnet_controller.dart';

class PaymentListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onUpdate;
  final PaymentController _controller = PaymentController();

  PaymentListItem({super.key, required this.item, required this.onUpdate});

  /// --- time formating method ---
  String _formatValue(String key, dynamic value) {
    if ((key.toLowerCase().contains('date') ||
            key.toLowerCase().contains('time') ||
            key.toLowerCase().contains('at')) &&
        value is String) {
      try {
        DateTime dt = DateTime.parse(value);
        String date =
            "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
        int hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        String ampm = dt.hour >= 12 ? "PM" : "AM";
        String time =
            "${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm";
        return "$date, $time";
      } catch (e) {
        return value.toString();
      }
    }
    return value.toString();
  }

  /// --- all dialogue method ---
  void _showSuspendDialog(BuildContext context) {
    TextEditingController noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Suspend Reason"),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(hintText: "Enter reason..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.suspendPayment(
                item['booking_id'],
                noteController.text,
                onUpdate,
              );
              Navigator.pop(context);
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void _showHandoverDialog(BuildContext context) {
    TextEditingController driveController = TextEditingController();
    driveController.text = item['drive_link_handover'] ?? "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Drive Link"),
        content: TextField(
          controller: driveController,
          decoration: const InputDecoration(hintText: "Google Drive Link"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (driveController.text.isNotEmpty) {
                _controller.updateHandover(
                  item['booking_id'],
                  driveController.text,
                  onUpdate,
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _showExpandedImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(
                child: Image.network(item['transaction_image_url']),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --- info list builder ---
  List<Widget> _buildDataList() {
    List<Widget> widgets = [];
    item.forEach((key, value) {
      if (value != null &&
          value.toString().isNotEmpty &&
          key != 'transaction_image_url' &&
          key != 'id' &&
          key != 'selected_addons_breakdown' &&
          key != 'booking_status' &&
          key != 'booking_id') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    key.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    ": ${_formatValue(key, value)}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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

  /// --- Status Radio List ---
  Widget _buildStatusRadioGroup(BuildContext context) {
    final List<String> statusOrder = [
      'pending',
      'approved',
      'shooting',
      'final draft',
      'handover',
    ];
    int currentIndex = statusOrder.indexOf(item['booking_status'] ?? 'pending');

    return Wrap(
      spacing: 8,
      children: statusOrder.map((status) {
        int chipIndex = statusOrder.indexOf(status);
        return ChoiceChip(
          label: Text(
            status.toUpperCase(),
            style: const TextStyle(fontSize: 11),
          ),
          selected: chipIndex <= currentIndex,
          selectedColor: status == item['booking_status']
              ? Colors.green
              : Colors.blue.shade200,
          onSelected: (val) {
            if (chipIndex > currentIndex + 1) return;
            if (status == 'handover')
              _showHandoverDialog(context);
            else if (chipIndex > currentIndex)
              _controller.updateBookingStatusOnly(
                item['booking_id'],
                status,
                onUpdate,
              );
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isApproved = item['booking_status'] != 'pending';
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width > 1000
            ? 1000
            : double.infinity,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Booking-ID: ${item['booking_id'] ?? 'N/A'}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    item['booking_status']?.toUpperCase() ?? 'N/A',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  backgroundColor: isApproved ? Colors.green : Colors.orange,
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._buildDataList(),
                    if (item['transaction_image_url'] != null)
                      GestureDetector(
                        onTap: () => _showExpandedImage(context),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Image.network(
                              item['transaction_image_url'],
                              height: 150,
                            ),
                          ),
                        ),
                      ),
                    const Divider(height: 30),
                    isApproved
                        ? _buildStatusRadioGroup(context)
                        : Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.check),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: () => _controller.updateStatus(
                                    item['booking_id'],
                                    'approved',
                                    onUpdate,
                                  ),
                                  label: const Text("Approve"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.close),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () => _showSuspendDialog(context),
                                  label: const Text("Suspend"),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
