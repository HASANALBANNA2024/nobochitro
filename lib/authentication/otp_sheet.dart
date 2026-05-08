import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nobochitro/authentication/reset_password_modal_sheet.dart';

class OTPModalSheet extends StatelessWidget {
  const OTPModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = Theme.of(context).primaryColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 700;
        // Mobile view
        double horizontalPadding = isDesktop ? constraints.maxWidth * 0.2 : 30;

        return Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              // drug handler
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
                        // key board padding
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 30 : horizontalPadding,
                          30,
                          isDesktop ? 30 : horizontalPadding,
                          MediaQuery.of(context).viewInsets.bottom + 20,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // --- app icon---
                            Image.asset('assets/images/app_icon.png', height: 70),
                            const SizedBox(height: 25),

                            const Text(
                              "OTP Verification",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),

                            const Text(
                              "Enter the 4-digit code sent to your email.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 35),

                            // OTP input row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(4, (index) => _otpBox(context, isDesktop)),
                            ),
                            const SizedBox(height: 40),

                            // VERIFY Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                // After verify otp then new screen of password set
                                Navigator.pop(context);

                                showModalBottomSheet(context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context)=> ResetPasswordModalSheet() );
                              },
                              child: Text(
                                "VERIFY",
                                style: TextStyle(
                                  color: isDark ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            // Resend code
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () {
                                print("Resend Code Clicked");
                              },
                              child: Text(
                                "Resend Code",
                                style: TextStyle(color: accent, fontWeight: FontWeight.w600),
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

  // OTP Box Helper
  Widget _otpBox(BuildContext context, bool isDesktop) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: isDesktop ? 70 : 60,
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus(); // on click to come next
          } else if (value.isEmpty) {
            FocusScope.of(context).previousFocus(); // on delete to return
          }
        },
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Theme.of(context).cardColor,

          // Color Normal situation
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.black12,
              width: 1,
            ),
          ),

          // Color of After click
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),

          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}