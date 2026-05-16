import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 ফায়ারবেস ফায়ারস্টোর ইম্পোর্ট করা হলো
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:nobochitro/booking_summary_screen/enhanced_summary_card.dart';
import 'package:nobochitro/payments/payment_sheet.dart';
import 'package:nobochitro/widgets/addOns_selector.dart';
import 'package:nobochitro/widgets/custom_appbar.dart';
import 'package:nobochitro/widgets/photographer_selector.dart';

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

  // 🔴 ফায়ারবেস থেকে ডাইনামিক ক্লায়েন্ট ডাটা ট্র্যাকিং
  String dynamicNsrId = "NSR-LOADING...";
  String dynamicUserName = "Loading User...";
  String dynamicUserEmail = "";
  String dynamicUserPhone = "";

  // 🔴 সুপাবেস থেকে ডাইনামিক ফটোগ্রাফার ডাটা ট্র্যাকিং
  String? _selectedPhotographerId;
  double _selectedPhotographerHourlyRate = 0.0;

  List<Map<String, dynamic>> _selectedAddOnsList = [];
  late Future<List<Map<String, dynamic>>> _photographersFuture;

  @override
  void initState() {
    super.initState();
    _selectedDurationHours = widget.packageData['base_hours'] ?? 1;
    _photographersFuture = DatabaseHelper.instance.getPhotographers();

    // 🔴 স্ক্রিন ওপেন হওয়ার সাথে সাথে ফায়ারস্টোর থেকে ইউজারের ডাটা লোড হবে
    _fetchFirebaseUserData();
  }

  // 🔴 ফায়ারস্টোর থেকে রিয়েলটাইম ক্লায়েন্টের NSR-ID, নাম, ফোন ও ইমেইল তুলে আনার ফাংশন
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

  // আপনার দেওয়া ৬০% লজিক অনুযায়ী ফটোগ্রাফারের এক্সট্রা আওয়ার্লি চার্জ ক্যালকুলেশন
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

  // এক্সট্রা আওয়ার্সের প্রাইস ক্যালকুলেশন
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

  double _calculateFinalAmount() {
    double basePrice = double.tryParse(widget.packageData['base_price'].toString()) ?? 0.0;
    return basePrice + _calculateExtraHoursPrice() + _calculateExtraPhotographerCharge() + totalAddonsPrice;
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
                      // 🔴 ফিক্সড: সুপাবেসের কলামের নাম 'photographer_id' অনুযায়ী রিয়েলটাইম আইডি ক্যাচ করা হচ্ছে
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

  // -------------------------------------------------------------
  // 🔴 ১০০% ডাইনামিক ও সংশোধিত প্রোসিড বাটন (0% UI Change)
  // -------------------------------------------------------------
  Widget _buildProceedButton(BuildContext context) {
    double totalAmount = _calculateFinalAmount();
    double extraHoursPrice = _calculateExtraHoursPrice();
    double extraPhotographerPrice = _calculateExtraPhotographerCharge();

    String databasePackageId = widget.packageData['package_id'] ?? "PKG-UNKNOWN";
    String databasePackageName = widget.packageData['title'] ?? "Unknown Package";
    String databaseCategory = widget.packageData['category'] ?? "General";
    double packageBasePrice = double.tryParse(widget.packageData['base_price'].toString()) ?? 0.0;
    String rawFeatures = widget.packageData['features']?.toString() ?? "No features listed";

    // 🔴 ফায়ারস্টোর এবং সুপাবেস থেকে একদম পারফেক্ট ম্যাপিং
    String databaseNsrId = dynamicNsrId;
    String databaseUserName = dynamicUserName;
    String databasePhotographerId = _selectedPhotographerId ?? "N-UNKNOWN";

    // button active conditions fill up
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
            // ফায়ারস্টোর থেকে আসা ডাইনামিক ইউজার ডাটা (ফোন ও ইমেইল যুক্ত করা হয়েছে)
            'user_id': databaseNsrId,
            'user_name': databaseUserName,
            'user_email': dynamicUserEmail,    // 👈 নতুন
            'user_phone': dynamicUserPhone,    // 👈 নতুন

            'package_id': databasePackageId,
            'package_name': databasePackageName,
            'package_category': databaseCategory,
            'base_price': packageBasePrice,
            'package_features': rawFeatures,

            // সুপাবেস থেকে আসা সঠিক কাস্টম ফটোগ্রাফার আইডি
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