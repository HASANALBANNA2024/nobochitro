import 'package:flutter/material.dart';
import 'suspended_controller.dart';
import 'suspended_list_item.dart';

class SuspendedView extends StatefulWidget {
  const SuspendedView({super.key});
  @override
  State<SuspendedView> createState() => _SuspendedViewState();
}

class _SuspendedViewState extends State<SuspendedView> {
  final SuspendedController _controller = SuspendedController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _controller.fetchSuspended(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, i) => SuspendedListItem(
            item: snapshot.data![i],
            onUpdate: () => setState(() {}),
          ),
        );
      },
    );
  }
}