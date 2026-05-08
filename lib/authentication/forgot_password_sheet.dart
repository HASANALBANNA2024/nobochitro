import 'package:flutter/material.dart';
import 'package:nobochitro/authentication/otp_sheet.dart';

class ForgotPasswordModalSheet extends StatelessWidget {
  const ForgotPasswordModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = Theme.of(context).primaryColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 700;
        // mobile view
        double horizontalPadding = isDesktop ? constraints.maxWidth * 0.2 : 30;

        return Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              // Drug Handler
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
                        // Key board open
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 30 : horizontalPadding,
                          25,
                          isDesktop ? 30 : horizontalPadding,
                          MediaQuery.of(context).viewInsets.bottom + 15,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // app icon
                            Image.asset('assets/images/app_icon.png', height: 70),
                            const SizedBox(height: 20),

                            const Text(
                              "Forgot Password?",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),

                            const Text(
                              "Enter your email to receive an OTP code.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 30),

                            // Email input field
                            _buildField(context, "Enter Email", Icons.email_outlined, isDesktop),
                            const SizedBox(height: 25),

                            // SEND CODE Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                showModalBottomSheet(context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context)=> OTPModalSheet());
                              },
                              child: Text(
                                "SEND CODE",
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

  // helper widgets
  Widget _buildField(BuildContext context, String hint, IconData icon, bool isDesktop) {
    return TextField(
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