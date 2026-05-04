import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nobochitro/photographer_section/photographer_profile_screen.dart';

class PhotographerSection extends StatefulWidget {
  final Color primaryAccent;

  const PhotographerSection({super.key, required this.primaryAccent});

  @override
  State<PhotographerSection> createState() => _PhotographerSectionState();
}

class _PhotographerSectionState extends State<PhotographerSection> {
  late final ScrollController _scrollController;
  Timer? _timer;

  final List<Map<String, String>> photographers = [
    {
      'name': 'Hasan Al Banna',
      'expert': 'Wedding Specialist',
      'image': 'https://i.pravatar.cc/300?u=1',
      'rating': '4.9',
    },
    {
      'name': 'Sabbir Ahmed',
      'expert': 'Portrait Expert',
      'image': 'https://i.pravatar.cc/300?u=2',
      'rating': '4.8',
    },
    {
      'name': 'Tanvir Hossain',
      'expert': 'Event Photographer',
      'image': 'https://i.pravatar.cc/300?u=3',
      'rating': '4.7',
    },
    {
      'name': 'Rifat Khan',
      'expert': 'Fashion & Model',
      'image': 'https://i.pravatar.cc/300?u=4',
      'rating': '5.0',
    },
    {
      'name': 'Mehedi Hasan',
      'expert': 'Cinematographer',
      'image': 'https://i.pravatar.cc/300?u=5',
      'rating': '4.9',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // ওয়েবে অটো-স্ক্রলিং লজিক (স্মুথ ফ্লো)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double delta = 300.0; // প্রতি ৩ সেকেন্ডে কতটুকু স্ক্রল হবে

        if (currentScroll >= maxScroll) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.animateTo(
            currentScroll + delta,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meet Our Experts',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See All',
                  style: TextStyle(color: widget.primaryAccent),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 350,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: photographers.length,
            itemBuilder: (context, index) {
              return Container(
                width: isMobile ? screenWidth * 0.75 : 320,
                margin: const EdgeInsets.only(right: 16, bottom: 10),
                child: _buildPhotographerCard(photographers[index], theme),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhotographerCard(Map<String, String> data, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ইমেজ সেকশন উইথ এরর হ্যান্ডলিং
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    data['image']!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // ইমেজ লোড না হলে এই আইকন বা কালার দেখাবে (CORS সমস্যা সমাধানে সহায়ক)
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.onSurface.withOpacity(0.05),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: widget.primaryAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        Text(
                          data['rating']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['expert']!,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      // call to profile section
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotographerProfileScreen(
                            primaryAccent: Color(
                              0xFF6200EE,
                            ), // এখানে আপনার অ্যাপের মেইন কালারটি দিন
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: theme.colorScheme.onSurface.withOpacity(
                        0.05,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
