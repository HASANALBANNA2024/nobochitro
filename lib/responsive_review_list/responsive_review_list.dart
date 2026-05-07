import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

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

class ResponsiveReviewList extends StatefulWidget {
  final Color primaryAccent;
  final String sectionTitle; // টাইটেল ডাইনামিক করার জন্য

  const ResponsiveReviewList({
    super.key,
    required this.primaryAccent,
    this.sectionTitle = 'Client Testimonials', // ডিফল্ট টাইটেল
  });

  @override
  State<ResponsiveReviewList> createState() => _ResponsiveReviewListState();
}

class _ResponsiveReviewListState extends State<ResponsiveReviewList> {
  late PageController _pageController;
  Timer? _autoTimer;
  int _currentPage = 0;

  final List<ReviewModel> _reviews = List.generate(
    15,
    (index) => ReviewModel(
      name: "User Name $index",
      reviewText: index % 2 == 0
          ? "Exceptional service from NoboChitro! Highly recommended."
          : "The photo quality and professionalism are top-notch. I am really happy with the results of my event photography.",
      imageUrl: "https://i.pravatar.cc/150?u=$index",
      rating: 4.8,
    ),
  );

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage % _reviews.length,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // --- নতুন BottomSheet মেথড (৭৫% হাইট) ---
  void _showAllReviewsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // এটি হাইট কন্ট্রোল করতে সাহায্য করে
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75, // ৭৫% থেকে শুরু হবে
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ড্র্যাগ হ্যান্ডেল
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.sectionTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  controller: controller, // ড্র্যাগ স্ক্রল করার জন্য এটি জরুরি
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 900
                        ? 3
                        : 1,
                    mainAxisExtent: 160,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: _reviews.length,
                  itemBuilder: (context, i) => _ReviewCard(
                    review: _reviews[i],
                    primaryAccent: widget.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fraction = screenWidth > 1400
        ? 0.2
        : (screenWidth > 1000 ? 0.33 : (screenWidth > 600 ? 0.5 : 1.0));

    _pageController = PageController(
      viewportFraction: fraction,
      initialPage: _currentPage,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 15),
            child: Text(
              widget.sectionTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 180,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _reviews.length,
                  padEnds: false,
                  onPageChanged: (i) => _currentPage = i,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: _ReviewCard(
                      review: _reviews[i],
                      primaryAccent: widget.primaryAccent,
                    ),
                  ),
                ),
              ),
            ),
            if (screenWidth > 800) ...[
              Positioned(
                left: 5,
                child: _Arrow(
                  icon: Icons.arrow_back_ios,
                  onTap: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  ),
                ),
              ),
              Positioned(
                right: 5,
                child: _Arrow(
                  icon: Icons.arrow_forward_ios,
                  onTap: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  ),
                ),
              ),
            ],
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10, top: 0),
          child: TextButton.icon(
            onPressed: _showAllReviewsSheet, // আপডেট করা হয়েছে
            icon: const Icon(Icons.grid_view_rounded, size: 16),
            label: const Text(
              "View All",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            style: TextButton.styleFrom(foregroundColor: widget.primaryAccent),
          ),
        ),
      ],
    );
  }
}

// --- Arrow Button ---
class _Arrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Arrow({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.7),
      shape: BoxShape.circle,
    ),
    child: IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: Colors.black87),
    ),
  );
}

// --- Helper Widgets---
class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final Color primaryAccent;
  const _ReviewCard({required this.review, required this.primaryAccent});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(review.imageUrl),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.star, color: Colors.amber, size: 12),
                Text(" ${review.rating}", style: const TextStyle(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                review.reviewText,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.format_quote,
                size: 18,
                color: primaryAccent.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
