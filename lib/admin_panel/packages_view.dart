import 'package:flutter/material.dart';

class PackagesView extends StatelessWidget {
  const PackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // এখানে তোমার packages ডেটাবেস লজিক এবং UI থাকবে
          Text("Packages Content"),
        ],
      ),
    );
  }
}
