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
  int _visibleCount = 8;

  /// supabase storage main url
  final String _storageBaseUrl =
      "https://whdyselehlvbshnoezgz.supabase.co/storage/v1/object/public/user_assets/";

  ///image path clean and full url
  String _buildFullImageUrl(String rawData) {
    /// unwanted tex remove
    String path = rawData
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .trim();

    /// url retur
    if (path.startsWith('http')) {
      return path;
    }

    /// to create main url embedded of base url
    return _storageBaseUrl + path;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: widget.galleryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        /// error handling
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!;
        final displayItems = items.take(_visibleCount).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                widget.sectionTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            MasonryGridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              itemCount: displayItems.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, i) {
                final fullImageUrl = _buildFullImageUrl(displayItems[i]);

                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    fullImageUrl,
                    fit: BoxFit.cover,

                    /// error handling
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                );
              },
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
