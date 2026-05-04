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
  @override
  Widget build(BuildContext context) {
    if (!_isCampaignActive) return HeroBanner(primaryAccent: widget.primaryAccent);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = screenWidth > 600; // সাধারণত ৬০০ এর বেশি হলে আমরা ওয়েব/ট্যাবলেট ধরি
    final String currentDate = DateFormat('dd MMM, EEEE').format(DateTime.now());

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: Container(
        key: const ValueKey('dynamic_banner'),
        width: double.infinity,
        // আপনার HeroBanner এর হাইট লজিক এখানে হুবহু বসানো হয়েছে
        constraints: BoxConstraints(
          minHeight: isWeb ? 280 : 200,
          maxHeight: isWeb ? 350 : 250,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(_currentBanner.imageUrl),
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
                        Colors.black.withOpacity(0.85),
                        Colors.black.withOpacity(0.3),
                        Colors.transparent
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),

              // Main Content Area
              Padding(
                padding: EdgeInsets.all(isWeb ? 25.0 : 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center, // কন্টেন্ট মাঝখানে রাখার জন্য
                  children: [
                    // Timer & Date Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            children: [
                              ScaleTransition(
                                scale: _pulseController,
                                child: const Icon(Icons.circle, color: Colors.white, size: 5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "LIVE: ${_formatTime(_secondsRemaining)}",
                                style: TextStyle(color: Colors.white, fontSize: isWeb ? 11 : 9, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                            currentDate,
                            style: TextStyle(color: Colors.white70, fontSize: isWeb ? 11 : 9)
                        ),
                      ],
                    ),

                    const Spacer(), // অটোমেটিক ব্যালেন্সড স্পেসিং

                    // Title - ওয়েব এবং মোবাইলের জন্য আলাদা সাইজ
                    Text(
                      _currentBanner.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFFFD700),
                        fontSize: isWeb ? 30 : 20, // মোবাইলে ২০, ওয়েবে ৩০
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),

                    // Subtitle
                    Text(
                      _currentBanner.subtitle,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isWeb ? 18 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Description - মোবাইল ভিউতে টেক্সট ছোট করা হয়েছে
                    SizedBox(
                      width: isWeb ? screenWidth * 0.4 : screenWidth * 0.55,
                      child: Text(
                        _currentBanner.description,
                        maxLines: 3,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isWeb ? 14 : 10,
                          height: 1.3,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Button
                    SizedBox(
                      height: isWeb ? 40 : 32,
                      child: ElevatedButton(
                        onPressed: widget.onBookingClick,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: isWeb ? 30 : 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          _currentBanner.buttonText,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWeb ? 13 : 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // App Icon (এটি Stack এর সবার নিচে থাকবে যাতে অন্য কিছুর নিচে চাপা না পড়ে)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(4), // আইকনের চারপাশে হালকা প্যাডিং
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2), // আইকনটি হাইলাইট করার জন্য হালকা ব্যাকগ্রাউন্ড
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: isWeb ? 40 : 28, // মোবাইল ভিউতে ছোট রাখা হয়েছে
                    height: isWeb ? 40 : 28,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => Icon(
                      Icons.auto_awesome,
                      color: const Color(0xFFFFD700), // গোল্ডেন কালার
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