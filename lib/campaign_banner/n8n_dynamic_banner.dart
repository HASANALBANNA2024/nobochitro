import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:nobochitro/hero_banner/hero_banner.dart';

class BannerData {
  final String title;
  final String subtitle;
  final String description;
  final String buttonText;
  final String imageUrl;
  final DateTime? endDate;

  BannerData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.buttonText,
    required this.imageUrl,
    this.endDate,
  });

  // Supabase থেকে আসা ডেটা ম্যাপ করার জন্য
  factory BannerData.fromSupabase(Map<String, dynamic> json) {
    return BannerData(
      title: json['title'] ?? "EXCLUSIVE OFFER!",
      subtitle:
          "${json['discount_pct'] ?? 0}% OFF - ${json['targeted_category'] ?? 'Premium'}",
      description: "✓ High-Res Digital Photos\n✓ Pro Lighting & Retouching",
      buttonText: "BOOK NOW",
      imageUrl:
          json['banner_url'] ??
          "https://images.pexels.com/photos/1036622/pexels-photo-1036622.jpeg",
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
    );
  }
}

class SupabaseDynamicBanner extends StatefulWidget {
  final Color primaryAccent;
  final VoidCallback? onBookingClick;

  const SupabaseDynamicBanner({
    super.key,
    required this.primaryAccent,
    this.onBookingClick,
  });

  @override
  State<SupabaseDynamicBanner> createState() => _SupabaseDynamicBannerState();
}

class _SupabaseDynamicBannerState extends State<SupabaseDynamicBanner>
    with TickerProviderStateMixin {
  BannerData? _currentBanner;
  Timer? _countdownTimer;
  int _secondsRemaining = 0;
  bool _isLoading = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _fetchDataFromSupabase();
  }

  Future<void> _fetchDataFromSupabase() async {
    final campaignData = await DatabaseHelper.instance.getActiveCampaign();

    if (campaignData != null && mounted) {
      setState(() {
        _currentBanner = BannerData.fromSupabase(campaignData);
        _isLoading = false;

        // End Date অনুযায়ী টাইমার সেট করা
        if (_currentBanner!.endDate != null) {
          _secondsRemaining = _currentBanner!.endDate!
              .difference(DateTime.now())
              .inSeconds;
          if (_secondsRemaining > 0) _startCountdown();
        }
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return "00:00:00";
    int hours = seconds ~/ 3600;
    int mins = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    // ডেটা না পেলে বা ক্যাম্পেইন না থাকলে আগের HeroBanner দেখাবে
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_currentBanner == null)
      return HeroBanner(primaryAccent: widget.primaryAccent);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = screenWidth > 600;
    final String currentDate = DateFormat(
      'dd MMM, EEEE',
    ).format(DateTime.now());

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: Container(
        key: const ValueKey('supabase_dynamic_banner'),
        width: double.infinity,
        // ওভারফ্লো এড়াতে maxHeight বাদ দিয়ে শুধু minHeight রাখা হয়েছে
        constraints: BoxConstraints(minHeight: isWeb ? 280 : 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(_currentBanner!.imageUrl),
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Dark Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),

              // Main Content Area - ফ্লেক্সিবল করার জন্য Padding + Column ব্যবহার
              Padding(
                padding: EdgeInsets.all(isWeb ? 25.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // ওভারফ্লো রোধ করবে
                  children: [
                    // Timer & Date Row
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ScaleTransition(
                                scale: _pulseController,
                                child: const Icon(
                                  Icons.circle,
                                  color: Colors.white,
                                  size: 8,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "ENDS IN: ${_formatTime(_secondsRemaining)}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isWeb ? 12 : 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currentDate,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isWeb ? 12 : 10,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      _currentBanner!.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFFFD700),
                        fontSize: isWeb ? 28 : 22,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      _currentBanner!.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isWeb ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description
                    SizedBox(
                      width: isWeb ? screenWidth * 0.5 : screenWidth * 0.65,
                      child: Text(
                        _currentBanner!.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isWeb ? 14 : 12,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Button
                    SizedBox(
                      height: isWeb ? 45 : 36,
                      child: ElevatedButton(
                        onPressed: widget.onBookingClick,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: isWeb ? 30 : 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _currentBanner!.buttonText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isWeb ? 14 : 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // App Icon
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: isWeb ? 45 : 30,
                    height: isWeb ? 45 : 30,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => Icon(
                      Icons.auto_awesome,
                      color: const Color(0xFFFFD700),
                      size: isWeb ? 30 : 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
