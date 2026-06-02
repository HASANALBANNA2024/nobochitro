import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:nobochitro/categories_grid/package_card.dart';

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
  List<Map<String, dynamic>> packages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    /// initial controller
    _pageController = PageController(viewportFraction: 0.85, initialPage: 0);
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      final data = await DatabaseHelper.instance.getPackages();
      if (mounted) {
        setState(() {
          packages = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
        _startAutoScroll();
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _startAutoScroll() {
    if (packages.isEmpty) return;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients && packages.isNotEmpty) {
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
    final isDark = theme.brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;

    /// ---- responsive fraction logic -------
    double fraction = screenWidth > 1200
        ? 0.33
        : (screenWidth > 700 ? 0.55 : 0.85);

    if (_pageController.viewportFraction != fraction) {
      final oldPage = _currentPage;
      _pageController.dispose();
      _pageController = PageController(
        viewportFraction: fraction,
        initialPage: (oldPage < packages.length) ? oldPage : 0,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(theme),
        const SizedBox(height: 10),
        SizedBox(
          height: 400,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : packages.isEmpty
              ? const Center(child: Text("No packages available"))
              : PageView.builder(
                  controller: _pageController,
                  itemCount: packages.length,
                  padEnds: false, // বাম থেকে শুরু হবে
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) => _currentPage = index,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 10),
                      child: PackageCard(
                        pkg: packages[index],
                        isDark: isDark,
                        accent: widget.primaryAccent,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Exclusive Packages',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'View All',
              style: TextStyle(
                color: widget.primaryAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
