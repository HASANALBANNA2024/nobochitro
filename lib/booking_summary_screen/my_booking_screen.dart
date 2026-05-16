import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:nobochitro/responsive_review_list/_review_sheet_widget.dart';
import 'package:nobochitro/widgets/custom_appbar.dart';
import 'package:nobochitro/widgets/custom_bottom_nav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyBookingScreen extends StatefulWidget {
  final Color primaryAccent;
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final Function(bool) onThemeChanged;
  final VoidCallback onSettingsPressed;

  const MyBookingScreen({
    super.key,
    required this.primaryAccent,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onThemeChanged,
    required this.onSettingsPressed,
  });

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  Future<List<Map<String, dynamic>>>? _bookingsFuture;
  String dynamicNsrId = "NSR-LOADING...";
  bool _isLoadingUser = true;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchSupabaseUserData();
  }

  Future<void> _fetchSupabaseUserData() async {
    try {
      final String? nsrId = await DatabaseHelper.instance.getCurrentUserNsrId();
      if (nsrId != null) {
        setState(() {
          dynamicNsrId = nsrId;
          _isLoadingUser = false;
          _bookingsFuture = DatabaseHelper.instance.getUserBookings(dynamicNsrId);
        });
      } else {
        setState(() {
          dynamicNsrId = "NSR-NOT-FOUND";
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        dynamicNsrId = "NSR-ERROR";
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = screenWidth > 800;
    final currentFirebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: buildCustomAppBar(context, widget.primaryAccent, "My Bookings"),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: currentFirebaseUser == null
                    ? const Center(child: Text("Please log in to see your bookings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))
                    : _isLoadingUser
                    ? Center(child: CircularProgressIndicator(color: widget.primaryAccent))
                    : dynamicNsrId == "NSR-NOT-FOUND" || dynamicNsrId == "NSR-ERROR"
                    ? const Center(child: Text("Failed to load user profile context.", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)))
                    : FutureBuilder<List<Map<String, dynamic>>>(
                  future: _bookingsFuture,
                  builder: (context, snapshot) {
                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // 📊 🎯 ১. আপডেট পার্ট: গ্ল্যান্স কার্ড এখন সরাসরি নিচের স্ট্যাটাস বার ও ডেটাবেজ মেইনটেইন করবে
                        SliverToBoxAdapter(
                          child: _buildVisualGlanceSection(
                            snapshot: snapshot,
                            isDark: isDark,
                            isWeb: isWeb,
                          ),
                        ),

                        SliverToBoxAdapter(child: _buildTabButtons(isDark)),

                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          sliver: const SliverToBoxAdapter(
                            child: Text(
                              "🏁 MY BOOKING TIMELINE",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Colors.grey),
                            ),
                          ),
                        ),
                        _selectedTabIndex == 0
                            ? _buildActiveGridContent(snapshot, isDark, theme, isWeb)
                            : _buildNonFunctionalGridContent(isDark, theme, isWeb),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isWeb ? CustomBottomNav(currentIndex: widget.selectedIndex, onTap: widget.onDestinationSelected) : null,
    );
  }

  // 🎯 ২. গ্ল্যান্স সেকশন মেইনটেইনার উইজেট যা ডেটাবেজের রিয়েল `booking_status` থেকে কাউন্ট ফিল্টার করবে
  Widget _buildVisualGlanceSection({
    required AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
    required bool isDark,
    required bool isWeb
  }) {
    if (!snapshot.hasData || snapshot.data == null) {
      return _buildVisualGlanceRow(isDark, 0, 0, 0, isWeb);
    }

    final List<Map<String, dynamic>> databaseBookings = snapshot.data!;

    int totalCount = databaseBookings.length;
    int upcomingCount = 0;
    int completedCount = 0;

    // 🎯 লুপ চালিয়ে booking_status এর রিয়েল ডেটা কাউন্ট করা হচ্ছে (Handover/Delivered/Completed হলে কমপ্লিট হবে)
    for (var booking in databaseBookings) {
      String bookingStatus = (booking['booking_status'] ?? 'pending').toString().trim().toLowerCase();

      if (bookingStatus == 'completed' || bookingStatus == 'delivered' || bookingStatus == 'handover') {
        completedCount++;
      } else if (bookingStatus != 'cancelled') {
        upcomingCount++;
      }
    }

    // আপনার অরিজিনাল উইজেটে রিয়েল ডেটা রিটার্ন করা হচ্ছে
    return _buildVisualGlanceRow(isDark, totalCount, upcomingCount, completedCount, isWeb);
  }

  // 🎯 ৩. আপনার মূল ফাংশন (UI এবং লজিক ১০০% অপরিবর্তিত)
  Widget _buildVisualGlanceRow(bool isDark, int total, int upcoming, int completed, bool isWeb) {
    final List<Widget> cards = [
      _glanceCard("Total Bookings", "$total", Icons.grid_view_rounded, Colors.blue, isDark, isWeb),
      _glanceCard("Upcoming", "$upcoming", Icons.hourglass_top_rounded, Colors.orange, isDark, isWeb),
      _glanceCard("Completed", "$completed", Icons.check_circle_rounded, Colors.green, isDark, isWeb),
    ];

    if (isWeb) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: cards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: card))).toList(),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: cards),
    );
  }

  Widget _glanceCard(String title, String count, IconData icon, Color color, bool isDark, bool isWeb) {
    return Container(
      width: isWeb ? null : 160,
      margin: isWeb ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundColor: color.withOpacity(0.15), child: Icon(icon, size: 18, color: color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons(bool isDark) {
    List<String> tabs = ["ACTIVE & UPCOMING", "CANCELLED & REFUNDS", "SUSPENDED"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(tabs.length, (index) {
            bool isSelected = _selectedTabIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? widget.primaryAccent : (isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : (isDark ? Colors.white60 : Colors.black54)),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  SliverPadding _buildActiveGridContent(AsyncSnapshot<List<Map<String, dynamic>>> snapshot, bool isDark, ThemeData theme, bool isWeb) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SliverPadding(
        padding: EdgeInsets.all(16),
        sliver: SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
      );
    }
    if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 50, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 10),
                  Text(snapshot.hasError ? "Database Error" : "No Active Bookings Found!", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final List<Map<String, dynamic>> bookings = snapshot.data!;

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isWeb ? 2 : 1,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isWeb ? 1.4 : 1.15,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final booking = bookings[index];
            bool isCompleted = (booking['payment_status'] ?? "").toString().trim().toLowerCase() == "completed" ||
                (booking['payment_status'] ?? "").toString().trim().toLowerCase() == "approved";
            return _buildBookingCard(booking, isDark, isCompleted, theme, context);
          },
          childCount: bookings.length,
        ),
      ),
    );
  }

  SliverPadding _buildNonFunctionalGridContent(bool isDark, ThemeData theme, bool isWeb) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Opacity(
          opacity: 0.45,
          child: AbsorbPointer(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWeb ? 2 : 1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isWeb ? 1.4 : 1.15,
              ),
              itemCount: 2,
              itemBuilder: (context, index) {
                return _buildBookingCard({
                  'booking_id': 'NB-XXXXX',
                  'package_name': 'Archived Preview Session',
                  'event_date': 'DD-MM-YYYY',
                  'event_time': '00:00 PM',
                  'event_location': 'Not Available in Preview',
                  'total_amount': '0',
                  'payment_status': 'Inactive'
                }, isDark, false, theme, context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, bool isDark, bool isCompleted, ThemeData theme, BuildContext context) {
    String bookingId = booking['booking_id'] ?? "NB-00000";
    String packageTitle = booking['package_name'] ?? "Photography Session";
    String dateStr = booking['event_date'] ?? "N/A";
    String timeStr = booking['event_time'] ?? "N/A";
    String locationStr = booking['event_location'] ?? "N/A";
    String amountStr = "${booking['total_amount']?.toString() ?? '0'} BDT";
    String photographerName = booking['photographer_name'] ?? "Not Assigned";

    String paymentStatus = booking['payment_status'] ?? "Pending";
    String bookingStatus = booking['booking_status'] ?? "pending";

    String daysToGoStr = "Upcoming";
    try {
      if (booking['event_date'] != null) {
        String fullDateTimeStr = booking['event_date'].toString();

        if (booking['event_time'] != null && !fullDateTimeStr.contains(':')) {
          String rawTime = booking['event_time'].toString().trim();
          fullDateTimeStr = "${booking['event_date']} $rawTime";
        }

        DateTime eventDateTime = DateTime.parse(fullDateTimeStr);
        DateTime now = DateTime.now();
        Duration difference = eventDateTime.difference(now);

        if (difference.isNegative) {
          daysToGoStr = "Passed";
        } else {
          if (difference.inDays > 0) {
            daysToGoStr = "${difference.inDays} Days to Go";
          } else if (difference.inHours > 0) {
            daysToGoStr = "${difference.inHours} Hours to Go";
          } else if (difference.inMinutes > 0) {
            daysToGoStr = "${difference.inMinutes} Mins to Go";
          } else {
            daysToGoStr = "Today";
          }
        }
      }
    } catch (_) {
      try {
        DateTime eventDate = DateTime.parse(booking['event_date'].toString());
        int diffDays = eventDate.difference(DateTime.now()).inDays;
        if (diffDays > 0) {
          daysToGoStr = "$diffDays Days to Go";
        } else if (diffDays == 0) {
          daysToGoStr = "Today";
        } else {
          daysToGoStr = "Passed";
        }
      } catch (__) {
        daysToGoStr = "Upcoming";
      }
    }

    int currentStep = 0;
    String cleanedBookingStatus = bookingStatus.trim().toLowerCase();

    if (cleanedBookingStatus == "pending") {
      currentStep = 0;
    } else if (cleanedBookingStatus == "approved") {
      currentStep = 1;
    } else if (cleanedBookingStatus == "shooting") {
      currentStep = 2;
    } else if (cleanedBookingStatus == "final draft" || cleanedBookingStatus == "draft") {
      currentStep = 3;
    } else if (cleanedBookingStatus == "handover" || cleanedBookingStatus == "delivered" || cleanedBookingStatus == "completed") {
      currentStep = 4;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text("#$bookingId", style: TextStyle(color: widget.primaryAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              if (cleanedBookingStatus != "cancelled" && cleanedBookingStatus != "completed" && daysToGoStr != "Passed")
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(daysToGoStr, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              _statusChip(paymentStatus, isCompleted),
            ],
          ),
          const SizedBox(height: 12),
          Text(packageTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.wallet, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              const Text("Payment: ", style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text(
                isCompleted ? "Fully Paid" : "Pending Verification",
                style: TextStyle(color: isCompleted ? Colors.green : Colors.blue, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(amountStr, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: widget.primaryAccent)),
            ],
          ),

          const Divider(height: 30, thickness: 0.5),

          Row(
            children: [
              _infoTile(Icons.calendar_today, dateStr, isDark),
              const SizedBox(width: 20),
              _infoTile(Icons.access_time, timeStr, isDark),
            ],
          ),
          const SizedBox(height: 12),
          _infoTile(Icons.camera_alt_outlined, "Photographer: $photographerName", isDark),
          const SizedBox(height: 12),
          _infoTile(Icons.location_on_outlined, locationStr, isDark),

          const Divider(height: 30, thickness: 0.5),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimelineStep("Pending", currentStep >= 0, isDark),
                _buildTimelineArrow(currentStep >= 1),
                _buildTimelineStep("Approved", currentStep >= 1, isDark),
                _buildTimelineArrow(currentStep >= 2),
                _buildTimelineStep("Shooting", currentStep >= 2, isDark),
                _buildTimelineArrow(currentStep >= 3),
                _buildTimelineStep("Final Draft", currentStep >= 3, isDark),
                _buildTimelineArrow(currentStep >= 4),
                _buildTimelineStep("Handover", currentStep >= 4, isDark),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: widget.primaryAccent),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("View Details", style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: cleanedBookingStatus == "completed" || cleanedBookingStatus == "delivered" || cleanedBookingStatus == "handover"
                    ? ElevatedButton(
                  onPressed: () => ReviewService.showReviewSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text("Review", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                )
                    : OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Cancel", style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String label, bool isActive, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isActive ? Icons.check_circle : Icons.radio_button_unchecked, size: 12, color: isActive ? Colors.green : (isDark ? Colors.white30 : Colors.black26)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? (isDark ? Colors.white : Colors.black87) : Colors.grey)),
      ],
    );
  }

  Widget _buildTimelineArrow(bool isActive) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("➔", style: TextStyle(fontSize: 9, color: isActive ? Colors.green : Colors.grey.withOpacity(0.3))),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey),
        const SizedBox(width: 5),
        Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87))),
      ],
    );
  }

  Widget _statusChip(String status, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: isCompleted ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: isCompleted ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}