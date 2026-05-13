import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nobochitro/booking_summary_screen/my_booking_screen.dart';
import 'package:nobochitro/widgets/custom_appbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientProfileScreen extends StatefulWidget {
  final Color? primaryAccent;
  final int? selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final Function(bool)? onThemeChanged;
  final VoidCallback? onSettingsPressed;

  const ClientProfileScreen({
    super.key,
    this.primaryAccent,
    this.selectedIndex,
    this.onDestinationSelected,
    this.onThemeChanged,
    this.onSettingsPressed,
  });

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  // Database state variables
  Map<String, dynamic>? userData;
  bool _isLoadingData = true;

  // Placeholder static data (can be replaced with DB fields later)
  final int _bookings = 24;
  final bool _isVerified = true;

  @override
  void initState() {
    super.initState();
    // Fetch real-time data from Supabase when the screen initializes
    _loadRealUserData();
  }
// Fetching user data from Supabase
  Future<void> _loadRealUserData() async {
   try{
     final String? firebaseuserid = FirebaseAuth.instance.currentUser?.uid;
     print("FirebaseUID $firebaseuserid");
     if(firebaseuserid != null)
     {
       final data = await Supabase.instance.client
           .from('users')
           .select()
           .eq('user_id', firebaseuserid)
           .maybeSingle();
       print("Log: supabase Data ::: $data ::");
       if(mounted)
       {
         setState(() {
           userData = data;
           _isLoadingData = false;
         });
       }
       else
       {
         print("NO user Logged in firebase");
         if(mounted) {
           setState(() {
             _isLoadingData = false;
           });
         }
       }

     }



   }catch (e)
    {
      debugPrint("LOG: Error fetching from Supabase -> $e");
      if (mounted) setState(() => _isLoadingData = false);
    }

  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 800;

    // Color Palette
    final Color background = isDark ? const Color(0xFF131313) : Colors.white;
    final Color surface = isDark ? const Color(0xFF1E1E1E) : Colors.grey[100]!;
    final Color goldColor = const Color(0xFFD4AF37);
    final Color tealColor = const Color(0xFF008080);

    return Scaffold(
      backgroundColor: background,
      appBar: buildCustomAppBar(context, goldColor, "Profile"),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator()) // Loading indicator
          : SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isWeb ? 1100 : screenWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // --- Header Section (Real Data) ---
                  _buildHeader(goldColor, tealColor, isDark),
                  const SizedBox(height: 10),

                  // --- Status Bar ---
                  _buildStatusBar(surface, tealColor, isWeb),
                  const SizedBox(height: 10),

                  // --- Responsive Menu Wrapper ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        _buildSingleMenu(
                          isWeb: isWeb,
                          screenWidth: screenWidth,
                          icon: Icons.person_outline,
                          title: "Profile Settings",
                          titleBn: "প্রোফাইল সেটিংস",
                          sub: "Update your personal info",
                          surface: surface,
                          tealColor: tealColor,
                          onTap: () => print("Navigate to Settings"),
                        ),
                        _buildSingleMenu(
                          isWeb: isWeb,
                          screenWidth: screenWidth,
                          icon: Icons.event_available,
                          title: "My Bookings",
                          titleBn: "আমার বুকিং",
                          sub: "Check your schedule",
                          surface: surface,
                          tealColor: tealColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MyBookingScreen(
                                  primaryAccent: widget.primaryAccent ?? goldColor,
                                  selectedIndex: widget.selectedIndex ?? 0,
                                  onDestinationSelected: widget.onDestinationSelected ?? (i) {},
                                  onThemeChanged: widget.onThemeChanged ?? (v) {},
                                  onSettingsPressed: widget.onSettingsPressed ?? () {},
                                ),
                              ),
                            );
                          },
                        ),
                        _buildSingleMenu(
                          isWeb: isWeb,
                          screenWidth: screenWidth,
                          icon: Icons.star_outline_rounded,
                          title: "My Reviews",
                          titleBn: "আমার রিভিউ",
                          sub: "See your feedback",
                          surface: surface,
                          tealColor: tealColor,
                          onTap: () => print("Navigate to Reviews"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- Action Buttons ---
                  _buildActionButtons(goldColor, surface, isDark),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // build info profile
  Widget _buildHeader(Color gold, Color teal, bool isDark)
  {
    // Database Mapping
    String nameEn = userData?['full_name'] ?? "User Name";
    String email = userData?['email'] ?? "No Email Found";
    String phone = userData?['phone_number'] ?? "No Phone Number";
    String profileImg = userData?['profile_image'] ?? "";
    String customId = userData?['id'] ?? "N-000000";

    // Formatted date logic stays same
    String joinedDate = "Joined: ...";
    if (userData?['created_at'] != null) {
      DateTime dt = DateTime.parse(userData!['created_at']);
      joinedDate = "Joined: ${DateFormat('MMM d, yyyy').format(dt)}";
    }

    return Column(
      mainAxisSize: MainAxisSize.min, // Prevents taking unnecessary vertical space
      children: [
        // Profile Image Section - Optimized radius
        CircleAvatar(
          radius: 55, // Reduced size to save space
          backgroundColor: gold,
          child: CircleAvatar(
            radius: 52,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            backgroundImage: profileImg.isNotEmpty ? NetworkImage(profileImg) : null,
            child: profileImg.isEmpty ? Icon(Icons.person, size: 55, color: gold) : null,
          ),
        ),
        const SizedBox(height: 5),
        // User Identity Details
        Text(
          nameEn,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: gold),
        ),
        const SizedBox(height: 2),
        Text(
          "Customer ID: $customId",
          style: const TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 0.5),
        ),
        const SizedBox(height: 2),

        // Contact Information - Using Padding to avoid overflow
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              _buildContactInfo(Icons.phone_android_rounded, phone, isDark),
              const SizedBox(height: 2),
              _buildContactInfo(Icons.email_outlined, email, isDark),
              const SizedBox(height: 2),
              _buildContactInfo(
                  Icons.location_on_outlined,
                  userData?['address'] ?? "Location not updated",
                  isDark
              ),
            ],
          ),
        ),

        const SizedBox(height: 2),
        Text(
          joinedDate,
          style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
        ),
      ],
    );


  }


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

  // Booking and Verification status bar
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

  // Generic menu card for Profile, Bookings, Reviews
  Widget _buildSingleMenu({
    required bool isWeb,
    required double screenWidth,
    required IconData icon,
    required String title,
    required String titleBn,
    required String sub,
    required Color surface,
    required Color tealColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: isWeb ? (screenWidth > 1100 ? (1100 / 2) - 24 : (screenWidth / 2) - 24) : screenWidth,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: tealColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: tealColor, size: 24),
          ),
          title: Text("$title ($titleBn)", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }

  // Profile Edit and Customer Support buttons
  Widget _buildActionButtons(Color gold, Color surface, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () => print("Edit Profile Tapped"),
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
              height: 50,
              child: OutlinedButton(
                onPressed: () => print("Support Tapped"),
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