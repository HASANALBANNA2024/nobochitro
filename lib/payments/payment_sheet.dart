import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class PaymentSheet extends StatefulWidget {
  final Color primaryAccent;
  final double amount;


  final Map<String, dynamic> bookingData;

  const PaymentSheet({
    super.key,
    required this.primaryAccent,
    required this.amount,
    required this.bookingData,
  });

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  String _selectedMethod = "bKash";
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _trxController = TextEditingController();
  final TextEditingController _extraController = TextEditingController();

  // cross platform image selection
  File? _selectedImageFile; // mobile local file object
  Uint8List? _selectedImageBytes; // preview
  String _imageName = ""; // display image name

  final ImagePicker _picker = ImagePicker();

  // boolean
  bool _isLoading = false;

  // 10 digit unique booking id generate
  String _generateMixedBookingId() {
    // name and email catch
    String name = (widget.bookingData['user_name'] ?? 'USER').toString().replaceAll(' ', '').toUpperCase();
    String email = (widget.bookingData['user_email'] ?? 'APP').toString().split('@')[0].toUpperCase();

    // Source of Mixed
    String baseSource = "$name$email" "NC202634587697609487346364878457645";
    // backup SOURCE
    const String pool = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789HSHEING769i487309873";

    final random = Random();
    List<String> idChars = [];

    // username first 2 name Character
    if (name.length >= 2) {
      idChars.add(name[random.nextInt(name.length)]);
      idChars.add(name[random.nextInt(name.length)]);
    } else {
      idChars.add(pool[random.nextInt(pool.length)]);
      idChars.add(pool[random.nextInt(pool.length)]);
    }

    // Email Character
    if (email.length >= 2) {
      idChars.add(email[random.nextInt(email.length)]);
      idChars.add(email[random.nextInt(email.length)]);
    } else {
      idChars.add(pool[random.nextInt(pool.length)]);
      idChars.add(pool[random.nextInt(pool.length)]);
    }

    // 6 digit random
    while (idChars.length < 10) {
      if (random.nextBool() && baseSource.isNotEmpty) {
        idChars.add(baseSource[random.nextInt(baseSource.length)]);
      } else {
        idChars.add(pool[random.nextInt(pool.length)]);
      }
    }

    // all thing mixed
    idChars.shuffle(random);
    return idChars.join().substring(0, 10);
  }

  // Universal image picker
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      // Image file director
      final Uint8List bytes = await pickedFile.readAsBytes();

      setState(() {
        _selectedImageBytes = bytes;
        _imageName = pickedFile.name;
        // Web platform
        if (!kIsWeb) {
          _selectedImageFile = File(pickedFile.path);
        }
      });
    }
  }

  // Account Details
  Map<String, String> get _ourAccountDetails {
    switch (_selectedMethod) {
      case "Nagad":
        return {"info": "019XXXXXXXX (Personal)", "label": "Nagad Number:"};
      case "Visa Card":
        return {
          "info": "City Bank, A/C: 10123456789",
          "label": "Card Payment Account:",
        };
      case "Bank Transfer":
        return {
          "info": "Bank: Dutch Bangla, A/C: 123.151.XXXX, Branch: Dhaka",
          "label": "Bank Details:",
        };
      default:
        return {"info": "017XXXXXXXX (Personal)", "label": "bKash Number:"};
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 15),
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Payment Details",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.primaryAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${widget.amount.toStringAsFixed(0)} BDT",
                            style: TextStyle(
                              color: widget.primaryAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Payment Metohod select
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                        [
                          "bKash",
                          "Nagad",
                          "Visa Card",
                          "Bank Transfer",
                        ].map((method) {
                          bool isSelected = _selectedMethod == method;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text(method),
                              selected: isSelected,
                              selectedColor: widget.primaryAccent,
                              onSelected: (val) {
                                setState(() {
                                  _selectedMethod = method;
                                  _numberController.clear();
                                  _trxController.clear();
                                  _extraController.clear();
                                });
                              },
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.black
                                    : (isDark
                                    ? Colors.white
                                    : Colors.black),
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Payment Receiving info card
                    _buildInfoCard(isDark),

                    const SizedBox(height: 25),

                    // Input field user account
                    _buildInputField(
                      label:
                      (_selectedMethod == "Bank Transfer" ||
                          _selectedMethod == "Visa Card")
                          ? "Your Bank Name"
                          : "Your $_selectedMethod Number",
                      hint:
                      (_selectedMethod == "Bank Transfer" ||
                          _selectedMethod == "Visa Card")
                          ? "e.g. Dutch Bangla Bank"
                          : "e.g. 01XXXXXXXXX",
                      controller: _numberController,
                      icon: Icons.account_balance,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 20),

                    // Txrd id
                    _buildInputField(
                      label:
                      (_selectedMethod == "Bank Transfer" ||
                          _selectedMethod == "Visa Card")
                          ? "Reference / Account No"
                          : "Transaction ID (TrxID)",
                      hint: "Enter TrxID or Reference",
                      controller: _trxController,
                      icon: Icons.vpn_key_outlined,
                      isDark: isDark,
                    ),

                    // Bank or card field
                    if (_selectedMethod == "Bank Transfer" ||
                        _selectedMethod == "Visa Card") ...[
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: "Account Holder Name / Branch",
                        hint: "Enter for manual cross-check",
                        controller: _extraController,
                        icon: Icons.person_outline,
                        isDark: isDark,
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Image picker of transaction
                    const Text(
                      "Transaction Image:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 10),

                    _selectedImageBytes == null ?
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: widget.primaryAccent.withOpacity(0.3), style: BorderStyle.solid),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: widget.primaryAccent, size: 28),
                            const SizedBox(height: 5),
                            const Text("ADD IMAGE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                        : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                              ),
                              // Image.memory
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.memory(
                                  _selectedImageBytes!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImageBytes = null;
                                    _selectedImageFile = null;
                                    _imageName = "";
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Selected:",
                                style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _imageName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // end of transaction

                    const SizedBox(height: 20),
                    _buildStatusAlert(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // সাবমিট বাটন
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {

                    setState(() {
                      _isLoading = true;
                    });
                    final String generatedBookingId = _generateMixedBookingId();
                    final Map<String, dynamic> finalPaymentAndBookingData = {
                      'booking_id': generatedBookingId,

                      // ১. Booking Summary Screen
                      ...widget.bookingData,
                      'payment_method': _selectedMethod,
                      'sender_account_or_number': _numberController.text.trim(),
                      'transaction_id': _trxController.text.trim(),
                      'extra_bank_info': _extraController.text.trim(),
                      'payment_amount': widget.amount,
                      'payment_status': 'Pending',
                      'submitted_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                      'transaction_image_file': kIsWeb ? _selectedImageBytes : _selectedImageFile,
                      'transaction_image_name': _imageName,
                    };

                    try {
                      await DatabaseHelper.instance.insertBookingWithTransactionImage(finalPaymentAndBookingData);
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.pop(context);
                        _showSuccessSnack(context);
                      }
                    }
                    catch (e) {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to submit booking: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                )
                    : const Text(
                  "Confirm Submission",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.primaryAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: widget.primaryAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _ourAccountDetails["label"]!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.primaryAccent,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _ourAccountDetails["info"]!,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          Text(
            "Send ${widget.amount.toStringAsFixed(0)} BDT then submit the details below.",
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: widget.primaryAccent, size: 20),
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
          validator: (v) => v!.isEmpty ? "This info is required" : null,
        ),
      ],
    );
  }

  Widget _buildStatusAlert() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Our team will verify the transaction manually to confirm your booking.",
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment details submitted for review!")),
    );
  }
}