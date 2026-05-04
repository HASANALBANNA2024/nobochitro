import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nobochitro/hero_banner/hero_banner.dart';

class BannerData {
  final String title;
  final String subtitle;
  final String description;
  final String buttonText;
  final String imageUrl;
  final int durationSeconds;

  BannerData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.buttonText,
    required this.imageUrl,
    this.durationSeconds = 60,
  });

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      title: json['title'] ?? "EXCLUSIVE OFFER! 50% OFF",
      subtitle: json['subtitle'] ?? "Premium Portrait Sessions",
      description: json['description'] ?? "✓ High-Res Digital Photos\n✓ Pro Lighting & Retouching",
      buttonText: json['buttonText'] ?? "BOOK NOW",
      imageUrl: json['imageUrl'] ?? "https://images.pexels.com/photos/1036622/pexels-photo-1036622.jpeg",
      durationSeconds: json['durationSeconds'] ?? 60,
    );
  }
}

class N8nDynamicBanner extends StatefulWidget {
  final Color primaryAccent;
  final String? n8nApiUrl;
  final VoidCallback? onBookingClick;

  const N8nDynamicBanner({
    super.key,
    required this.primaryAccent,
    this.n8nApiUrl,
    this.onBookingClick
  });

  @override
  State<N8nDynamicBanner> createState() => _N8nDynamicBannerState();
}

class _N8nDynamicBannerState extends State<N8nDynamicBanner> with TickerProviderStateMixin {
  late BannerData _currentBanner;
  Timer? _toggleTimer;
  Timer? _countdownTimer;
  int _secondsRemaining = 60;
  bool _isCampaignActive = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _currentBanner = BannerData(
      title: "EXCLUSIVE OFFER! 50% OFF",
      subtitle: "Premium Portrait Sessions",
      description: "✓ High-Res Digital Photos\n✓ Pro Lighting & Retouching\n✓ World-class Quality",
      buttonText: "BOOK NOW",
      imageUrl: "https://images.pexels.com/photos/1036622/pexels-photo-1036622.jpeg",
    );

    _startScheduleTimer();
    _startCountdown();
    if (widget.n8nApiUrl != null) _fetchDataFromN8n();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _secondsRemaining = 60;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  void _startScheduleTimer() {
    _toggleTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _isCampaignActive = !_isCampaignActive;
          if (_isCampaignActive) _startCountdown();
        });
      }
    });
  }

  Future<void> _fetchDataFromN8n() async {
    try {
      final response = await http.get(Uri.parse(widget.n8nApiUrl!));
      if (response.statusCode == 200) {
        setState(() {
          _currentBanner = BannerData.fromJson(json.decode(response.body));
          _secondsRemaining = _currentBanner.durationSeconds;
        });
      }
    } catch (e) {
      debugPrint("n8n Error: $e");
    }
  }

  @override
  void dispose() {
    _toggleTimer?.cancel();
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCampaignActive) return HeroBanner(primaryAccent: widget.primaryAccent);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = screenWidth > 800;
    final String currentDate = DateFormat('dd MMM, EEEE').format(DateTime.now());

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: Container(
        key: const ValueKey('dynamic_banner'),
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: isWeb ? 300 : 230,
          maxHeight: isWeb ? 380 : 280,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          image: DecorationImage(
            image: NetworkImage(_currentBanner.imageUrl),
            fit: BoxFit.cover,
            alignment: Alignment.centerRight, // ছবিকে একটু ডানে রাখা হয়েছে যাতে টেক্সট ক্লিয়ার থাকে
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              // High-Contrast Gradient for clear readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.4),
                        Colors.transparent
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),

              // App Icon
              Positioned(
                top: 15,
                right: 15,
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 45,
                  height: 45,
                  errorBuilder: (c, e, s) => const Icon(Icons.star, color: Colors.amber),
                ),
              ),

              // Main Information (Centered Vertically)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center, // সবকিছু মাঝখানে রাখার জন্য
                  children: [
                    // Timer & Date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              ScaleTransition(
                                scale: _pulseController,
                                child: const Icon(Icons.circle, color: Colors.white, size: 7),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "LIVE: ${_formatTime(_secondsRemaining)}",
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          currentDate,
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Title (Bigger and Brighter)
                    Text(
                      _currentBanner.title,
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 28, // সাইজ বাড়ানো হয়েছে
                        fontWeight: FontWeight.bold, // আরও বোল্ড করা হয়েছে
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle (Clear and White)
                    Text(
                      _currentBanner.subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Information/Bullets (High Visibility)
                    Text(
                      _currentBanner.description,
                      style: const TextStyle(
                        color: Colors.white, // পিওর হোয়াইট করা হয়েছে
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20), // বাটন এবং টেক্সটের মাঝে গ্যাপ

                    // Book Now Button
                    ElevatedButton(
                      onPressed: widget.onBookingClick,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      ),
                      child: Text(
                        _currentBanner.buttonText,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}