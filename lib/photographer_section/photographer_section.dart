import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nobochitro/photographer_section/photographer_profile_screen.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart'; // আপনার হেল্পার ফাইলের পাথ দিন

class PhotographerSection extends StatefulWidget {
  final Color primaryAccent;

  const PhotographerSection({super.key, required this.primaryAccent});

  @override
  State<PhotographerSection> createState() => _PhotographerSectionState();
}

class _PhotographerSectionState extends State<PhotographerSection> {
  late final ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  // অটো স্ক্রলিং লজিক (আপনার আগের কোড অনুযায়ী)
  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double delta = 300.0;

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
                onPressed: () {
                  // ডেমো ডাটা ইনসার্ট করার জন্য হেল্পার কল করতে পারেন (টেস্টিং এর জন্য)
                  // DatabaseHelper.insertDemoPhotographers();
                },
                child: Text(
                  'See All',
                  style: TextStyle(color: widget.primaryAccent),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 380,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            // সরাসরি সুপাবেস কল না করে হেল্পার ব্যবহার করা হয়েছে
            stream: DatabaseHelper.getPhotographerStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading data from helper"));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No photographers found"));
              }

              final photographers = snapshot.data!;

              return ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: photographers.length,
                itemBuilder: (context, index) {
                  final data = photographers[index];
                  return Container(
                    width: isMobile ? screenWidth * 0.75 : 320,
                    margin: const EdgeInsets.only(right: 16, bottom: 10),
                    child: _buildPhotographerCard(data, theme),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhotographerCard(Map<String, dynamic> data, ThemeData theme) {
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
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    data['profile_image_url'] ?? '',
                    width: double.infinity,
                    fit: BoxFit.cover, // ডিজাইনের জন্য cover রাখা ভালো
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.onSurface.withOpacity(0.05),
                        child: const Center(
                          child: Icon(Icons.person, size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                if (data['is_available'] == true)
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
                        data['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                        Text(
                          data['avg_rating']?.toString() ?? '0.0',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['specialty'] ?? 'Photography Specialist',
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotographerProfileScreen(
                            primaryAccent: widget.primaryAccent,
                            photographerData: data,
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: theme.colorScheme.onSurface.withOpacity(0.05),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
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