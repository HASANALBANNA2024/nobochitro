import 'package:flutter/material.dart';
import 'show_campaign_form.dart';
import 'campaigns_logic.dart';

class CampaignsListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onUpdate;
  const CampaignsListItem({super.key, required this.item, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // ১. ব্যানার ইমেজ
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['banner_url'] ?? '',
                width: 100, height: 80, fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Container(width: 100, height: 80, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
              ),
            ),
            const SizedBox(width: 15),

            // ২. বাকি সব ডাটা
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  // গ্রিড বা র‍্যাপ আকারে সব ডাটা
                  Wrap(
                    spacing: 10, runSpacing: 5,
                    children: [
                      _infoChip("🎟️ ${item['campaign_id'] ?? 'N/A'}"),
                      _infoChip("💰 ${item['discount_pct']}% OFF"),
                      _infoChip("📂 Cat: ${item['targeted_category'] ?? 'All'}"),
                      _infoChip("📦 Pkg: ${item['targeted_package_id'] ?? 'All'}"),
                      _infoChip("📅 ${item['start_date']} - ${item['end_date']}"),
                      _infoChip(item['is_active'] == true ? "✅ Active" : "❌ Inactive",
                          color: item['is_active'] == true ? Colors.green[100] : Colors.red[100]),
                    ],
                  ),
                ],
              ),
            ),

            // ৩. এডিট/ডিলিট বাটন
            Column(
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => showCampaignForm(context, item: item, onComplete: onUpdate)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { await CampaignsLogic.delete(item['id']); onUpdate(); }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// helper widget for display info 
  Widget _infoChip(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        softWrap: true,
      ),
    );
  }
}