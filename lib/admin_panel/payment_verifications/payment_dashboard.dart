import 'package:flutter/material.dart';
import 'package:nobochitro/admin_panel/payment_verifications/active/active_payments_tab.dart';


class PaymentDashboard extends StatelessWidget {
  const PaymentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 8,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Active", icon: Icon(Icons.check_circle)),
              Tab(text: "Cancelled", icon: Icon(Icons.cancel)),
              Tab(text: "Suspended", icon: Icon(Icons.warning)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ActivePaymentsTab(),
            Center(child: Text("Cancelled Data")), // ২ নম্বর ট্যাব (অবশ্যই দিতে হবে)
            Center(child: Text("Suspended Data")),
          ],
        ),
      ),
    );
  }
}