import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nobochitro/utilities/package_standard.dart';

import '../photography_package/package_details_screen.dart';

class PackageCard extends StatefulWidget {
  final Map<String, dynamic> pkg;
  final bool isDark;
  final Color accent;

  const PackageCard({
    super.key,
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
    /// list convert of features
    final List<String> features = (widget.pkg['features'] as String? ?? "")
        .split(',');

    final String badgeLabel = PackageStandard.getBadgeLabel(
      widget.pkg['base_price'],
    );
    final Color badgeColor = PackageStandard.getBadgeColor(badgeLabel);

    return Container(
      width: 320,
      height: 380,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: widget.isDark ? Colors.white10 : Colors.black12,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          /// image and badge
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _buildImage(widget.pkg['image_url']),
                ),

                /// corner of top badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      badgeLabel,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// title feature and button
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.pkg['title'] ?? "No Title",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        "৳${widget.pkg['base_price']}",
                        style: TextStyle(
                          color: widget.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  /// features area
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: features
                            .take(4)
                            .map((f) => _buildChip(f.trim()))
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  // বুক বাটন
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
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "View Details & Book",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        width: double.infinity,
        color: Colors.grey[900],
        child: const Icon(
          Icons.camera_alt_outlined,
          color: Colors.white24,
          size: 40,
        ),
      );
    }
    return Image.network(
      url,
      key: ValueKey<int>(_imgIndex),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => Container(
        width: double.infinity,
        color: Colors.grey[900],
        child: const Icon(
          Icons.broken_image_outlined,
          color: Colors.white24,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: widget.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.accent.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: widget.isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }
}
