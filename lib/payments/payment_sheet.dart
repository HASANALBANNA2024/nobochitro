import 'package:flutter/material.dart';

class PaymentSheet extends StatefulWidget {
  final Color primaryAccent;
  final double amount;

  const PaymentSheet({
    super.key,
    required this.primaryAccent,
    required this.amount,
  });

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  String _selectedMethod = "bKash";
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _numberController =
      TextEditingController(); // Number or Bank Name
  final TextEditingController _trxController =
      TextEditingController(); // TrxID or Reference
  final TextEditingController _extraController =
      TextEditingController(); // Extra info (Branch/Name)

  // মেথড অনুযায়ী আমাদের অ্যাকাউন্ট ডিটেইলস
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
      height: MediaQuery.of(context).size.height * 0.75,
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

                    // আমাদের পেমেন্ট রিসিভিং ইনফো কার্ড
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                    _showSuccessSnack(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
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
