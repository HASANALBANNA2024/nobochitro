import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:nobochitro/admin_panel/photographers/photographer_form.dart';

import 'photographer_list_item.dart';

class PhotographerView extends StatefulWidget {
  const PhotographerView({super.key});

  @override
  State<PhotographerView> createState() => _PhotographerViewState();
}

class _PhotographerViewState extends State<PhotographerView> {
  List<Map<String, dynamic>> _photographers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData(); // শুরুতে ডাটা আনা
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getData(table: 'photographers');
    if (mounted) {
      setState(() {
        _photographers = data;
        _isLoading = false;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( // পুরো বডিকে সেন্টার করার জন্য
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000), // ওয়েবে সর্বোচ্চ ১০০০পিক্সেল
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _photographers.isEmpty
              ? const Center(child: Text("No photographers found"))
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 100),
            itemCount: _photographers.length,
            itemBuilder: (ctx, i) => PhotographerListItem(
              item: _photographers[i],
              onUpdate: _fetchData,
            ),

          ),

        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showPhotographerForm(context);
          _fetchData();
        },
        label: const Text("Add New"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
