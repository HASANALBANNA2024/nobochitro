import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nobochitro/authentication/login_screen.dart';
import 'auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrationModalSheet extends StatefulWidget {
  const RegistrationModalSheet({super.key});

  @override
  State<RegistrationModalSheet> createState() => _RegistrationModalSheetState();
}

class _RegistrationModalSheetState extends State<RegistrationModalSheet> {
  // Controller Create
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  final AuthService _auth = AuthService(); // Service Call
  bool _isLoading = false; // Loading State

  @override
  void dispose() {
    // dispose of memory leak
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
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

                            // Controller Field
                            _buildField(context, "Full Name", Icons.person_outline, isDesktop, controller: _nameController),
                            const SizedBox(height: 15),

                            _buildField(context, "Email", Icons.email_outlined, isDesktop, controller: _emailController, keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 15),

                            _buildField(context, "Mobile Number", Icons.phone_android_outlined, isDesktop, controller: _phoneController, keyboardType: TextInputType.phone),
                            const SizedBox(height: 15),

                            _buildField(context, "Password", Icons.lock_outline, isDesktop, controller: _passController, isPass: true),
                            const SizedBox(height: 15),

                            _buildField(context, "Confirm Password", Icons.lock_reset, isDesktop, controller: _confirmPassController, isPass: true),
                            const SizedBox(height: 30),

                            // Sign up Button and logic connect
                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: ()async {
                                if(_passController.text != _confirmPassController.text)
                                  {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password and Confirm Password must be same!")));
                                    return;
                                  }
                                setState(() {
                                  _isLoading = true;
                                });

                                // user unique identity number
                                String customId = "NSR-${Random().nextInt(900000) + 100000}";
                                // firebase sign up
                                var user = await _auth.signUp
                                  (
                                    name: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    password: _passController.text.trim(),
                                    phone: _phoneController.text.trim(),
                                    CustomId: customId,
                                );

                                if(user != null)
                                  {
                                    // formatted Number
                                    String rawPhone = _phoneController.text.trim();
                                    String formattedPhone = rawPhone;
                                    if (!rawPhone.startsWith('+88')) {
                                      if (rawPhone.startsWith('88')) {
                                        formattedPhone = '+$rawPhone';
                                      } else if (rawPhone.startsWith('0')) {
                                        formattedPhone = '+88$rawPhone';
                                      } else {
                                        formattedPhone = '+880$rawPhone';
                                      }
                                    }
                                    // formatted Number of End
                                    try{
                                      await Supabase.instance.client.from("users").insert(
                                          {
                                            'id': customId,
                                            'user_id':user.uid,
                                            'full_name':_nameController.text.trim(),
                                            'email':_emailController.text.trim(),
                                            'phone_number': formattedPhone,
                                            'user_role':'client',
                                          });
                                    } catch (e){
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      // Error
                                      Navigator.pop(context);
                                      print("Supabase Sync Error :$e");
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Created, But profile Sync Failed")));
                                    }
                                  }
                                else {
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration Failed. Try again.")));
                                }


                                Navigator.pop(context);


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
                                    showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context)=> const LoginModalSheet()
                                    );
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

  // Build Field TextEditingController to add
  Widget _buildField(BuildContext context, String hint, IconData icon, bool isDesktop,
      {bool isPass = false, TextInputType keyboardType = TextInputType.text, required TextEditingController controller}) {
    return TextField(
      controller: controller, // Controller Connect
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