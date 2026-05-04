import 'package:flutter/material.dart';
import 'package:nobochitro/community_gallery/community_gallery.dart';
import 'package:nobochitro/responsive_review_list/responsive_review_list.dart';
import 'package:nobochitro/widgets/custom_appbar.dart';

class PhotographerProfileScreen extends StatelessWidget {
  final Color primaryAccent;
  const PhotographerProfileScreen({super.key, required this.primaryAccent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      // custom appbar
      appBar: buildCustomAppBar(context, primaryAccent, "Photographer Profile"),

      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SingleChildScrollView(
            // sliver appbar
            child: Column(
              children: [
                // face image profile icon style
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    // cover photo
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            "https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?fit=crop&w=1200",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -60,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: const NetworkImage(
                            "https://i.pravatar.cc/300",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 70), // প্রোফাইল পিকচারের নিচের স্পেস
                //photographer information name and designation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Alex Rivera",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified,
                            color: Colors.blue[600],
                            size: 24,
                          ),
                        ],
                      ),
                      const Text(
                        "Professional Photographer",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Divider(height: 40),

                      // ৩. বিস্তারিত তথ্য (রেসপনসিভ লেআউট)
                      screenWidth > 850
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildDetailedInfo(theme),
                                ),
                                const SizedBox(width: 40),
                                Expanded(
                                  flex: 1,
                                  child: _buildExpertiseSideBar(theme),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildDetailedInfo(theme),
                                const SizedBox(height: 30),
                                _buildExpertiseSideBar(theme),
                              ],
                            ),
                      const SizedBox(height: 15),
                      CommunityGallery(
                        primaryAccent: primaryAccent,
                        sectionTitle: "Recent Masterpiece",
                      ),
                      const SizedBox(height: 15),
                      ResponsiveReviewList(
                        primaryAccent: primaryAccent,
                        sectionTitle: "Client Say about photographer!",
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // informative build Widgets...
  Widget _buildDetailedInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Biography",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "With over a decade of experience, Alex specializes in high-fashion editorial and cinematic wedding storytelling. His work has been featured in international magazines.",
          style: TextStyle(fontSize: 15, height: 1.6),
        ),
        const SizedBox(height: 30),
        const Text(
          "Technical Arsenal",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _gearChip("Sony A1"),
            _gearChip("Nikon Z9"),
            _gearChip("35mm f/1.4"),
            _gearChip("Lightroom"),
          ],
        ),
      ],
    );
  }

  Widget _gearChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.grey.withOpacity(0.1),
    );
  }

  Widget _buildExpertiseSideBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _statRow(Icons.event_available, "450+ Projects"),
          _statRow(Icons.timer_outlined, "3-5 Days Delivery"),
          _statRow(Icons.workspace_premium, "8 Years Exp."),
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
