import 'package:flutter/material.dart';

/// -----------------------------------------------------------------------
/// GALLERY MODEL
/// This model represents the structure of each gallery item.
/// -----------------------------------------------------------------------
class GalleryModel {
  final String id;
  final String imageUrl;

  GalleryModel({required this.id, required this.imageUrl});
}

/// -----------------------------------------------------------------------
/// COMMUNITY GALLERY SECTION
/// -----------------------------------------------------------------------
class CommunityGallery extends StatelessWidget {
  final List<GalleryModel>? customGalleryItems;

  const CommunityGallery({
    super.key,
    this.customGalleryItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // --- DEMO DATA SECTION ---
    // If no custom data is passed, it uses these demo images.
    final List<GalleryModel> displayItems = customGalleryItems ?? [
      GalleryModel(id: '1', imageUrl: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=500'),
      GalleryModel(id: '2', imageUrl: 'https://images.unsplash.com/photo-1554080353-a576cf803bda?w=500'),
      GalleryModel(id: '3', imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500'),
      GalleryModel(id: '4', imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500'),
      GalleryModel(id: '5', imageUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=500'),
      GalleryModel(id: '6', imageUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=500'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community Highlights',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: displayItems.length,
            itemBuilder: (context, index) {
              return _GalleryItemCard(imageUrl: displayItems[index].imageUrl);
            },
          ),
        )
      ],
    );
  }
}

/// -----------------------------------------------------------------------
/// INDIVIDUAL GALLERY IMAGE CARD
/// -----------------------------------------------------------------------
class _GalleryItemCard extends StatelessWidget {
  final String imageUrl;

  const _GalleryItemCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3), // Placeholder color
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/*
  ---------------------------------------------------------
  FUTURE INTEGRATION GUIDE (FIREBASE / N8N):
  ---------------------------------------------------------

  1. FIREBASE LOGIC:
     - Wrap the call in your Dashboard with a StreamBuilder or FutureBuilder.
     - Example:
       StreamBuilder<QuerySnapshot>(
         stream: FirebaseFirestore.instance.collection('gallery').snapshots(),
         builder: (context, snapshot) {
           if (!snapshot.hasData) return CircularProgressIndicator();
           final items = snapshot.data!.docs.map((doc) => GalleryModel(
             id: doc.id,
             imageUrl: doc['url'],
           )).toList();
           return CommunityGallery(customGalleryItems: items);
         },
       );

  2. N8N AUTOMATION:
     - If you are fetching images from an n8n webhook or API:
     - Use a FutureProvider or an API service class to fetch the JSON list.
     - Map the JSON response to the 'GalleryModel' list and pass it to the widget.

  3. DARK & LIGHT MODE:
     - The widget uses 'Theme.of(context)' to adapt text colors.
     - The container border uses 'colorScheme.onSurface' to look good in both modes.
  ---------------------------------------------------------
*/