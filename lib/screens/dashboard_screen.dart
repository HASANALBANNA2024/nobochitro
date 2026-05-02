import 'package:flutter/material.dart';
import 'package:nobochitro/widgets/custom_bottom_nav.dart';
import 'package:nobochitro/widgets/custom_header.dart';
import 'package:nobochitro/widgets/custom_side_navigation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;




  // ১. ড্রয়ার কন্ট্রোল করার জন্য গ্লোবাল কী
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryAccent = isDarkMode ? const Color(0xFFD4AF37) : const Color(0xFF008080);
    final background = isDarkMode ? const Color(0xFF0F0F0F) : theme.scaffoldBackgroundColor;

    bool isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      key: _scaffoldKey, // ২. কী-টি এখানে অ্যাসাইন করুন
      backgroundColor: background,

      // আপনার রিকয়ারমেন্ট: মোবাইলে ড্রয়ার থাকবে না, শুধু ওয়েবে থাকবে
      drawer: isLargeScreen
          ? CustomSideNavigation(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
      )
          : null,

      body: Column(
        children: [
          // ৩. হেডার কল (এখান থেকে মেনু বাটন কন্ট্রোল হবে)
          CustomHeader(
            isLargeScreen: isLargeScreen,
            primaryAccent: primaryAccent,
            onMenuPressed: () {
              _scaffoldKey.currentState?.openDrawer(); // ড্রয়ার ওপেন করার সঠিক উপায়
            },
          ),

          Expanded(
            child: _buildMainContent(textTheme, colorScheme, isLargeScreen, primaryAccent, theme),
          ),
        ],
      ),

      bottomNavigationBar: isLargeScreen
          ? null
          : CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  // Build main content..
  Widget _buildMainContent(TextTheme textTheme, ColorScheme colorScheme, bool isLargeScreen, Color primaryAccent, ThemeData theme) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroBanner(textTheme, colorScheme, primaryAccent),
                  const SizedBox(height: 30),
                  Text('Explore Categories', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildCategoriesGrid(textTheme, colorScheme, primaryAccent, theme),
                  const SizedBox(height: 35),
                  _buildPhotographyPackages(textTheme, colorScheme, primaryAccent, theme),
                  const SizedBox(height: 35),
                  _buildCommunityGallery(textTheme, colorScheme, theme),
                  const SizedBox(height: 35),
                  _buildReviewsSection(textTheme, colorScheme, primaryAccent, theme),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isDarkMode(ThemeData theme) => theme.brightness == Brightness.dark;



  Widget _buildHeroBanner(TextTheme textTheme, ColorScheme colorScheme, Color primaryAccent) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        height: 320,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1519741497674-611481863552?w=1000'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              colors: [Colors.black.withOpacity(0.9), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Unveil Your Story\'s\nLight – Today!',
                  style: textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, height: 1.2)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)
                ),
                child: const Text('Explore Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(TextTheme textTheme, ColorScheme colorScheme, Color primaryAccent, ThemeData theme) {
    List<Map<String, dynamic>> cats = [
      {'n': 'Wedding', 'i': Icons.favorite_rounded},
      {'n': 'Newborn', 'i': Icons.child_care_rounded},
      {'n': 'Birthday', 'i': Icons.cake_rounded},
      {'n': 'Travel', 'i': Icons.terrain_rounded},
      {'n': 'Event', 'i': Icons.theater_comedy_rounded},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 25),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: primaryAccent.withOpacity(0.1),
                radius: 30,
                child: Icon(cats[index]['i'], color: primaryAccent, size: 28),
              ),
              const SizedBox(height: 10),
              Text(cats[index]['n'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotographyPackages(TextTheme textTheme, ColorScheme colorScheme, Color primaryAccent, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Exclusive Packages', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: Text('View All', style: TextStyle(color: primaryAccent))),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, constraints) {
          int count = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.85),
            itemCount: 3,
            itemBuilder: (context, index) => _buildPackageCard(colorScheme, textTheme, primaryAccent, theme),
          );
        }),
      ],
    );
  }

  Widget _buildPackageCard(ColorScheme colorScheme, TextTheme textTheme, Color primaryAccent, ThemeData theme) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Image.network(
                  'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400',
                  fit: BoxFit.cover,
                  width: double.infinity
              )
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cinematic Wedding', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 5),
                Text('Premier album & 4K video included',
                    style: TextStyle(fontSize: 13, color: textTheme.bodyMedium?.color?.withOpacity(0.6))),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$499', style: TextStyle(color: primaryAccent, fontWeight: FontWeight.bold, fontSize: 20)),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      child: const Text('Book', style: TextStyle(color: Colors.white)),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCommunityGallery(TextTheme textTheme, ColorScheme colorScheme, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Community Highlights', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) => Container(
              width: 240,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=500'), fit: BoxFit.cover),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildReviewsSection(TextTheme textTheme, ColorScheme colorScheme, Color primaryAccent, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What Clients Say', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildReviewCard(colorScheme, primaryAccent, theme, 'Hasan Al Banna', 'The lighting and composition were world-class! Highly recommend.'),
        const SizedBox(height: 12),
        _buildReviewCard(colorScheme, primaryAccent, theme, 'Sarah Jahan', 'Captured our anniversary so beautifully. A true artist.'),
      ],
    );
  }

  Widget _buildReviewCard(ColorScheme colorScheme, Color primaryAccent, ThemeData theme, String name, String review) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.onSurface.withOpacity(0.05))
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 25, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d')),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(children: List.generate(5, (index) => Icon(Icons.star_rounded, color: primaryAccent, size: 18))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(review, style: TextStyle(height: 1.4, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}