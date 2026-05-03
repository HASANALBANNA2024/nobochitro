import 'dart:async';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ReviewModel {
  final String name;
  final String reviewText;
  final String imageUrl;
  final double rating;

  ReviewModel({required this.name, required this.reviewText, required this.imageUrl, required this.rating});
}

class ResponsiveReviewList extends StatefulWidget {
  final Color primaryAccent;
  const ResponsiveReviewList({super.key, required this.primaryAccent});

  @override
  State<ResponsiveReviewList> createState() => _ResponsiveReviewListState();
}

class _ResponsiveReviewListState extends State<ResponsiveReviewList> {
  late PageController _pageController;
  Timer? _autoTimer;
  int _currentPage = 0;

  final List<ReviewModel> _reviews = List.generate(15, (index) => ReviewModel(
    name: "User Name $index",
    reviewText: index % 2 == 0
        ? "Exceptional service from NoboChitro! Highly recommended."
        : "The photo quality and professionalism are top-notch. I am really happy with the results of my event photography.",
    imageUrl: "https://i.pravatar.cc/150?u=$index",
    rating: 4.8,
  ));

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

  void _showAllReviews() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("All Testimonials", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Flexible(
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
                          mainAxisExtent: 160, crossAxisSpacing: 15, mainAxisSpacing: 15,
                        ),
                        itemCount: _reviews.length,
                        itemBuilder: (context, i) => _ReviewCard(review: _reviews[i], primaryAccent: widget.primaryAccent),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(right: 10, top: 10, child: IconButton(icon: const Icon(Icons.cancel, color: Colors.redAccent), onPressed: () => Navigator.pop(context))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // ৫টি কার্ড দেখা যাবে এমনভাবে ফ্র্যাকশন সেট করা
    double fraction = screenWidth > 1400 ? 0.2 : (screenWidth > 1000 ? 0.33 : (screenWidth > 600 ? 0.5 : 1.0));

    // নতুন কনফিগারেশন সহ কন্ট্রোলার
    _pageController = PageController(viewportFraction: fraction, initialPage: _currentPage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end, // বাটন ডান দিকে নেওয়ার জন্য
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20, bottom: 15),
            child: Text('Client Testimonials', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              // এখানে ইন্ট্রিনসিক হাইট কাজ করবে না PageView তে, তাই একটি অপটিমাইজড হাইট দেওয়া হয়েছে
              height: 180,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _reviews.length,
                  padEnds: false, // এটি প্রথম কার্ডকে একদম বামে রাখবে
                  onPageChanged: (i) => _currentPage = i,
                  itemBuilder: (context, i) => Padding(padding: const EdgeInsets.all(8), child: _ReviewCard(review: _reviews[i], primaryAccent: widget.primaryAccent)),
                ),
              ),
            ),
            if (screenWidth > 800) ...[
              Positioned(left: 5, child: _Arrow(icon: Icons.arrow_back_ios, onTap: () => _pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.ease))),
              Positioned(right: 5, child: _Arrow(icon: Icons.arrow_forward_ios, onTap: () => _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.ease))),
            ]
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20, top: 10),
          child: TextButton.icon(
            onPressed: _showAllReviews,
            icon: const Icon(Icons.grid_view_rounded, size: 16),
            label: const Text("View All", style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
            style: TextButton.styleFrom(foregroundColor: widget.primaryAccent),
          ),
        ),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Arrow({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), shape: BoxShape.circle),
    child: IconButton(onPressed: onTap, icon: Icon(icon, size: 18, color: Colors.black87)),
  );
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final Color primaryAccent;
  const _ReviewCard({required this.review, required this.primaryAccent});

  @override
  Widget build(BuildContext context) {
    return Align(
      // কার্ডটিকে ওপরের দিকে আটকে রাখার জন্য
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // কন্টেন্ট যতটুকু, কার্ডের হাইট ঠিক ততটুকুই হবে
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.star, color: Colors.amber, size: 12),
                Text(" ${review.rating}", style: const TextStyle(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            // এখানে Expanded এর বদলে Flexible দিন
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
            const SizedBox(height: 4), // টেক্সট এবং আইকনের মাঝে খুব সামান্য গ্যাপ
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