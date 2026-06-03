import 'package:flutter/material.dart';

import '../screens/dashboard_screen.dart';

class PrivacySecurityView extends StatelessWidget {
  final Function(bool) onThemeChanged;
  const PrivacySecurityView({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy & Security"),
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DashboardScreen(onThemeChanged: onThemeChanged),
              ),
            );
          },
        ),
      ),

      body: Center(
        child: Container(
          width: isLargeScreen ? 1000 : double.infinity,
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              // 1. Legal & Support Section
              _buildSectionTitle("Legal & Support", theme),

              _buildLegalContent(
                "Refund Policy",
                "আমাদের রিফান্ড পলিসি অনুযায়ী, আপনি বুকিং কনফার্ম হওয়ার ২৪ ঘণ্টার মধ্যে রিফান্ড রিকোয়েস্ট করতে পারবেন। এরপর রিফান্ড প্রযোজ্য হবে না। প্রয়োজনে আমাদের সাপোর্ট টিমের সাথে যোগাযোগ করুন।",
              ),
              const SizedBox(height: 16),

              _buildLegalContent(
                "Terms of Service",
                "নভোচিত্র ব্যবহার করার অর্থ হলো আপনি আমাদের সকল নিয়ম ও শর্তাবলি মেনে নিয়েছেন। কোনো অসদাচরণ পাওয়া গেলে অ্যাকাউন্ট বাতিল হতে পারে। ব্যবহারকারীকে অবশ্যই অ্যাকাউন্টের গোপনীয়তা বজায় রাখতে হবে।",
              ),
              const SizedBox(height: 16),

              _buildLegalContent(
                "Privacy Policy",
                "আমরা আপনার ব্যক্তিগত তথ্য সুরক্ষিত রাখতে প্রতিশ্রুতিবদ্ধ। আপনার ডাটা শুধুমাত্র অ্যাপের প্রয়োজনে ব্যবহৃত হয় এবং তৃতীয় কোনো পক্ষকে প্রদান করা হয় না। আপনার গোপনীয়তাই আমাদের অগ্রাধিকার।",
              ),
              const SizedBox(height: 16),

              _buildLegalContent(
                "Help & Support",
                "কোনো সমস্যা বা জিজ্ঞাসার জন্য আমাদের কাস্টমার সাপোর্ট টিমের সাথে সরাসরি যোগাযোগ করুন। ইমেইল: support@nobochitro.com অথবা আমাদের হটলাইন নম্বরে কল করুন (+8801580361198)।",
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// section title
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
        ),
      ),
    );
  }

  /// content and paragraph design
  Widget _buildLegalContent(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.grey),
        ),
      ],
    );
  }
}
