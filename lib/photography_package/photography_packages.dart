import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nobochitro/booking_summary_screen/booking_summary_screen.dart';
import 'package:nobochitro/photography_package/package_details_screen.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class PhotographyPackages extends StatefulWidget {
  final Color primaryAccent;

  const PhotographyPackages({super.key, required this.primaryAccent});

  @override
  State<PhotographyPackages> createState() => _PhotographyPackagesState();
}

class _PhotographyPackagesState extends State<PhotographyPackages> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  // রিয়েল ডেটা রাখার জন্য লিস্ট
  List<Map<String, dynamic>> packages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // ইনিশিয়াল কন্ট্রোলার ভিউপোর্ট ফ্র্যাকশন সেট করা
    _pageController = PageController(viewportFraction: 0.8, initialPage: 0);
    _loadPackages();
  }

  // ডেটাবেস থেকে প্যাকেজ নিয়ে আসা
  Future<void> _loadPackages() async {
    try {
      // DatabaseHelper এর মেথড কল করা (নিশ্চিত করুন এই মেথডটি আপনার হেল্পার ফাইলে আছে)
      final data = await DatabaseHelper.instance.getPackages();
      if (mounted) {
        setState(() {
          packages = data;
          isLoading = false;
        });
        _startAutoScroll();
      }
    } catch (e) {
      debugPrint("Error loading packages: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _startAutoScroll() {
    if (packages.isEmpty) return;
    _autoScrollTimer?.cancel();
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

    // রেসপনসিভ ভিউপোর্ট সেটআপ
    double fraction = screenWidth > 1200 ? 0.35 : (screenWidth > 800 ? 0.55 : 0.8);

    // স্ক্রিন সাইজ চেঞ্জ হলে কন্ট্রোলার আপডেট করা
    if (_pageController.viewportFraction != fraction) {
      final oldPage = _currentPage;
      _pageController.dispose();
      _pageController = PageController(
        viewportFraction: fraction,
        initialPage: oldPage,
      );
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
                onPressed: () {
                  // View All লজিক এখানে দিতে পারেন
                },
                child: Text('View All', style: TextStyle(color: widget.primaryAccent)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 380,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : packages.isEmpty
              ? const Center(child: Text("No packages available"))
              : PageView.builder(
            controller: _pageController,
            itemCount: packages.length,
            padEnds: false,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) => _currentPage = index,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.hasContentDimensions) {
                    value = (_pageController.page ?? 0) - index;
                    value = (1 - (value.abs() * 0.06)).clamp(0.0, 1.0);
                  }
                  return Center(child: Transform.scale(scale: value, child: child));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: _buildPackageCard(
                    context,
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

  Widget _buildPackageCard(
      BuildContext context,
      Map<String, dynamic> package,
      ColorScheme colorScheme,
      TextTheme textTheme,
      Color primaryAccent,
      ) {
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PackageDetailsScreen(
                primaryAccent: primaryAccent,
                packageData: package,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Image.network(
                package['image_url'] ?? "https://via.placeholder.com/400",
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image, size: 50)),
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
                      package['title'] ?? "No Title",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          package['features'] ?? "No features listed.",
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
                          "৳${package['base_price']}",
                          style: TextStyle(
                            color: primaryAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PackageDetailsScreen(
                                  primaryAccent: primaryAccent,
                                  packageData: package,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Book'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}