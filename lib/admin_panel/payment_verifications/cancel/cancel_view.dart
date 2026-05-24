import 'package:flutter/material.dart';
import 'cancel_controller.dart';
import 'cancel_list_item.dart';

class CancelView extends StatefulWidget {
  const CancelView({super.key});
  @override
  State<CancelView> createState() => _CancelViewState();
}

class _CancelViewState extends State<CancelView> {
  final CancelController _controller = CancelController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _controller.fetchCancelled(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, i) => CancelListItem(
            item: snapshot.data![i],
            onUpdate: () => setState(() {}),
          ),
        );
      },
    );
  }
}