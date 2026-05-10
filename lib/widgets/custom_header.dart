import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth যোগ করা হয়েছে
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore যোগ করা হয়েছে
import 'package:nobochitro/authentication/login_screen.dart';
import 'package:nobochitro/authentication/registration_modal_sheet.dart';
import 'package:nobochitro/client_profile/client_profile_screen.dart';
import 'package:nobochitro/screens/search_screen.dart';
import 'package:nobochitro/widgets/custom_search_bar.dart';

class CustomHeader extends StatelessWidget {
  final Color primaryAccent;
  final VoidCallback onMenuPressed;

  const CustomHeader({
    super.key,
    required this.primaryAccent,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool showSearchBar = screenWidth > 900;
    final bool showLogoText = screenWidth > 600;
    final bool isWebView = screenWidth > 1100;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.05)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isWebView ? 12 : 8,
              vertical: 12
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ১. লোগো সেকশন
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isWebView)
                    IconButton(
                      padding: const EdgeInsets.only(right: 4),
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: onMenuPressed,
                    ),
                  Image.asset(
                    'assets/images/app_icon.png',
                    height: showLogoText ? 35 : 28,
                    fit: BoxFit.contain,
                  ),
                  if (showLogoText) ...[
                    const SizedBox(width: 8),
                    Text(
                      'NoboChitro',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),

              const Spacer(),

              // ২. ডান পাশের সেকশন (সার্চ + লগইন/নাম)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showSearchBar) ...[
                    Container(
                      width: screenWidth * 0.45,
                      constraints: const BoxConstraints(maxWidth: 600, minWidth: 250),
                      child: CustomSearchBar(onSearch: (value) {}),
                    ),
                    const SizedBox(width: 20),
                  ],

                  if (!showSearchBar) ...[
                    IconButton(
                      icon: const Icon(Icons.search_rounded, size: 24),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const SearchScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 15),
                  ],

                  // ৩. স্ট্যাটাস চেক (লগইন থাকলে নাম, না থাকলে বাটন)
                  StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        // লগইন থাকলে নাম দেখাবে
                        return _buildUserGreeting(context, snapshot.data!.uid);
                      } else {
                        // লগইন না থাকলে বাটন দেখাবে
                        return _buildActionButtons(context, isWebView);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // লগইন থাকা অবস্থায় ইউজারের নাম দেখানোর উইজেট
  Widget _buildUserGreeting(BuildContext context, String uid) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        String name = "User";
        if (snapshot.hasData && snapshot.data!.exists) {
          name = (snapshot.data!.get('name') as String).split(' ')[0];
        }

        return PopupMenuButton(
          offset: const Offset(0, 45),
          child: Row(
            children: [
              const Icon(Icons.account_circle_outlined, size: 22),
              const SizedBox(width: 6),
              Text(
                "$name",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'profile', child: Text("Profile")),
            const PopupMenuItem(
              value: 'logout',
              child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
          onSelected: (value) async {
            if (value == 'logout') {
              await FirebaseAuth.instance.signOut();
            }
            if(value == 'profile'){
              Navigator.push(context, MaterialPageRoute(builder: (_)=> ClientProfileScreen() ));
            }
          },
        );
      },
    );
  }

  // লগইন না থাকলে লগইন/সাইন-আপ বাটন
  Widget _buildActionButtons(BuildContext context, bool showSignUp) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const LoginModalSheet());
          },
          child: Text(
            'Login',
            style: TextStyle(color: primaryAccent, fontWeight: FontWeight.w600),
          ),
        ),
        if (showSignUp) ...[
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const RegistrationModalSheet());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sign Up', style: TextStyle(fontSize: 12)),
          ),
        ],
      ],
    );
  }
}