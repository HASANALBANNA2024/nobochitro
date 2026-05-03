import 'dart:async';
import 'package:flutter/material.dart';

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

class PhotographyPackages extends StatefulWidget {
  final Color primaryAccent;

  const PhotographyPackages({
    super.key,
    required this.primaryAccent,
  });

  @override
  State<PhotographyPackages> createState() => _PhotographyPackagesState();
}

class _PhotographyPackagesState extends State<PhotographyPackages> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  final List<PackageModel> packages = [
    PackageModel(
      title: "Cinematic Wedding",
      subtitle: "Premier album & 4K video included with professional lighting and drone shots for your special day.",
      price: "\$499",
      imageUrl: "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400",
    ),
    PackageModel(
      title: "Cinematic Wedding",
      subtitle: "Premier album & 4K video included with professional lighting and drone shots for your special day.",
      price: "\$499",
      imageUrl: "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400",
    ),
    PackageModel(
      title: "Cinematic Wedding",
      subtitle: "Premier album & 4K video included with professional lighting and drone shots for your special day.",
      price: "\$499",
      imageUrl: "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400",
    ),  PackageModel(
      title: "Cinematic Wedding",
      subtitle: "Premier album & 4K video included with professional lighting and drone shots for your special day.",
      price: "\$499",
      imageUrl: "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400",
    ),
    PackageModel(
      title: "Cinematic Wedding",
      subtitle: "Premier album & 4K video included with professional lighting and drone shots for your special day.",
      price: "\$499",
      imageUrl: "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400",
    ),
    PackageModel(
      title: "Cinematic Wedding",
      subtitle: "Premier album & 4K video included with professional lighting and drone shots for your special day.",
      price: "\$499",
      imageUrl: "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400",
    ),
    PackageModel(
      title: "Cinematic Wedding",
      subtitle: "Premier album & 4K video included with professional lighting and drone shots for your special day.",
      price: "\$499",
      imageUrl: "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400",
    ),
    PackageModel(
      title: "Cinematic Wedding",
      subtitle: "Premier album & 4K video included with professional lighting and drone shots for your special day.",
      price: "\$499",
      imageUrl: "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400",
    ),
    PackageModel(
      title: "Cinematic Wedding",
      subtitle: "Premier album & 4K video included with professional lighting and drone shots for your special day.",
      price: "\$499",
      imageUrl: "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400",
    ),
    PackageModel(
      title: "Cinematic Wedding",
      subtitle: "Premier album & 4K video included with professional lighting and drone shots for your special day.",
      price: "\$499",
      imageUrl: "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400",
    ),
    PackageModel(
      title: "Cinematic Wedding",
      subtitle: "Premier album & 4K video included with professional lighting and drone shots for your special day.",
      price: "\$499",
      imageUrl: "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400",
    ),


  ];

  @override
  void initState() {
    super.initState();
    // ইনিশিয়াল কন্ট্রোলার
    _pageController = PageController(viewportFraction: 0.8, initialPage: 0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        if (_currentPage < packages.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;

    // fraction এমনভাবে সেট করা হয়েছে যাতে দুই পাশে কার্ডের অংশ (কাটা পার্ট) দেখা যায়
    // Web: 0.35 (মাঝে ১টি পূর্ণ, দুই পাশে দুটি কাটা), Tablet: 0.55, Mobile: 0.8
    double fraction = screenWidth > 1200 ? 0.35 : (screenWidth > 800 ? 0.55 : 0.8);

    if (_pageController.viewportFraction != fraction) {
      _pageController = PageController(viewportFraction: fraction, initialPage: _currentPage);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exclusive Packages',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: Text('View All', style: TextStyle(color: widget.primaryAccent)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 380,
          child: PageView.builder(
            controller: _pageController,
            itemCount: packages.length,
            // padEnds: true রাখলে প্রথম ও শেষ কার্ডের সময়ও দুই পাশে গ্যাপ/কাটা অংশ বজায় থাকে
            padEnds: true,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) => _currentPage = index,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  // স্লাইড করার সময় পাশের কার্ডগুলো সামান্য ছোট দেখাবে যা প্রিমিয়াম লুক দেয়
                  double value = 1.0;
                  if (_pageController.position.hasContentDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.06)).clamp(0.0, 1.0);
                  }
                  return Center(
                    child: Transform.scale(
                      scale: value,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: _buildPackageCard(
                    packages[index],
                    theme.colorScheme,
                    theme.textTheme,
                    widget.primaryAccent,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(PackageModel package, ColorScheme colorScheme, TextTheme textTheme, Color primaryAccent) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Image.network(
              package.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        package.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Book'),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}