import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CommunityGallery extends StatefulWidget {
  final Future<List<String>> galleryFuture;
  final Color primaryAccent;
  final String sectionTitle;

  const CommunityGallery({
    super.key,
    required this.galleryFuture,
    required this.primaryAccent,
    this.sectionTitle = 'Gallery',
  });

  @override
  State<CommunityGallery> createState() => _CommunityGalleryState();
}

class _CommunityGalleryState extends State<CommunityGallery> {
  int _visibleCount = 8; // ড্যাশবোর্ডে বেশি দেখানোর জন্য ৮ দিলাম

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: widget.galleryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!;
        final displayItems = items.take(_visibleCount).toList();

        return Column(
          children: [
            Text(
              widget.sectionTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            MasonryGridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
              itemCount: displayItems.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, i) => ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(displayItems[i]),
              ),
            ),
            if (_visibleCount < items.length)
              TextButton(
                onPressed: () => setState(() => _visibleCount += 4),
                child: const Text("See More"),
              ),
          ],
        );
      },
    );
  }
}
