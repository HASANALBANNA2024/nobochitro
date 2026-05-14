import 'package:flutter/material.dart';
import 'package:nobochitro/community_gallery/community_gallery.dart';
import 'package:nobochitro/responsive_review_list/responsive_review_list.dart';
import 'package:nobochitro/widgets/custom_appbar.dart';

class PhotographerProfileScreen extends StatelessWidget {
  final Color primaryAccent;
  final Map<String, dynamic> photographerData; // Data Receive

  const PhotographerProfileScreen({
    super.key,
    required this.primaryAccent,
    required this.photographerData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: buildCustomAppBar(context, primaryAccent, "Photographer Profile"),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // কভার এবং প্রোফাইল ইমেজ
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            photographerData['banner_image_url'] ??
                                "https://via.placeholder.com/1200x250",
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
                          backgroundImage: NetworkImage(
                            photographerData['profile_image_url'] ?? "",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            photographerData['name'] ?? "User",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (photographerData['is_available'] == true)
                            Icon(
                              Icons.verified,
                              color: Colors.blue[600],
                              size: 24,
                            ),
                        ],
                      ),
                      Text(
                        photographerData['specialty'] ?? "Photographer",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Divider(height: 40),

                      // লেআউট লজিক
                      screenWidth > 850
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildDetailedInfo(photographerData),
                                ),
                                const SizedBox(width: 40),
                                Expanded(
                                  flex: 1,
                                  child: _buildExpertiseSideBar(
                                    photographerData,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildDetailedInfo(photographerData),
                                const SizedBox(height: 30),
                                _buildExpertiseSideBar(photographerData),
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
                        sectionTitle: "Client Reviews",
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

  Widget _buildDetailedInfo(Map<String, dynamic> data) {
    // Technical Arsenal স্ট্রিংকে লিস্টে রূপান্তর
    List<String> gearList = (data['technical_arsenal'] ?? "").toString().split(
      ',',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Biography",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          data['bio'] ?? "No bio available.",
          style: const TextStyle(fontSize: 15, height: 1.6),
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
          children: gearList
              .where((gear) => gear.trim().isNotEmpty)
              .map((gear) => _gearChip(gear.trim()))
              .toList(),
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

  Widget _buildExpertiseSideBar(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _statRow(
            Icons.event_available,
            "${data['projects_completed'] ?? '0'} Projects",
          ),
          _statRow(
            Icons.timer_outlined,
            "${data['delivery_time'] ?? 'N/A'} Delivery",
          ),
          _statRow(
            Icons.workspace_premium,
            "${data['experience_years'] ?? '0'} Years Exp.",
          ),
          _statRow(Icons.location_on, data['location'] ?? "Not Specified"),
          _statRow(
            Icons.monetization_on,
            "৳${data['per_hours_fee'] ?? '0'} / hr",
          ),
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
