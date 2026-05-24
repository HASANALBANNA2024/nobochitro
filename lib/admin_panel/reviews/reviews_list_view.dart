import 'package:flutter/material.dart';
import 'review_logic.dart';

class ReviewsListView extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;
  final VoidCallback onRefresh;

  const ReviewsListView({
    super.key,
    required this.reviews,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ExpansionTile(
            title: Text("${review['user_name'] ?? 'Anonymous'}"),

            /// email subtitle done
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Email: ${review['user_email'] ?? 'No Email'}"),
                Text(
                  "Rating: ${review['rating']} | Package: ${review['package_name'] ?? 'N/A'}",
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Comment: ${review['comment'] ?? 'No comment'}"),
                    const SizedBox(height: 10),

                    /// review image logic
                    if (review['review_image_url'] != null)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 1,
                          itemBuilder: (context, i) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.network(
                              review['review_image_url'].toString().replaceAll(
                                RegExp(r'[\[\]"]'),
                                '',
                              ),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 15),

                    ///Delete button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                      ),
                      onPressed: () async {
                        bool confirm =
                            await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Delete Review"),
                                content: const Text(
                                  "Are you sure this is a harmful review?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            ) ??
                            false;

                        if (confirm) {
                          await ReviewLogic.deleteReview(review);
                          onRefresh();
                        }
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        "Delete Harmful Review",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
