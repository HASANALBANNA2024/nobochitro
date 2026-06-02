import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'suspended_controller.dart';

class SuspendedListItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onUpdate;
  const SuspendedListItem({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  @override
  State<SuspendedListItem> createState() => _SuspendedListItemState();
}

class _SuspendedListItemState extends State<SuspendedListItem> {
  final SuspendedController _controller = SuspendedController();

  void _showExpandedImage(String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title, style: const TextStyle(color: Colors.white)),
            ),
            Expanded(
              child: InteractiveViewer(
                child: Center(child: Image.network(url)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog() {
    TextEditingController notesCtrl = TextEditingController();
    Uint8List? webImage;
    File? mobileFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Reject Appeal"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: "Reason/Notes"),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text("Pick Proof Image"),
                  onPressed: () async {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
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
                  Container(
                    height: 100,
                    child: kIsWeb
                        ? Image.memory(webImage!)
                        : Image.file(mobileFile!),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
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
                child: const Text("Submit Reject"),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildDataList() {
    List<Widget> widgets = [];

    /// map to list
    var entries = widget.item.entries.toList();

    /// reversed display
    var reversedEntries = entries.reversed.toList();

    /// widget create for loop use
    for (var entry in reversedEntries) {
      var key = entry.key;
      var value = entry.value;
      if (value != null &&
          value.toString().isNotEmpty &&
          !key.toLowerCase().contains('image') &&
          key != 'booking_id' &&
          key != 'appeal_status') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    key.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(flex: 3, child: Text(": $value")),
              ],
            ),
          ),
        );
      }
    }
    return widgets;
  }

  Widget _buildImageGallery() {
    List<Widget> imageWidgets = [];
    widget.item.forEach((key, value) {
      if (key.toLowerCase().contains('image') &&
          value != null &&
          value.toString().isNotEmpty) {
        String title = key.replaceAll('_', ' ').toUpperCase();
        imageWidgets.add(
          GestureDetector(
            onTap: () => _showExpandedImage(value.toString(), title),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Image.network(
                  value.toString(),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                ),
              ],
            ),
          ),
        );
      }
    });
    return imageWidgets.isEmpty
        ? const SizedBox.shrink()
        : Wrap(spacing: 15, runSpacing: 15, children: imageWidgets);
  }

  @override
  Widget build(BuildContext context) {
    String appealStatus = widget.item['appeal_status'] ?? '';
    bool isRequest = appealStatus == 'request';
    bool isProcessing = appealStatus == 'processing';

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width > 1000
            ? 1000
            : double.infinity,
        child: Card(
          margin: const EdgeInsets.all(8),
          child: ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Booking-ID: ${widget.item['booking_id']}",
                  style: const TextStyle(fontSize: 14),
                ),

                /// Request status only
                if (isRequest)
                  const Chip(
                    label: Text(
                      "REQUEST",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.orange,
                    elevation: 4,
                  ),
              ],
            ),
            subtitle: Text("Status: ${widget.item['booking_status']}"),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._buildDataList(),
                    const SizedBox(height: 10),
                    _buildImageGallery(),

                    //
                    if (isRequest) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () => _controller.updateAppealStatus(
                              widget.item['booking_id'],
                              widget.item['user_id'].toString(),
                              'processing',
                              onDone: widget.onUpdate,
                            ),
                            child: const Text(
                              "Accept",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: _showRejectDialog,
                            child: const Text(
                              "Reject",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],

                    /// Processing Status and final approve
                    if (isProcessing) ...[
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            minimumSize: const Size(200, 50),
                          ),
                          onPressed: () => _controller.updateFinalApproval(
                            widget.item['booking_id'],
                            'approved',
                            'approved',
                            onDone: widget.onUpdate,
                          ),
                          child: const Text(
                            "Final Approve",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
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
