import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:nobochitro/widgets/custom_appbar.dart';
import 'package:nobochitro/widgets/custom_bottom_nav.dart';

import 'booking_card_widget.dart';
import 'booking_glance_section.dart';
import 'booking_tab_buttons.dart';

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

  /// database refreshed methond
  void _refreshBookings() {
    if (dynamicNsrId != "NSR-LOADING..." && dynamicNsrId != "NSR-NOT-FOUND") {
      setState(() {
        _bookingsFuture = DatabaseHelper.instance.getUserBookings(dynamicNsrId);
      });
    }
  }

  Future<void> _fetchSupabaseUserData() async {
    try {
      final String? nsrId = await DatabaseHelper.instance.getCurrentUserNsrId();
      if (nsrId != null) {
        setState(() {
          dynamicNsrId = nsrId;
          _isLoadingUser = false;
          _bookingsFuture = DatabaseHelper.instance.getUserBookings(
            dynamicNsrId,
          );
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

  /// backend update and real time state handling
  Future<void> _handleBookingCancellation(
    String bookingId,
    String notes,
  ) async {
    try {
      await DatabaseHelper.instance.updateBookingCancellation(
        bookingId: bookingId,
        cancellationNotes: notes,
        newStatus: "cancellation pending",
      );

      /// after successful refreshed
      _refreshBookings();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cancellation request submitted successfully!"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
      );
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
                    ? const Center(
                        child: Text(
                          "Please log in to see your bookings",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : _isLoadingUser
                    ? Center(
                        child: CircularProgressIndicator(
                          color: widget.primaryAccent,
                        ),
                      )
                    : dynamicNsrId == "NSR-NOT-FOUND" ||
                          dynamicNsrId == "NSR-ERROR"
                    ? const Center(
                        child: Text(
                          "Failed to load user profile context.",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : FutureBuilder<List<Map<String, dynamic>>>(
                        future: _bookingsFuture,
                        builder: (context, snapshot) {
                          return CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              SliverToBoxAdapter(
                                child: BookingGlanceSection(
                                  snapshot: snapshot,
                                  isDark: isDark,
                                  isWeb: isWeb,
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: BookingTabButtons(
                                  selectedTabIndex: _selectedTabIndex,
                                  primaryAccent: widget.primaryAccent,
                                  isDark: isDark,
                                  onTabSelected: (index) =>
                                      setState(() => _selectedTabIndex = index),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: Text(
                                    _selectedTabIndex == 0
                                        ? "🏁 ACTIVE & UPCOMING TIMELINE"
                                        : _selectedTabIndex == 1
                                        ? "⏳ CANCELLED & REFUNDS TIMELINE"
                                        : "⚠️ SUSPENDED TIMELINE",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),

                              /// runtime filtering grid
                              _buildFilteredGridContent(
                                snapshot,
                                isDark,
                                theme,
                                isWeb,
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isWeb
          ? CustomBottomNav(
              currentIndex: widget.selectedIndex,
              onTap: widget.onDestinationSelected,
            )
          : null,
    );
  }

  //
  SliverPadding _buildFilteredGridContent(
    AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
    bool isDark,
    ThemeData theme,
    bool isWeb,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SliverPadding(
        padding: EdgeInsets.all(16),
        sliver: SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
      return _buildEmptyState("No Bookings Found!");
    }

    final List<Map<String, dynamic>> allBookings = snapshot.data!;
    List<Map<String, dynamic>> filteredBookings = [];

    /// tab wise filtering grid
    if (_selectedTabIndex == 0) {
      filteredBookings = allBookings.where((b) {
        String status = (b['booking_status'] ?? 'pending')
            .toString()
            .trim()
            .toLowerCase();
        return ![
          "cancelled",
          "cancellation pending",
          "cancellation approved",
          "refund processing",
          "refund done",
          "suspended",
        ].contains(status);
      }).toList();
    } else if (_selectedTabIndex == 1) {
      filteredBookings = allBookings.where((b) {
        String status = (b['booking_status'] ?? 'pending')
            .toString()
            .trim()
            .toLowerCase();
        return [
          "cancelled",
          "cancellation pending",
          "cancellation approved",
          "refund processing",
          "refund done",
        ].contains(status);
      }).toList();
    } else if (_selectedTabIndex == 2) {
      filteredBookings = allBookings.where((b) {
        String status = (b['booking_status'] ?? 'pending')
            .toString()
            .trim()
            .toLowerCase();
        return status == "suspended";
      }).toList();
    }

    if (filteredBookings.isEmpty) {
      return _buildEmptyState("No data available in this section.");
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isWeb ? 2 : 1,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isWeb ? 1.4 : 1.15,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final booking = filteredBookings[index];
          bool isCompleted =
              (booking['payment_status'] ?? "")
                      .toString()
                      .trim()
                      .toLowerCase() ==
                  "completed" ||
              (booking['payment_status'] ?? "")
                      .toString()
                      .trim()
                      .toLowerCase() ==
                  "approved";

          return BookingCardWidget(
            booking: booking,
            isDark: isDark,
            isCompleted: isCompleted,
            primaryAccent: widget.primaryAccent,
            onViewDetails: () {},
            onCancel: () {
              _showCancelBottomSheet(
                context,
                booking['booking_id'] ?? "NB-00000",
                isDark,
              );
            },
          );
        }, childCount: filteredBookings.length),
      ),
    );
  }

  SliverPadding _buildEmptyState(String msg) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              msg,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// custom cancellation sheet widget
  void _showCancelBottomSheet(
    BuildContext context,
    String bookingId,
    bool isDark,
  ) {
    final TextEditingController notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text(
                      "Cancel Booking #$bookingId",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please specify your reason for cancelling this booking.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: notesController,
                  maxLines: 3,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Enter your notes here...",
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? "Reason is required"
                      : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            _handleBookingCancellation(
                              bookingId,
                              notesController.text.trim(),
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Submit Cancel"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
