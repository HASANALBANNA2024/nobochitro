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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _controller.fetchActivePayments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("কোনো একটিভ পেমেন্ট নেই!"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) => PaymentListItem(
              item: snapshot.data![i],
              onUpdate: () => setState(() {}),
            ),
          );
        },
      ),
    );
  }
}