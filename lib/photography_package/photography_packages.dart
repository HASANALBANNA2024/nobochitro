import 'package:flutter/material.dart';

/// -----------------------------------------------------------------------
/// PACKAGE MODEL
/// -----------------------------------------------------------------------
class PackageModel {
  final String title;
  final String subtitle;
  final String price;
  final String imageUrl;

  PackageModel({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
  });
}

/// -----------------------------------------------------------------------
/// PHOTOGRAPHY PACKAGES SECTION
/// -----------------------------------------------------------------------
class PhotographyPackages extends StatelessWidget {
  final Color primaryAccent;

  const PhotographyPackages({
    super.key,
    required this.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // --- DEMO DATA (সব লজিক ফাইলের ভেতরে) ---
    final List<PackageModel> packages = [
      PackageModel(
        title: "Cinematic Wedding",
        subtitle: "Premier album & 4K video included",
        price: "\$499",
        imageUrl: "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400",
      ),
      PackageModel(
        title: "Portrait Session",
        subtitle: "Professional lighting & 20 edited shots",
        price: "\$199",
        imageUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400",
      ),
      PackageModel(
        title: "Event Coverage",
        subtitle: "Full event raw files & quick highlights",
        price: "\$350",
        imageUrl: "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=400",
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Exclusive Packages',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: Text('View All', style: TextStyle(color: primaryAccent)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive logic (Web/Tablet/Mobile)
            int count = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.85, // আপনার আগের রেশিও অনুযায়ী
              ),
              itemCount: packages.length,
              itemBuilder: (context, index) => _buildPackageCard(
                packages[index],
                colorScheme,
                textTheme,
                primaryAccent,
              ),
            );
          },
        ),
      ],
    );
  }

  /// -----------------------------------------------------------------------
  /// আপনার দেওয়া অরিজিনাল কার্ড ডিজাইন (উইজেট হিসেবে)
  /// -----------------------------------------------------------------------
  Widget _buildPackageCard(PackageModel package, ColorScheme colorScheme, TextTheme textTheme, Color primaryAccent) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ইমেজ সেকশন
          Expanded(
            child: Image.network(
              package.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          // কন্টেন্ট সেকশন
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 5),
                Text(
                  package.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      package.price,
                      style: TextStyle(
                        color: primaryAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Booking/Firebase Logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Book', style: TextStyle(color: Colors.white)),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}