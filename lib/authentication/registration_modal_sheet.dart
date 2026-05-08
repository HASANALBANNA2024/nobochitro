import 'package:flutter/material.dart';
import 'package:nobochitro/authentication/login_screen.dart';

class RegistrationModalSheet extends StatelessWidget {
  const RegistrationModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = Theme.of(context).primaryColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 700;
        // mobile and web view two side gap of sheet
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
                        // key open then padding adjustment
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 30 : horizontalPadding,
                          20,
                          isDesktop ? 30 : horizontalPadding,
                          MediaQuery.of(context).viewInsets.bottom + 15,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: accent,
                              ),
                            ),
                            const SizedBox(height: 25),

                            _buildField(context, "Full Name", Icons.person_outline, isDesktop),
                            const SizedBox(height: 15),

                            _buildField(context, "Email", Icons.email_outlined, isDesktop),
                            const SizedBox(height: 15),

                            // Mobile number field
                            _buildField(
                                context,
                                "Mobile Number",
                                Icons.phone_android_outlined,
                                isDesktop,
                                keyboardType: TextInputType.phone
                            ),
                            const SizedBox(height: 15),

                            _buildField(context, "Password", Icons.lock_outline, isDesktop, isPass: true),
                            const SizedBox(height: 15),

                            _buildField(context, "Confirm Password", Icons.lock_reset, isDesktop, isPass: true),
                            const SizedBox(height: 30),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                print("Registration Sheet Clicked");
                              },
                              child: Text(
                                "SIGN UP",
                                style: TextStyle(
                                  color: isDark ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an account? "),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    showModalBottomSheet(context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context)=> LoginModalSheet());
                                  },
                                  child: Text(
                                    "Login",
                                    style: TextStyle(color: accent, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
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

  Widget _buildField(BuildContext context, String hint, IconData icon, bool isDesktop,
      {bool isPass = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      obscureText: isPass,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      ),
    );
  }
}