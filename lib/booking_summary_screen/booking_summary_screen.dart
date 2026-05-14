import 'dart:ui';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nobochitro/payments/payment_sheet.dart';
import 'package:nobochitro/widgets/addOns_selector.dart';
import 'package:nobochitro/widgets/custom_appbar.dart';
import 'package:nobochitro/widgets/photographer_selector.dart';

class BookingSummaryScreen extends StatefulWidget {
  final Color primaryAccent;
  final Map<String, dynamic> packageData;
  const BookingSummaryScreen({super.key, required this.primaryAccent, required this.packageData});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  DateTime? _selectedDate;
  String _selectedTime = "10:00 AM";
  String _selectedLocationType = "Studio";
  int _selectedDurationHours = 1;
  int _selectedDurationMinutes = 0;
  int _selectedPhotographerIndex = -1;
  String _selectedPhotographer = "None";

  // getaddons
  List<Map<String, dynamic>> selectedAddons = [];
  double totalAddonsPrice = 0.0;

  late Future<List<Map<String, dynamic>>> _photographersFuture;

  @override
  void initState() {
    super.initState();
    // database call
    _photographersFuture = DatabaseHelper.instance.getPhotographers();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: widget.primaryAccent,
              primary: widget.primaryAccent,
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = screenWidth > 800;

    return Scaffold(
      appBar: buildCustomAppBar(
        context,
        widget.primaryAccent,
        "Booking Details",
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? screenWidth * 0.2 : 16.0,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Booking Summary", theme),
                _buildEnhancedSummaryCard(theme, isDark),

                const SizedBox(height: 25),
                _buildSectionTitle("Select Professional Photographer", theme),
                // photographer call
                PhotographerSelector(
                    photographersFuture: _photographersFuture,
                    onPhotographerSelected: (photographer){
                      setState(() {
                        _selectedPhotographer = photographer['name']?? "unknow";
                      });
                    }
                ),


                const SizedBox(height: 25,),
                const Text(
                  "Extra Service (Exclusive)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                AddOnsSelector(onSelectionChanged: (newList){
                  setState(() {
                    totalAddonsPrice = newList.fold(0, (sum, item)=> sum+ (item['price']?? 0));
                  });
                  print("সিলেক্ট করা হয়েছে: ${selectedAddons.length} টি আইটেম");
                  print("মোট খরচ: ৳$totalAddonsPrice");
                }),


                const SizedBox(height: 25),
                _buildSectionTitle("Schedule Your Session", theme),
                _buildDateTimeSelector(theme, isDark),

                const SizedBox(height: 25),
                _buildSectionTitle("Set Duration", theme), // ডিউরেশন টাইটেল
                _buildDurationSelector(theme, isDark), // ডিউরেশন উইজেট

                const SizedBox(height: 25),
                _buildSectionTitle("Set Event Location", theme),
                _buildLocationSelector(theme, isDark),

                const SizedBox(height: 30),
                _buildProceedButton(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Components Methods ---

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEnhancedSummaryCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.primaryAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: widget.primaryAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Premium Portrait Session",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 0.8),
          _infoRow(
            Icons.timer_outlined,
            "Duration",
            "${_selectedDurationHours}h ${_selectedDurationMinutes}m Full Session",
          ),
          _infoRow(
            Icons.collections_rounded,
            "Deliverables",
            "50+ Retouched Photos",
          ),
          _infoRow(
            Icons.location_on_outlined,
            "Location",
            _selectedLocationType,
          ),
          const Divider(height: 32, thickness: 0.8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "15,750 BDT",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: widget.primaryAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector(ThemeData theme, bool isDark) {
    return Container(
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
              const Text(
                "Booking Duration",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                "${_selectedDurationHours}h ${_selectedDurationMinutes}m",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildRoundBtn(Icons.remove, () {
                setState(() {
                  if (_selectedDurationHours > 1 ||
                      _selectedDurationMinutes >= 30) {
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
    );
  }

  Widget _buildRoundBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.primaryAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.primaryAccent.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelector(ThemeData theme, bool isDark) {
    return Column(
      children: [
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
            child: Row(
              //
              children: [
                Icon(Icons.calendar_month, color: widget.primaryAccent),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Date",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      _selectedDate == null
                          ? "Choose a date"
                          : DateFormat(
                              'EEEE, dd MMMM yyyy',
                            ).format(_selectedDate!),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
                  ),
                );
              }),
              ActionChip(
                label: Text(
                  ![
                        "10:00 AM",
                        "01:00 PM",
                        "04:00 PM",
                        "07:00 PM",
                      ].contains(_selectedTime)
                      ? _selectedTime
                      : "Custom",
                ),
                onPressed: () async {
                  TimeOfDay? t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (t != null)
                    setState(() => _selectedTime = t.format(context));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSelector(ThemeData theme, bool isDark) {
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
            decoration: InputDecoration(
              hintText: "Enter event location or city name",
              filled: true,
              fillColor: isDark ? Colors.grey[900] : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.location_on, color: widget.primaryAccent),
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
            border: Border.all(
              color: isSelected
                  ? widget.primaryAccent
                  : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.black : Colors.grey,
              ),
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
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _selectedDate == null
            ? null
            : () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => PaymentSheet(
                    primaryAccent: widget.primaryAccent,
                    amount: 15750.0,
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.primaryAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 8,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Proceed to Payment",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}
