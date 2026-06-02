import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nobochitro/authentication/forgot_password_sheet.dart';
import 'package:nobochitro/authentication/registration_modal_sheet.dart';

import 'auth_service.dart';

class LoginModalSheet extends StatefulWidget {
  const LoginModalSheet({super.key});

  @override
  State<LoginModalSheet> createState() => _LoginModalSheetState();
}

class _LoginModalSheetState extends State<LoginModalSheet> {
  final _identifierController = TextEditingController();
  final _passController = TextEditingController();
  final AuthService _auth = AuthService();

  bool _isLoading = false;
  bool _isEmailMode = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passController.dispose();
    super.dispose();
  }

  bool _isNumeric(String s) => double.tryParse(s) != null;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = Theme.of(context).primaryColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWeb = constraints.maxWidth > 700;
        double horizontalPadding = isWeb ? constraints.maxWidth * 0.2 : 30;

        return Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWeb ? 500 : double.infinity,
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              isWeb ? 30 : horizontalPadding,
                              20,
                              isWeb ? 30 : horizontalPadding,
                              20,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/app_icon.png',
                                  height: isWeb ? 80 : 70,
                                ),
                                const SizedBox(height: 15),

                                Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(height: 25),

                                /// ----- professional toggle button ---
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildToggleButton(
                                        context,
                                        "Email",
                                        _isEmailMode,
                                        () {
                                          setState(() {
                                            _isEmailMode = true;
                                            _identifierController.clear();
                                          });
                                        },
                                      ),
                                      _buildToggleButton(
                                        context,
                                        "Phone",
                                        !_isEmailMode,
                                        () {
                                          setState(() {
                                            _isEmailMode = false;
                                            _identifierController.clear();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                /// Email or Phone Input Field
                                _buildTextField(
                                  context,
                                  _isEmailMode
                                      ? "Email Address"
                                      : "Phone Number",
                                  _isEmailMode
                                      ? Icons.email_outlined
                                      : Icons.phone_android_outlined,
                                  isWeb,
                                  controller: _identifierController,
                                  keyboardType: _isEmailMode
                                      ? TextInputType.emailAddress
                                      : TextInputType.phone,
                                ),
                                const SizedBox(height: 15),

                                _buildTextField(
                                  context,
                                  "Password",
                                  Icons.lock_outline,
                                  isWeb,
                                  controller: _passController,
                                  isPassword: true,
                                ),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            const ForgotPasswordModalSheet(),
                                      );
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                        color: accent,
                                        fontSize: isWeb ? 14 : 13,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // login button logic
                                _isLoading
                                    ? const CircularProgressIndicator()
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accent,
                                          minimumSize: const Size(
                                            double.infinity,
                                            50,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed: () async {
                                          String input = _identifierController
                                              .text
                                              .trim();
                                          String password = _passController.text
                                              .trim();

                                          if (input.isEmpty ||
                                              password.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Please fill all fields!",
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          setState(() => _isLoading = true);

                                          String loginEmail = input;

                                          if (!_isEmailMode ||
                                              _isNumeric(input)) {
                                            String formattedSearchPhone = input;
                                            if (!formattedSearchPhone
                                                .startsWith('+88')) {
                                              if (formattedSearchPhone
                                                  .startsWith('88')) {
                                                formattedSearchPhone =
                                                    '+$formattedSearchPhone';
                                              } else if (formattedSearchPhone
                                                  .startsWith('0')) {
                                                formattedSearchPhone =
                                                    '+88$formattedSearchPhone';
                                              } else {
                                                formattedSearchPhone =
                                                    '+880$formattedSearchPhone';
                                              }
                                            }

                                            try {
                                              var userQuery =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .where(
                                                        'phone',
                                                        isEqualTo:
                                                            formattedSearchPhone,
                                                      )
                                                      .limit(1)
                                                      .get();

                                              if (userQuery.docs.isNotEmpty) {
                                                loginEmail = userQuery
                                                    .docs
                                                    .first
                                                    .get('email');
                                              } else {
                                                setState(
                                                  () => _isLoading = false,
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Phone number not found!",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                            } catch (e) {
                                              setState(
                                                () => _isLoading = false,
                                              );
                                              print(
                                                "Firestore Query Error: $e",
                                              );
                                              return;
                                            }
                                          }

                                          var user = await _auth.logIn(
                                            loginEmail,
                                            password,
                                          );

                                          setState(() => _isLoading = false);

                                          if (user != null) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Login Successful!",
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Login Failed! Check credentials.",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          "LOGIN",
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                const SizedBox(height: 20),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextStyle(
                                        fontSize: isWeb ? 14 : 13,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) =>
                                              const RegistrationModalSheet(),
                                        );
                                      },
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          color: accent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isWeb ? 14 : 13,
                                        ),
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
            ),
          ),
        );
      },
    );
  }

  // টগল বাটন তৈরির হেল্পার
  Widget _buildToggleButton(
    BuildContext context,
    String title,
    bool isActive,
    VoidCallback onTap,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.transparent,
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

  Widget _buildTextField(
    BuildContext context,
    String hint,
    IconData icon,
    bool isWeb, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: isWeb ? 16 : 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: isWeb ? 22 : 20,
        ),
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
