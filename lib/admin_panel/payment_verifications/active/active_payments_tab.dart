import 'package:flutter/material.dart';
import 'package:nobochitro/admin_panel/payment_verifications/active/paymnet_controller.dart';
import 'payment_list_item.dart';

class ActivePaymentsTab extends StatefulWidget {
  const ActivePaymentsTab({super.key});

  @override
  State<ActivePaymentsTab> createState() => _ActivePaymentsTabState();
}

class _ActivePaymentsTabState extends State<ActivePaymentsTab> {
  final PaymentController _controller = PaymentController();

  /// it refresh future builder in new time
  void _refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _controller.fetchActivePayments(), /// all time refresh
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No Found Any activate!"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, i) => PaymentListItem(
            item: snapshot.data![i],
            onUpdate: _refreshData,
          ),
        );
      },
    );
  }
}