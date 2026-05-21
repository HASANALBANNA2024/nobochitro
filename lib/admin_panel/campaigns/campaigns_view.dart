import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'show_campaign_form.dart';
import 'campaigns_list_item.dart';

class CampaignsView extends StatefulWidget {
  const CampaignsView({super.key});
  @override
  State<CampaignsView> createState() => _CampaignsViewState();
}

class _CampaignsViewState extends State<CampaignsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // বডি সেন্টারে রেখে ConstrainedBox দিয়ে ১১০০ পিক্সেলের লিমিট দেওয়া হয়েছে
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            key: UniqueKey(),
            future: DatabaseHelper.instance.getData(table: 'campaigns'),
            builder: (context, snapshot) {
              // লোডিং স্টেট
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              // এরর বা ডাটা না থাকলে
              if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("কোনো ক্যাম্পেইন পাওয়া যায়নি!"));
              }

              // ডাটা লিস্ট
              return ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, i) => CampaignsListItem(
                  item: snapshot.data![i],
                  onUpdate: () => setState(() {}),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCampaignForm(context, onComplete: () => setState(() {})),
        child: const Icon(Icons.add),
      ),
    );
  }
}