import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nobochitro/widgets/custom_appbar.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final String _nameEn = "Hasan Ali";
  final String _nameBn = "(হাসান আলী)";
  final DateTime _joinedDate = DateTime(2023, 10, 12);
  final int _bookings = 24;
  final bool _isVerified = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 800;

    // Color Plate
    final Color background = isDark ? const Color(0xFF131313) : Colors.white;
    final Color surface = isDark ? const Color(0xFF1E1E1E) : Colors.grey[100]!;
    final Color goldColor = const Color(0xFFD4AF37);
    final Color tealColor = const Color(0xFF008080);

    // Dummy Data list
    final List<Map<String, dynamic>> menuItems = [
      {"icon": Icons.person_outline, "title": "Profile Settings", "bn": "প্রোফাইল সেটিংস", "sub": "Update your personal info"},
      {"icon": Icons.event_available, "title": "My Bookings", "bn": "আমার বুকিং", "sub": "Check your schedule"},
      {"icon": Icons.grid_view_rounded, "title": "Packages", "bn": "প্যাকেজ সমূহ", "sub": "View chosen plans"},
      {"icon": Icons.account_balance_wallet_outlined, "title": "Payments", "bn": "পেমেন্ট পদ্ধতি", "sub": "Manage billing details"},
      {"icon": Icons.star_outline_rounded, "title": "My Reviews", "bn": "আমার রিভিউ", "sub": "See your feedback"},
      {"icon": Icons.notifications_none_rounded, "title": "Notifications", "bn": "নোটিফিকেশন", "sub": "Stay updated"},
    ];

    return Scaffold(
      backgroundColor: background,
      appBar: buildCustomAppBar(context, goldColor, "Profile"),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isWeb ? 1100 : screenWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // --- Header Section  ---
                  _buildHeader(goldColor, tealColor, isDark),

                  const SizedBox(height: 32),

                  // --- Status Bar ---
                  _buildStatusBar(surface, tealColor, isWeb),

                  const SizedBox(height: 32),

                  // --- Responsive Menu Grid ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true, // ScrollView use
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: menuItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWeb ? 2 : 1, // web 2 and mobile 1
                        mainAxisExtent: 90, // Card Height
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        return _buildMenuCard(menuItems[index], surface, tealColor, isDark);
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- action button in same row ---
                  _buildActionButtons(goldColor, surface, isDark),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // logo and profile picture
  Widget _buildHeader(Color gold, Color teal, bool isDark) {
    return Column(
      children: [
        // লোগো সেকশন
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, color: gold, size: 28),
            const SizedBox(width: 10),
            Text("Nobochitro - নবচিত্র",
                style: TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        const SizedBox(height: 30),

        // প্রোফাইল ইমেজ
        CircleAvatar(
          radius: 68,
          backgroundColor: gold,
          child: CircleAvatar(
            radius: 65,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: Icon(Icons.person, size: 70, color: gold),
          ),
        ),
        const SizedBox(height: 16),

        // নাম ও জয়েনিং ডেট
        Text(_nameEn, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: gold)),
        Text(_nameBn, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 12),

        // --- নতুন কন্টাক্ট ডিটেইলস সেকশন ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _buildContactInfo(Icons.phone_android_rounded, "+880 17XX-XXXXXX", isDark),
              const SizedBox(height: 6),
              _buildContactInfo(Icons.email_outlined, "hasan.ali@example.com", isDark),
              const SizedBox(height: 6),
              _buildContactInfo(Icons.location_on_outlined, "Mirpur, Dhaka, Bangladesh", isDark),
            ],
          ),
        ),

        const SizedBox(height: 12),
        Text("Joined: ${DateFormat('MMM d, yyyy').format(_joinedDate)}",
            style: const TextStyle(color: Colors.grey, fontSize: 12)
        ),
      ],
    );
  }


  // build header
  Widget _buildContactInfo(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // status bar widget
  Widget _buildStatusBar(Color surface, Color teal, bool isWeb) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statusItem(Icons.calendar_today, "Bookings: $_bookings", teal),
          Container(width: 1, height: 20, color: Colors.grey.withOpacity(0.3)),
          _statusItem(Icons.verified_user_outlined, "Verified: ${_isVerified ? 'Yes' : 'No'}", teal),
        ],
      ),
    );
  }

  Widget _statusItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // information  menu card
  Widget _buildMenuCard(Map<String, dynamic> item, Color surface, Color teal, bool isDark) {
    return Container(
      alignment: Alignment.center, // কন্টেইনারের ভেতরের সবকিছু সেন্টারে রাখার জন্য
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        // নিচের প্রপার্টিগুলো টেক্সট সেন্টারে আনতে সাহায্য করবে
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        visualDensity: const VisualDensity(vertical: -4), // অতিরিক্ত ফাঁকা জায়গা কমাবে
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)
          ),
          child: Icon(item['icon'], color: teal, size: 24),
        ),
        title: Text(
            "${item['title']} (${item['bn']})",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)
        ),
        subtitle: Text(
            item['sub'],
            style: const TextStyle(fontSize: 11, color: Colors.grey)
        ),
        trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  // action button edit profile and support
  Widget _buildActionButtons(Color gold, Color surface, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50, // এখানে উচ্চতা সেট করা হয়েছে
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: const Text("EDIT PROFILE", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 50, // এখানেও সমান উচ্চতা সেট করা হয়েছে
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: surface,
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  side: const BorderSide(color: Colors.white10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.headset_mic_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }
}