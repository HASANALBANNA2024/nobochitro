import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'suspended_controller.dart';

class SuspendedListItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onUpdate;
  const SuspendedListItem({super.key, required this.item, required this.onUpdate});

  @override
  State<SuspendedListItem> createState() => _SuspendedListItemState();
}

class _SuspendedListItemState extends State<SuspendedListItem> {
  final SuspendedController _controller = SuspendedController();

  void _showRejectDialog() {
    TextEditingController notesCtrl = TextEditingController();
    Uint8List? webImage;
    File? mobileFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text("Reject Appeal"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: "Reason/Notes")),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text("Pick Image"),
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
              if (webImage != null || mobileFile != null)
                Container(height: 100, child: kIsWeb ? Image.memory(webImage!) : Image.file(mobileFile!)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await _controller.updateAppealStatus(
                  widget.item['booking_id'],
                  widget.item['user_id'].toString(),
                  'rejected',
                  notes: notesCtrl.text,
                  image: kIsWeb ? webImage : mobileFile,
                  onDone: () {
                    widget.onUpdate();
                    Navigator.pop(context);
                  },
                );
              },
              child: const Text("Submit"),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    String appealStatus = widget.item['appeal_status'] ?? 'pending';

    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text("Booking ID: ${widget.item['booking_id']}"),
        subtitle: Text("Status: ${widget.item['booking_status']} | Appeal: $appealStatus"),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // যদি ইমেজ থাকে তবে দেখাবে
                if (widget.item['appeal_cancel_image'] != null)
                  Image.network(widget.item['appeal_cancel_image'], height: 150),

                const SizedBox(height: 15),

                // বাটন লজিক
                if (appealStatus == 'pending') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => _controller.updateAppealStatus(widget.item['booking_id'], widget.item['user_id'].toString(), 'processing', onDone: widget.onUpdate),
                        child: const Text("Accept", style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: _showRejectDialog,
                        child: const Text("Reject", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],

                if (appealStatus == 'processing')
                  ElevatedButton(
                    onPressed: () => _controller.updateAppealStatus(widget.item['booking_id'], widget.item['user_id'].toString(), 'approved', onDone: widget.onUpdate),
                    child: const Text("Approve Final"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}