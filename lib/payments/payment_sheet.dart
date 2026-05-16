import 'dart:io';
import 'dart:math'; // র্যান্ডম আইডি জেনারেট করার জন্য যুক্ত করা হলো
import 'dart:typed_data'; // ইউনিভার্সাল বাইটস হ্যান্ডল করার জন্য যুক্ত করা হলো
import 'package:flutter/foundation.dart'; // kIsWeb কন্ডিশন চেক করার জন্য
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class PaymentSheet extends StatefulWidget {
  final Color primaryAccent;
  final double amount;

  // জাস্ট এই একটি ম্যাপের ভেতরেই সব ডাটা (package_id, photographer_id, date, time, addons, location) চলে আসবে
  final Map<String, dynamic> bookingData;

  const PaymentSheet({
    super.key,
    required this.primaryAccent,
    required this.amount,
    required this.bookingData, // মাত্র ৩টি প্যারামিটারে চলে আসলো
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

  // ক্রস-প্ল্যাটফর্ম ইমেজ সিলেকশন ভ্যারিয়েবলসমূহ
  File? _selectedImageFile; // মোবাইলের লোকাল ফাইল অবজেক্ট ব্যাকআপ
  Uint8List? _selectedImageBytes; // অ্যান্ড্রয়েড, আইওএস এবং ওয়েব সব জায়গায় প্রিভিউ দেখানোর ইউনিভার্সাল ডাটা
  String _imageName = ""; // ইমেজের নাম দেখানোর জন্য

  final ImagePicker _picker = ImagePicker();

  // boolean
  bool _isLoading = false;

  // 🔴 ১০ ডিজিটের মিক্সড অলমেলো বুকিং আইডি জেনারেট করার অ্যালগরিদম ফাংশন
  String _generateMixedBookingId() {
    // আগের স্ক্রিন থেকে আসা নাম ও ইমেইল ক্যাচ করা (ডিফল্ট ব্যাকআপসহ)
    String name = (widget.bookingData['user_name'] ?? 'USER').toString().replaceAll(' ', '').toUpperCase();
    String email = (widget.bookingData['user_email'] ?? 'APP').toString().split('@')[0].toUpperCase();

    // মিক্স করার বেস সোর্স তৈরি
    String baseSource = "$name$email" "NC2026";
    // যদি সোর্স টেক্সট ছোট হয়, তবে ক্যারেক্টার পুল দিয়ে ব্যাকআপ দেওয়া
    const String pool = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

    final random = Random();
    List<String> idChars = [];

    // ১. নামের প্রথম থেকে বা র্যান্ডম ২ ক্যারেক্টার নেওয়া
    if (name.length >= 2) {
      idChars.add(name[random.nextInt(name.length)]);
      idChars.add(name[random.nextInt(name.length)]);
    } else {
      idChars.add(pool[random.nextInt(pool.length)]);
      idChars.add(pool[random.nextInt(pool.length)]);
    }

    // ২. ইমেইল থেকে ২ ক্যারেক্টার নেওয়া
    if (email.length >= 2) {
      idChars.add(email[random.nextInt(email.length)]);
      idChars.add(email[random.nextInt(email.length)]);
    } else {
      idChars.add(pool[random.nextInt(pool.length)]);
      idChars.add(pool[random.nextInt(pool.length)]);
    }

    // ৩. বাকি ৬ ডিজিট র্যান্ডম ক্যারেক্টার ও টাইমস্ট্যাম্প দিয়ে ১০ ডিজিট পূরণ করা
    while (idChars.length < 10) {
      if (random.nextBool() && baseSource.isNotEmpty) {
        idChars.add(baseSource[random.nextInt(baseSource.length)]);
      } else {
        idChars.add(pool[random.nextInt(pool.length)]);
      }
    }

    // সবকিছুকে এলোমেলো (Shuffle) করে ১০ ডিজিটের স্ট্রিং বানানো
    idChars.shuffle(random);
    return idChars.join().substring(0, 10);
  }

  // ইউনিভার্সাল ImagePicker ফাংশন (Web + Mobile ফ্রেন্ডলি)
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      // ইমেজ ফাইল থেকে ডিরেক্ট বাইটস রিড করা হলো
      final Uint8List bytes = await pickedFile.readAsBytes();

      setState(() {
        _selectedImageBytes = bytes;
        _imageName = pickedFile.name;
        // ওয়েব প্ল্যাটফর্মে ডিরেক্ট লোকাল ফাইল পাথ এক্সিস্ট করে না, তাই কন্ডিশনাল অ্যাসাইনমেন্ট
        if (!kIsWeb) {
          _selectedImageFile = File(pickedFile.path);
        }
      });
    }
  }

  // মেথড অনুযায়ী আমাদের অ্যাকাউন্ট ডিটেইলস
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

                    // পেমেন্ট মেথড সিলেক্টর
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

                    // ইনপুট ফিল্ড ১: ইউজার অ্যাকাউন্ট বা ব্যাংক নাম
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

                    // ইনপুট ফিল্ড ২: TrxID বা রেফারেন্স
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

                    // ব্যাংক বা কার্ডের জন্য অতিরিক্ত ফিল্ড (অ্যাকাউন্ট হোল্ডার নাম)
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
                              // Image.memory ব্যবহার করায় এখন Web, Android, iOS সব প্ল্যাটফর্মে প্রিভিউ পারফেক্টলি আসবে
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

                    // 🔴 ১০ ডিজিটের কাস্টম মিক্সড অলমেলো আইডি জেনারেট করা হলো
                    final String generatedBookingId = _generateMixedBookingId();

                    // -------------------------------------------------------------
                    // ডাটাবেসে ডেটা পাঠানোর কমপ্লিট অবজেক্ট স্ট্রাকচার
                    // -------------------------------------------------------------
                    final Map<String, dynamic> finalPaymentAndBookingData = {
                      // 🔴 কাস্টম জেনারেটেড আইডিটি 'booking_id' কলামের জন্য ম্যাপের প্রথমে পুশ করা হলো
                      'booking_id': generatedBookingId,

                      // ১. Booking Summary Screen থেকে আসা সমস্ত প্রিভিয়াস ডাটা
                      ...widget.bookingData,

                      // ২. এই শীট থেকে ইউজার ইনপুট করা পেমেন্ট ভেরিфикации ডাটা
                      'payment_method': _selectedMethod,
                      'sender_account_or_number': _numberController.text.trim(),
                      'transaction_id': _trxController.text.trim(),
                      'extra_bank_info': _extraController.text.trim(),
                      'payment_amount': widget.amount,
                      'payment_status': 'Pending', // অ্যাডমিন ভেরিফাই করার আগ পর্যন্ত পেন্ডিং থাকবে
                      'submitted_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),

                      // ৩. সিলেক্টেড ট্রানজেকশন ডাটা (মোবাইলের জন্য File অবজেক্ট, আর ওয়েবের জন্য ডিরেক্ট Bytes অবজেক্ট)
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