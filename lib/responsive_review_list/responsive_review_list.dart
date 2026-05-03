import 'package:flutter/material.dart';

/// -----------------------------------------------------------------------
/// REVIEW MODEL
/// -----------------------------------------------------------------------
class ReviewModel {
  final String name;
  final String reviewText;
  final String imageUrl;
  final double rating;

  ReviewModel({
    required this.name,
    required this.reviewText,
    required this.imageUrl,
    required this.rating,
  });
}

/// -----------------------------------------------------------------------
/// RESPONSIVE REVIEW LIST (Main entry point)
/// -----------------------------------------------------------------------
class ResponsiveReviewList extends StatelessWidget {
  final Color primaryAccent;
  final List<ReviewModel>? customReviews;

  const ResponsiveReviewList({
    super.key,
    this.primaryAccent = Colors.blue, // Default color
    this.customReviews,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Logic to use Demo Data if no external data is provided
    final List<ReviewModel> displayList = customReviews ?? _getDemoData();

    // 2. Screen responsiveness logic
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isWeb)
        // WEB VIEW: Multiple cards in a Grid
          GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 10),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: screenWidth > 1200 ? 3 : 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              mainAxisExtent: 180, // Fixed height for alignment
            ),
            itemCount: displayList.length,
            itemBuilder: (context, index) => _ReviewCard(
              review: displayList[index],
              primaryAccent: primaryAccent,
            ),
          )
        else
        // MOBILE VIEW: Single column list
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 10),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            itemBuilder: (context, index) => _ReviewCard(
              review: displayList[index],
              primaryAccent: primaryAccent,
            ),
          ),
      ],
    );
  }

  /// INTERNAL DEMO DATA GENERATOR
  List<ReviewModel> _getDemoData() {
    return [
      ReviewModel(
        name: "MD. Hasan Al Banna",
        reviewText: "The Flutter implementation is very clean and the responsive UI works perfectly on web and mobile.",
        imageUrl: "https://i.pravatar.cc/150?u=hasan",
        rating: 5,
      ),
      ReviewModel(
        name: "Sarah Jenkins",
        reviewText: "Amazing user experience! The dark mode transitions are smooth and the layout is very intuitive.",
        imageUrl: "https://i.pravatar.cc/150?u=sarah",
        rating: 5,
      ),
      ReviewModel(
        name: "Alex Rivera",
        reviewText: "Great job on the performance. Even with many reviews, the scrolling remains buttery smooth.",
        imageUrl: "https://i.pravatar.cc/150?u=alex",
        rating: 4,
      ),
    ];
  }
}

/// -----------------------------------------------------------------------
/// SINGLE REVIEW CARD (Private Widget)
/// -----------------------------------------------------------------------
class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final Color primaryAccent;

  const _ReviewCard({
    required this.review,
    required this.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: NetworkImage(review.imageUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        review.name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                            (index) => Icon(
                          index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: primaryAccent,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review.reviewText,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
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
     - Fetch data from Firestore and map it to a List<ReviewModel>.
     - Pass that list to 'customReviews'.

  2. N8N INTEGRATION:
     - If you are fetching data from an n8n webhook or API:
     - Map the JSON response to the 'ReviewModel' list and pass it here.

  3. DARK & LIGHT MODE:
     - The 'colorScheme.surface' and 'theme.textTheme' handles theme
       adaptation automatically.
  ---------------------------------------------------------
*/