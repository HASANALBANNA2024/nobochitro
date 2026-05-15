import 'dart:async';

import 'package:flutter/material.dart';

import '../photography_package/package_details_screen.dart';

class PackageCard extends StatefulWidget {
  final Map<String, dynamic> pkg;
  final bool isDark;
  final Color accent;
  const PackageCard({
    required this.pkg,
    required this.isDark,
    required this.accent,
  });

  @override
  State<PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<PackageCard> {
  int _imgIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // এখানে স্লাইড হবে। যদি ডাটাবেসে মাল্টিপল ইমেজ থাকতো তবে ভালো হতো।
    // আপাতত একটি ইমেজই ফেইড এফেক্ট দিবে অথবা আপনি চাইলে ওই ক্যাটাগরির অন্য ইমেজ রেন্ডমলি দেখাতে পারেন।
    _timer = Timer.periodic(const Duration(seconds: 3), (t) {
      if (mounted) setState(() => _imgIndex++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final features = (widget.pkg['features'] as String).split(',');

    return Container(
      width: 350, // Responsive layout অনুযায়ী width এডজাস্ট হবে
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        children: [
          // ইমেজ স্লাইডার/লুপ
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Image.network(
              widget.pkg['image_url'], // এখানে রিয়েল লুপ লজিক বসবে
              key: ValueKey<int>(_imgIndex),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.pkg['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "৳${widget.pkg['base_price']}",
                      style: TextStyle(
                        color: widget.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, // পাশাপাশি গ্যাপ (Horizontal gap)
                  runSpacing:
                      8, // দুই লাইনের মাঝখানের গ্যাপ (Vertical gap) - এটাকে পজিটিভ ভ্যালু দিন
                  children: features
                      .take(3)
                      .map(
                        (f) => Chip(
                          label: Text(
                            f.trim(),
                            style: TextStyle(
                              fontSize: 10,
                              color: widget.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: widget.accent.withOpacity(0.1),
                          side: BorderSide.none,
                          // নিচের এই প্রপার্টিগুলো চিপের এক্সট্রা জায়গা রিমুভ করবে যাতে আপনি গ্যাপ নিয়ন্ত্রণ করতে পারেন
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: const VisualDensity(
                            horizontal: -4,
                            vertical: -4,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PackageDetailsScreen(
                          primaryAccent: widget.accent,
                          packageData: widget.pkg,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accent,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text(
                    "View Details & Book",
                    style: TextStyle(color: Colors.white),
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
