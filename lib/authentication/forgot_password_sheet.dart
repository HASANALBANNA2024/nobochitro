import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nobochitro/authentication/otp_sheet.dart';

class ForgotPasswordModalSheet extends StatefulWidget {
  const ForgotPasswordModalSheet({super.key});

  @override
  State<ForgotPasswordModalSheet> createState() => _ForgotPasswordModalSheetState();
}

class _ForgotPasswordModalSheetState extends State<ForgotPasswordModalSheet> {
  bool _isEmailMode = true;
  final _identifierController = TextEditingController();
  bool _isLoading = false; // Loading indicator add

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  // Email Reset Link
  Future<void> _sendEmailReset() async {
    final String email = _identifierController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      Navigator.pop(context); // sheet close
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reset link sent! Please check your email inbox or spam.")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = Theme.of(context).primaryColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 700;
        double horizontalPadding = isDesktop ? constraints.maxWidth * 0.2 : 30;

        return Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white30 : Colors.black26,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isDesktop ? 500 : double.infinity),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 30 : horizontalPadding,
                          25,
                          isDesktop ? 30 : horizontalPadding,
                          MediaQuery.of(context).viewInsets.bottom + 15,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/images/app_icon.png', height: 70),
                            const SizedBox(height: 20),

                            const Text(
                              "Forgot Password?",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),

                            Text(
                              _isEmailMode
                                  ? "Enter your email to receive a reset link."
                                  : "Enter your phone number to receive an OTP code.",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 25),

                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  _buildTab("Email", _isEmailMode, () => setState(() => _isEmailMode = true)),
                                  _buildTab("Phone", !_isEmailMode, () => setState(() => _isEmailMode = false)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),

                            _buildField(
                              context,
                              _isEmailMode ? "Enter Email" : "Enter Phone Number",
                              _isEmailMode ? Icons.email_outlined : Icons.phone_android_outlined,
                              isDesktop,
                              controller: _identifierController,
                              keyboardType: _isEmailMode ? TextInputType.emailAddress : TextInputType.phone,
                            ),
                            const SizedBox(height: 25),

                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                if (_identifierController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter value!")));
                                  return;
                                }

                                if (_isEmailMode) {
                                  // Direct Email Reset function call
                                  _sendEmailReset();
                                } else {
                                  // Phone mode for otp screen
                                  Navigator.pop(context);
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => const OTPModalSheet(),
                                  );
                                }
                              },
                              child: Text(
                                _isEmailMode ? "SEND RESET LINK" : "SEND CODE",
                                style: TextStyle(
                                  color: isDark ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(String title, bool isActive, VoidCallback onTap) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, String hint, IconData icon, bool isDesktop,
      {required TextEditingController controller, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: isDesktop ? 16 : 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor, size: isDesktop ? 22 : 20),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}