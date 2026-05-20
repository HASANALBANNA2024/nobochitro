import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:nobochitro/booking_summary_screen/enhanced_summary_card.dart';
import 'package:nobochitro/payments/payment_sheet.dart';
import 'package:nobochitro/widgets/addOns_selector.dart';
import 'package:nobochitro/widgets/custom_appbar.dart';
import 'package:nobochitro/widgets/photographer_selector.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👈 সুপাবেস ক্লায়েন্ট ব্যবহারের জন্য নিশ্চিত করা হলো

class BookingSummaryScreen extends StatefulWidget {
  final Color primaryAccent;
  final Map<String, dynamic> packageData;

  const BookingSummaryScreen({
    super.key,
    required this.primaryAccent,
    required this.packageData,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  DateTime? _selectedDate;
  String _selectedTime = "10:00 AM";
  String _selectedLocationType = "Studio";
  String _outdoorAddress = "";

  int _selectedDurationHours = 1;
  int _selectedDurationMinutes = 0;
  String _selectedPhotographer = "None";
  double totalAddonsPrice = 0.0;

  // 🔴 ফায়ারবেস থেকে ডাইনামিক ক্লায়েন্ট ডাটা ট্র্যাকিং
  String dynamicNsrId = "NSR-LOADING...";
  String dynamicUserName = "Loading User...";
  String dynamicUserEmail = "";
  String dynamicUserPhone = "";

  // 🔴 সুপাবেস থেকে ডাইনামিক ফটোগ্রাফার ডাটা ট্র্যাকিং
  String? _selectedPhotographerId;
  double _selectedPhotographerHourlyRate = 0.0;

  List<Map<String, dynamic>> _selectedAddOnsList = [];
  late Future<List<Map<String, dynamic>>> _photographersFuture;

  // 🎯 ─── কুপন সিস্টেমের নতুন ভ্যারিয়েবলস ───
  final TextEditingController _couponController = TextEditingController();
  String? _appliedCouponCode;
  bool _isCouponApplied = false;
  int _discountPercentage = 0;

  @override
  void initState() {
    super.initState();
    _selectedDurationHours = widget.packageData['base_hours'] ?? 1;
    _photographersFuture = DatabaseHelper.instance.getPhotographers();

    // 🔴 স্ক্রিন ওপেন হওয়ার সাথে সাথে ফায়ারস্টোর থেকে ইউজারের ডাটা লোড হবে
    _fetchFirebaseUserData();
  }

  @override
  void dispose() {
    _couponController.dispose(); // কন্ট্রোলার মেমোরি ক্লিয়ার করা
    super.dispose();
  }

  // 🔴 ফায়ারস্টোর থেকে রিয়েলটাইম ক্লায়েন্টের NSR-ID, নাম, ফোন ও ইমেইল তুলে আনার ফাংশন
  Future<void> _fetchFirebaseUserData() async {
    try {
      final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserUid != null) {
        final docSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .get();

        if (docSnap.exists && docSnap.data() != null) {
          final data = docSnap.data()!;
          setState(() {
            dynamicNsrId = data['custom_id'] ?? "NSR-UNKNOWN";
            dynamicUserName = data['name'] ?? "Unknown User";
            dynamicUserEmail = data['email'] ?? "";
            dynamicUserPhone = data['phone'] ?? "";
          });
        }
      }
    } catch (e) {
      debugPrint("Firebase Firestore User Fetch Error: $e");
      setState(() {
        dynamicNsrId = "NSR-ERROR";
        dynamicUserName = "Error Loading";
      });
    }
  }

  // 🎯 ─── সুপাবেস কুপন চেক ও অ্যাপ্লাই লজিক (targeted_category এবং targeted_package চেইক) ───
  Future<void> _applyCouponCode() async {
    final inputCode = _couponController.text.trim();
    if (inputCode.isEmpty) {
      _showSnackBar("Please enter a coupon code!", Colors.red);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('campaigns')
          .select()
          .eq('campaign_id', inputCode)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        _showSnackBar("❌ Invalid or inactive coupon code!", Colors.red);
        return;
      }

      // ১. মেয়াদের তারিখ চেক (Expiry Check)
      final DateTime now = DateTime.now();
      final DateTime endDate = DateTime.parse(response['end_date'].toString());
      if (now.isAfter(endDate)) {
        _showSnackBar("❌ Sorry, this coupon code has expired!", Colors.red);
        return;
      }

      // কারেন্ট প্যাকেজের আইডি এবং ক্যাটাগরি ডাটা
      final String currentPackageId = widget.packageData['package_id']?.toString() ?? "PKG-UNKNOWN";
      final String currentCategory = widget.packageData['category']?.toString() ?? "General";

      final String? dbCategory = response['targeted_category']?.toString();
      final String? dbPackage = response['targeted_package']?.toString();

      bool isEligible = false;

      // ২. সুনির্দিষ্ট প্যাকেজ চেক (targeted_package কলাম চেক)
      if (dbPackage != null && dbPackage.trim().isNotEmpty) {
        List<String> allowedPackages = dbPackage.split(',').map((e) => e.trim().toLowerCase()).toList();
        if (allowedPackages.contains(currentPackageId.toLowerCase())) {
          isEligible = true;
        }
      }

      // ৩. ক্যাটাগরি চেক (targeted_category কলাম চেক - যদি প্যাকেজ দিয়ে ম্যাচ না হয়ে থাকে)
      if (!isEligible && dbCategory != null && dbCategory.trim().isNotEmpty) {
        List<String> allowedCategories = dbCategory.split(',').map((e) => e.trim().toLowerCase()).toList();
        if (allowedCategories.contains(currentCategory.toLowerCase())) {
          isEligible = true;
        }
      }

      // কুপন যদি কোনো নির্দিষ্ট কন্ডিশন হোল্ড করে কিন্তু কোনোটাই ম্যাচ না করে
      if ((dbPackage != null && dbPackage.trim().isNotEmpty || dbCategory != null && dbCategory.trim().isNotEmpty) && !isEligible) {
        _showSnackBar("❌ This coupon is not valid for this package or category!", Colors.red);
        return;
      }

      // ৪. সব চেক পাস হলে ডিসকাউন্ট স্টেট সেট হবে
      setState(() {
        _discountPercentage = response['discount_pct'] ?? 0;
        _appliedCouponCode = inputCode;
        _isCouponApplied = true;
      });

      _showSnackBar("🎉 Coupon applied successfully! ৳$_discountPercentage% off.", Colors.green);

    } catch (e) {
      debugPrint("Coupon Apply Error: $e");
      _showSnackBar("Error validating coupon!", Colors.red);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: bgColor, duration: const Duration(seconds: 2)),
    );
  }

  // আপনার দেওয়া ৬০% লজিক অনুযায়ী ফটোগ্রাফারের এক্সট্রা আওয়ার্লি চার্জ ক্যালকুলেশন
  double _calculateExtraPhotographerCharge() {
    if (_selectedPhotographer == "None" || _selectedPhotographer.isEmpty) return 0.0;

    double basePrice = double.tryParse(widget.packageData['base_price'].toString()) ?? 0.0;
    int baseHours = widget.packageData['base_hours'] ?? 1;

    double packageAllocatedHourlyRate = (basePrice * 0.6) / baseHours;

    if (_selectedPhotographerHourlyRate > packageAllocatedHourlyRate) {
      double hourlyRateDifference = _selectedPhotographerHourlyRate - packageAllocatedHourlyRate;
      double totalSelectedDuration = _selectedDurationHours + (_selectedDurationMinutes / 60);
      return totalSelectedDuration * hourlyRateDifference;
    }

    return 0.0;
  }

  // এক্সট্রা আওয়ার্সের প্রাইস ক্যালকুলেশন
  double _calculateExtraHoursPrice() {
    double basePrice = double.tryParse(widget.packageData['base_price'].toString()) ?? 0.0;
    int baseHours = widget.packageData['base_hours'] ?? 1;
    double pricePerHour = basePrice / baseHours;
    double selectedDuration = _selectedDurationHours + (_selectedDurationMinutes / 60);
    double extraPrice = 0.0;

    if (selectedDuration > baseHours) {
      double extraTime = selectedDuration - baseHours;
      extraPrice = extraTime * pricePerHour;
    }
    return extraPrice;
  }

  // 🎯 মেইন টোটাল অ্যামাউন্ট হিসাব (কুপন ডিসকাউন্ট শুধুমাত্র মেইন ফাইনাল টাকা থেকে মাইনাস হবে)
  double _calculateFinalAmount() {
    double basePrice = double.tryParse(widget.packageData['base_price'].toString()) ?? 0.0;
    double totalBeforeDiscount = basePrice + _calculateExtraHoursPrice() + _calculateExtraPhotographerCharge() + totalAddonsPrice;

    if (_isCouponApplied) {
      double discount = totalBeforeDiscount * (_discountPercentage / 100);
      return totalBeforeDiscount - discount;
    }

    return totalBeforeDiscount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    double basePrice = double.tryParse(widget.packageData['base_price'].toString()) ?? 0.0;
    int baseHours = widget.packageData['base_hours'] ?? 1;
    double packageAllocatedHourlyRate = (basePrice * 0.6) / baseHours;
    bool isPhotographerSelected = _selectedPhotographer != "None" && _selectedPhotographer.isNotEmpty;

    return Scaffold(
      appBar: buildCustomAppBar(
        context,
        widget.primaryAccent,
        "Booking Details",
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Booking Summary", theme),

                    EnhancedSummaryCard(
                      packageData: widget.packageData,
                      primaryAccent: widget.primaryAccent,
                      selectedHours: _selectedDurationHours,
                      selectedMinutes: _selectedDurationMinutes,
                      selectedTime: _selectedTime,
                      locationType: (_selectedLocationType == "Outdoor" && _outdoorAddress.isNotEmpty)
                          ? _outdoorAddress
                          : _selectedLocationType,
                      totalAddonsPrice: totalAddonsPrice,
                    ),

                    const SizedBox(height: 25),
                    _buildSectionTitle("Select Photographer", theme),
                    PhotographerSelector(
                      photographersFuture: _photographersFuture,
                      onPhotographerSelected: (p) => setState(() {
                        _selectedPhotographer = p['name'] ?? "Unknown";
                        _selectedPhotographerId = p['photographer_id']?.toString() ?? "N-UNKNOWN";
                        _selectedPhotographerHourlyRate = double.tryParse(p['price_per_hour'].toString()) ?? 0.0;
                      }),
                    ),

                    if (isPhotographerSelected) ...[
                      const SizedBox(height: 8),
                      Text(
                        _selectedPhotographerHourlyRate <= packageAllocatedHourlyRate
                            ? "This photographer is valid for package not pay extra fees"
                            : "Premium Photographer Extra Fee: ৳${_calculateExtraPhotographerCharge().toStringAsFixed(0)} (+৳${(_selectedPhotographerHourlyRate - packageAllocatedHourlyRate).toStringAsFixed(0)}/h)",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _selectedPhotographerHourlyRate <= packageAllocatedHourlyRate
                              ? Colors.green
                              : widget.primaryAccent,
                        ),
                      ),
                    ],

                    const SizedBox(height: 25),
                    const Text(
                      "Extra Service",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    AddOnsSelector(
                      selectedCategory: widget.packageData['category'] ?? "Not available",
                      onSelectionChanged: (newList) {
                        setState(() {
                          _selectedAddOnsList = newList;
                          totalAddonsPrice = newList.fold(
                            0.0,
                                (sum, item) => sum + (double.tryParse(item['price'].toString()) ?? 0.0),
                          );
                        });
                      },
                    ),

                    const SizedBox(height: 25),
                    _buildSectionTitle("Schedule & Duration", theme),
                    _buildDateTimeSelector(isDark),
                    const SizedBox(height: 15),
                    _buildBookingScheduleSelector(theme, isDark),

                    const SizedBox(height: 25),
                    _buildSectionTitle("Event Location", theme),
                    _buildLocationSelector(isDark),

                    // 🎯 ─── কুপন কোড ইনপুট ফিল্ড ও বাটন UI সেকশন ───
                    const SizedBox(height: 25),
                    _buildSectionTitle("Have a Coupon?", theme),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponController,
                            enabled: !_isCouponApplied,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: "Enter Coupon Code",
                              filled: true,
                              fillColor: isDark ? Colors.grey[900] : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isCouponApplied ? null : _applyCouponCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.primaryAccent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(_isCouponApplied ? "Applied" : "Apply"),
                          ),
                        ),
                      ],
                    ),
                    if (_isCouponApplied) ...[
                      const SizedBox(height: 6),
                      Text(
                        "🎉 Coupon '$_appliedCouponCode' Active ($_discountPercentage% Discount Appended)",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],

                    const SizedBox(height: 35),
                    _buildProceedButton(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildBookingScheduleSelector(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              ...["10:00 AM", "01:00 PM", "04:00 PM", "07:00 PM"].map((time) {
                bool isSelected = _selectedTime == time;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(time),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedTime = time),
                    selectedColor: widget.primaryAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black),
                    ),
                    backgroundColor: isDark ? Colors.grey[850] : Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    showCheckmark: false,
                  ),
                );
              }),
              ActionChip(
                avatar: Icon(
                  Icons.access_time,
                  size: 16,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                label: const Text("Custom"),
                onPressed: () async {
                  TimeOfDay? t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (t != null) setState(() => _selectedTime = t.format(context));
                },
                backgroundColor: isDark ? Colors.grey[850] : Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Booking Duration", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    "${_selectedDurationHours}h ${_selectedDurationMinutes}m",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildRoundBtn(Icons.remove, () {
                    setState(() {
                      int baseH = widget.packageData['base_hours'] ?? 1;
                      if (_selectedDurationHours > baseH || _selectedDurationMinutes >= 30) {
                        if (_selectedDurationMinutes == 0) {
                          _selectedDurationHours--;
                          _selectedDurationMinutes = 30;
                        } else {
                          _selectedDurationMinutes -= 30;
                        }
                      }
                    });
                  }, isDark),
                  const SizedBox(width: 15),
                  _buildRoundBtn(Icons.add, () {
                    setState(() {
                      _selectedDurationMinutes += 30;
                      if (_selectedDurationMinutes >= 60) {
                        _selectedDurationHours++;
                        _selectedDurationMinutes = 0;
                      }
                    });
                  }, isDark),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoundBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: widget.primaryAccent, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }

  Widget _buildDateTimeSelector(bool isDark) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: widget.primaryAccent),
            const SizedBox(width: 15),
            Text(
              _selectedDate == null
                  ? "Choose Date"
                  : DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate!),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelector(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            _locationTypeChip("Studio", Icons.storefront_outlined),
            const SizedBox(width: 10),
            _locationTypeChip("Outdoor", Icons.terrain_outlined),
          ],
        ),
        if (_selectedLocationType == "Outdoor") ...[
          const SizedBox(height: 15),
          TextField(
            onChanged: (val) => setState(() => _outdoorAddress = val),
            decoration: InputDecoration(
              hintText: "Enter address",
              filled: true,
              fillColor: isDark ? Colors.grey[900] : Colors.white,
              prefixIcon: Icon(Icons.location_on, color: widget.primaryAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _locationTypeChip(String type, IconData icon) {
    bool isSelected = _selectedLocationType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedLocationType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? widget.primaryAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? widget.primaryAccent : Colors.grey.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.black : Colors.grey),
              const SizedBox(width: 8),
              Text(
                type,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProceedButton(BuildContext context) {
    double totalAmount = _calculateFinalAmount();
    double extraHoursPrice = _calculateExtraHoursPrice();
    double extraPhotographerPrice = _calculateExtraPhotographerCharge();

    String databasePackageId = widget.packageData['package_id'] ?? "PKG-UNKNOWN";
    String databasePackageName = widget.packageData['title'] ?? "Unknown Package";
    String databaseCategory = widget.packageData['category'] ?? "General";
    double packageBasePrice = double.tryParse(widget.packageData['base_price'].toString()) ?? 0.0;
    String rawFeatures = widget.packageData['features']?.toString() ?? "No features listed";

    String databaseNsrId = dynamicNsrId;
    String databaseUserName = dynamicUserName;
    String databasePhotographerId = _selectedPhotographerId ?? "N-UNKNOWN";

    bool isDateSelected = _selectedDate != null;
    bool isPhotographerSelected = _selectedPhotographer != "None" && _selectedPhotographer.isNotEmpty;
    bool isLocationValid = _selectedLocationType == "Outdoor" ? _outdoorAddress.trim().isNotEmpty : true;
    bool isFormValid = isDateSelected && isPhotographerSelected && isLocationValid;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isFormValid
            ? () {
          final Map<String, dynamic> currentBooking = {
            'user_id': databaseNsrId,
            'user_name': databaseUserName,
            'user_email': dynamicUserEmail,
            'user_phone': dynamicUserPhone,

            'package_id': databasePackageId,
            'package_name': databasePackageName,
            'package_category': databaseCategory,
            'base_price': packageBasePrice,
            'package_features': rawFeatures,

            'photographer_id': databasePhotographerId,
            'photographer_name': _selectedPhotographer,
            'photographer_hourly_rate': _selectedPhotographerHourlyRate,

            'event_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
            'event_time': _selectedTime,
            'event_duration': "${_selectedDurationHours}h ${_selectedDurationMinutes}m",
            'event_location': _selectedLocationType == "Outdoor" && _outdoorAddress.isNotEmpty
                ? _outdoorAddress
                : _selectedLocationType,

            'extra_hours_price': extraHoursPrice,
            'extra_photographer_price': extraPhotographerPrice,
            'total_addons_price': totalAddonsPrice,
            'total_amount': totalAmount,

            // পেমেন্ট শীটে কুপন ট্র্যাকিংয়ের জন্য ডাটা পাঠানো হচ্ছে
            'applied_coupon_code': _appliedCouponCode ?? "NONE",
            'coupon_discount_percentage': _discountPercentage,

            'selected_addons_breakdown': _selectedAddOnsList.map((item) => {
              'name': item['name'],
              'price': double.tryParse(item['price'].toString()) ?? 0.0,
            }).toList(),

            'addons_summary_text': _selectedAddOnsList.map((item) => item['name']).join(', '),
          };

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => PaymentSheet(
              primaryAccent: widget.primaryAccent,
              amount: totalAmount,
              bookingData: currentBooking,
            ),
          );
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.primaryAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(
          "Pay ৳${totalAmount.toStringAsFixed(0)}",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}