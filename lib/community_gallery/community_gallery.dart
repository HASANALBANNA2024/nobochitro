import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// -----------------------------------------------------------------------
/// GALLERY MODEL
/// -----------------------------------------------------------------------
class GalleryModel {
  final String id;
  final String imageUrl;

  GalleryModel({required this.id, required this.imageUrl});
}

/// -----------------------------------------------------------------------
/// COMMUNITY GALLERY SECTION (UPDATED: DYNAMIC TITLE + MASONRY)
/// -----------------------------------------------------------------------
class CommunityGallery extends StatefulWidget {
  final List<GalleryModel>? customGalleryItems;
  final Color primaryAccent;
  final String sectionTitle;

  const CommunityGallery({
    super.key,
    this.customGalleryItems,
    required this.primaryAccent,
    this.sectionTitle = 'Community Highlights',
  });

  @override
  State<CommunityGallery> createState() => _CommunityGalleryState();
}

class _CommunityGalleryState extends State<CommunityGallery> {
  int _visibleCount = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final double screenWidth = MediaQuery.of(context).size.width;

    final List<GalleryModel> allItems =
        widget.customGalleryItems ??
        [
          GalleryModel(
            id: '1',
            imageUrl:
                'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=500',
          ),
          GalleryModel(
            id: '2',
            imageUrl:
                'https://images.unsplash.com/photo-1554080353-a576cf803bda?w=500',
          ),
          GalleryModel(
            id: '3',
            imageUrl:
                'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500',
          ),
          GalleryModel(
            id: '4',
            imageUrl:
                'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500',
          ),
          GalleryModel(
            id: '5',
            imageUrl:
                'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=500',
          ),
          GalleryModel(
            id: '6',
            imageUrl:
                'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=500',
          ),
          GalleryModel(
            id: '7',
            imageUrl:
                'https://images.unsplash.com/photo-1532712938310-34cb3982ef74?w=500',
          ),
          GalleryModel(
            id: '8',
            imageUrl:
                'https://images.unsplash.com/photo-1519741497674-611481863552?w=500',
          ),
        ];

    final displayItems = allItems.take(_visibleCount).toList();
    int crossAxisCount = screenWidth > 1200 ? 4 : (screenWidth > 800 ? 3 : 2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.sectionTitle,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          MasonryGridView.count(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: displayItems.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _GalleryItemCard(
                imageUrl: displayItems[index].imageUrl,
                index: index,
              );
            },
          ),

          if (_visibleCount < allItems.length)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _visibleCount += 4;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: widget.primaryAccent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'See More',
                    style: TextStyle(
                      color: widget.primaryAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryItemCard extends StatelessWidget {
  final String imageUrl;
  final int index;

  const _GalleryItemCard({required this.imageUrl, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}
