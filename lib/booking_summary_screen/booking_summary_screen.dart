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

  late Future<List<Map<String, dynamic>>> _photographersFuture;

  @override
  void initState() {
    super.initState();
    _selectedDurationHours = widget.packageData['base_hours'] ?? 1;
    _photographersFuture = DatabaseHelper.instance.getPhotographers();
  }

  double _calculateFinalAmount() {
    double basePrice =
        double.tryParse(widget.packageData['base_price'].toString()) ?? 0.0;
    int baseHours = widget.packageData['base_hours'] ?? 1;
    double pricePerHour = basePrice / baseHours;
    double selectedDuration =
        _selectedDurationHours + (_selectedDurationMinutes / 60);
    double finalPrice = basePrice;

    if (selectedDuration > baseHours) {
      double extraTime = selectedDuration - baseHours;
      finalPrice += (extraTime * pricePerHour);
    }
    return finalPrice + totalAddonsPrice;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: buildCustomAppBar(
        context,
        widget.primaryAccent,
        "Booking Details",
      ),
      body: SafeArea(
        child: Center(
          // ওয়েবে কন্টেন্ট মাঝখানে রাখার জন্য
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 800,
            ), // বড় স্ক্রিনে ৮০০ পিক্সেলের বেশি হবে না
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
                      locationType:
                          (_selectedLocationType == "Outdoor" &&
                              _outdoorAddress.isNotEmpty)
                          ? _outdoorAddress
                          : _selectedLocationType,
                      totalAddonsPrice: totalAddonsPrice,
                    ),

                    const SizedBox(height: 25),
                    _buildSectionTitle("Select Photographer", theme),
                    PhotographerSelector(
                      photographersFuture: _photographersFuture,
                      onPhotographerSelected: (p) => setState(
                        () => _selectedPhotographer = p['name'] ?? "Unknown",
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "Extra Service",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AddOnsSelector(
                      onSelectionChanged: (newList) {
                        setState(() {
                          totalAddonsPrice = newList.fold(
                            0.0,
                            (sum, item) =>
                                sum +
                                (double.tryParse(item['price'].toString()) ??
                                    0.0),
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

  // --- Widgets (লজিক ও UI আগের মতোই আছে) ---

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
                      color: isSelected
                          ? Colors.black
                          : (isDark ? Colors.white : Colors.black),
                    ),
                    backgroundColor: isDark
                        ? Colors.grey[850]
                        : Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  if (t != null)
                    setState(() => _selectedTime = t.format(context));
                },
                backgroundColor: isDark ? Colors.grey[850] : Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                      int baseH = widget.packageData['base_hours'] ?? 1;
                      if (_selectedDurationHours > baseH ||
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
        ),
      ],
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
        ),
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
    double total = _calculateFinalAmount();
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _selectedDate == null
            ? null
            : () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (c) => PaymentSheet(
                  primaryAccent: widget.primaryAccent,
                  amount: total,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.primaryAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          "Pay ৳${total.toStringAsFixed(0)}",
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
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
