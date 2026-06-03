import 'package:flutter/material.dart';

import '../screens/dashboard_screen.dart';

class HelpCenterView extends StatelessWidget {
  final Function(bool) onThemeChanged;

  const HelpCenterView({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
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
          /// web screen width
          width: isLargeScreen ? 1000 : double.infinity,
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              _buildSectionTitle("সহায়তা ও যোগাযোগ", theme),

              _buildHelpCard(
                Icons.support_agent,
                "কাস্টমার সাপোর্ট",
                "যেকোনো সমস্যায় আমাদের সরাসরি কল করুন: +8801580361198",
              ),
              const SizedBox(height: 16),

              _buildHelpCard(
                Icons.email,
                "ইমেইল সাপোর্ট",
                "আপনার সমস্যার বিস্তারিত পাঠান: support@nobochitro.com",
              ),
              const SizedBox(height: 16),

              _buildSectionTitle("সাধারণ জিজ্ঞাসা (FAQ)", theme),

              _buildFaqItem(
                "বুকিং কীভাবে করব?",
                "ড্যাশবোর্ডের মেনু থেকে বুকিং অপশনে গিয়ে প্রয়োজনীয় তথ্য দিয়ে বুকিং সম্পন্ন করুন।",
              ),
              _buildFaqItem(
                "রিফান্ড পলিসি কী?",
                "বুকিং কনফার্ম হওয়ার ২৪ ঘণ্টার মধ্যে রিফান্ড রিকোয়েস্ট গ্রহণযোগ্য।",
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildHelpCard(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer, style: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
