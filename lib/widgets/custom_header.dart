import 'package:flutter/material.dart';
import 'package:nobochitro/authentication/login_screen.dart';
import 'package:nobochitro/authentication/registration_modal_sheet.dart';
import 'package:nobochitro/screens/search_screen.dart';
import 'package:nobochitro/widgets/custom_search_bar.dart';

class CustomHeader extends StatelessWidget {
  final Color primaryAccent;
  final VoidCallback onMenuPressed;
  final bool isLoggedIn = false;

  const CustomHeader({
    super.key,
    required this.primaryAccent,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    //breakpoint
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
          // padding
          padding: EdgeInsets.symmetric(
              horizontal: isWebView ? 12 : 8,
              vertical: 12
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ১. বাম পাশে লোগো সেকশন (একদম বামে থাকবে)
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
                      'NoboChitro - নবচিত্র',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),

              // মাঝখানে Spacer লোগোকে বামে এবং বাকি সব কিছুকে ডানে ধাক্কা দিবে
              const Spacer(),

              // ২. ডান পাশের সেকশন (সার্চ বার এবং বাটন গ্রুপ - একদম ডানে থাকবে)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 5),
                  if (showSearchBar) ...[
                    Container(
                      // বড় স্ক্রিনে সার্চ বারকে আরও চওড়া (৫০০-৬০০ পিক্সেল) করা হয়েছে
                      width: screenWidth * 0.45,
                      constraints: const BoxConstraints(maxWidth: 600, minWidth: 250),
                      child: CustomSearchBar(
                        onSearch: (value) {
                          // search logic
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],

                  // মোবাইল/ট্যাবলেটে সার্চ আইকন
                  if (!showSearchBar) ...[
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.search_rounded, size: 24),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const SearchScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 15),
                  ],

                  // login and sigh up
                  _buildActionButtons(context, isWebView),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool showSignUp) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {
            showModalBottomSheet(context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const LoginModalSheet());
       },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Login',
            style: TextStyle(
              color: primaryAccent,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        if (showSignUp) ...[
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context)=> RegistrationModalSheet() );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }
}