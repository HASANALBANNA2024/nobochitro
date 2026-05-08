import 'package:flutter/material.dart';
import 'package:nobochitro/authentication/forgot_password_sheet.dart';
import 'package:nobochitro/authentication/registration_modal_sheet.dart';

class LoginModalSheet extends StatelessWidget {
  const LoginModalSheet({super.key});

  @override
  Widget build(BuildContext context) {

    //Theme and Dark mode check
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = Theme.of(context).primaryColor;

    // ২. LayoutBuilder
    return LayoutBuilder(
      builder: (context, constraints) {
        // screen width for
        final bool isWeb = constraints.maxWidth > 700;

        // is web
        double horizontalPadding = isWeb ? constraints.maxWidth * 0.2 : 30;

        // Material
        return Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drug Handle
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: isDark ? Colors.white30 : Colors.black26, borderRadius: BorderRadius.circular(5)),
              ),
              const SizedBox(height: 10),

              //UI Content
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,

                  // Center
                  child: Center(
                    child: ConstrainedBox(
                      // ৪. ConstrainedBox:
                      constraints: BoxConstraints(maxWidth: isWeb ? 500 : double.infinity),

                      // ৫. SingleChildScrollView:
                      child: SingleChildScrollView(
                        // if keyboard open and against overflow
                        padding: EdgeInsets.fromLTRB(
                          isWeb ? 30 : horizontalPadding,
                          20,
                          isWeb ? 30 : horizontalPadding,
                          MediaQuery.of(context).viewInsets.bottom + 10,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            Image.asset('assets/images/app_icon.png', height: isWeb ? 80 : 70),
                            const SizedBox(height: 15),

                            //Title
                            Text("Login", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: accent)),
                            const SizedBox(height: 25),

                            // Email input field
                            _buildTextField(context, "Email", Icons.email_outlined, isWeb),
                            const SizedBox(height: 15),

                            // password filed
                            _buildTextField(context, "Password", Icons.lock_outline, isWeb, isPassword: true),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context); //
                                  showModalBottomSheet(context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context)=> ForgotPasswordModalSheet());
                                },
                                child: Text("Forgot Password?", style: TextStyle(color: accent, fontSize:isWeb ? 14 : 13)),
                              ),
                            ),
                            const SizedBox(height: 15),

                            // LOGIN Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                print("clicked on login");
                              },
                              child: Text("LOGIN", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            const SizedBox(height: 20),

                            // Sign Up
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account? ", style: TextStyle(fontSize:isWeb? 14 : 13)),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    showModalBottomSheet(context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context)=> RegistrationModalSheet() );

                                  },
                                  child: Text("Sign Up", style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: isWeb? 14 : 13)),
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

  /// helper widgets
  Widget _buildTextField(BuildContext context, String hint, IconData icon, bool isWeb, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: isWeb ? 16 : 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor, size: isWeb ? 22 : 20),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      ),
    );
  }
}