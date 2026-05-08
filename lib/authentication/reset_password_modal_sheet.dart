import 'package:flutter/material.dart';

class ResetPasswordModalSheet extends StatelessWidget {
  const ResetPasswordModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme and dark mode check
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
                        // after key board open then padding adjustment
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 30 : horizontalPadding,
                          30,
                          isDesktop ? 30 : horizontalPadding,
                          MediaQuery.of(context).viewInsets.bottom + 20,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // --- app_icon ---
                            Image.asset('assets/images/app_icon.png', height: 70),
                            const SizedBox(height: 25),

                            const Text(
                              "Set New Password",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),

                            const Text(
                              "Create a strong password to secure your account.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            const SizedBox(height: 35),

                            // New Password field
                            _buildField(context, "New Password", Icons.lock_outline, isDesktop, isPass: true),
                            const SizedBox(height: 15),

                            // Confirm Password field
                            _buildField(context, "Confirm New Password", Icons.lock_reset, isDesktop, isPass: true),
                            const SizedBox(height: 35),

                            // UPDATE PASSWORD Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                // Password update logic
                                print("Password successfully updated!");
                                Navigator.pop(context); // Sheet close
                              },
                              child: Text(
                                "UPDATE PASSWORD",
                                style: TextStyle(
                                  color: isDark ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
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

  // Helper Widgets
  Widget _buildField(BuildContext context, String hint, IconData icon, bool isDesktop, {bool isPass = false}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      obscureText: isPass,
      style: TextStyle(fontSize: isDesktop ? 16 : 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor, size: isDesktop ? 22 : 20),
        filled: true,
        fillColor: Theme.of(context).cardColor,

        // border logic
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}