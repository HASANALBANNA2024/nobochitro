import 'package:flutter/material.dart';
import 'package:nobochitro/admin_panel/payment_verifications/active/active_payments_tab.dart';
import 'package:nobochitro/admin_panel/payment_verifications/cancel/cancel_view.dart';
import 'package:nobochitro/admin_panel/payment_verifications/suspended/suspended_view.dart';


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
            CancelView(),
            SuspendedView(),
          ],
        ),
      ),
    );
  }
}