import 'package:flutter/material.dart';

class HeroBanner extends StatelessWidget {
  final Color primaryAccent;

  const HeroBanner({
    super.key,
    required this.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Responsive check
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = screenWidth > 800;
    final bool isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            // আপনার দেওয়া হাইট ঠিক রাখা হয়েছে
            constraints: BoxConstraints(
              minHeight: isWeb ? 280 : 200,
              maxHeight: isWeb ? 350 : 250,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1519741497674-611481863552?w=1000'),
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
            child: Stack(
              children: [
                // ১. উন্নত গ্রেডিয়েন্ট (ডার্ক ও লাইট মোডে টেক্সট ফুটানোর জন্য)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft, // বাম থেকে ডানে স্মুথ ফেইড
                        end: Alignment.centerRight,
                        colors: [
                          // ডার্ক মোডে একটু বেশি গাঢ়, লাইট মোডেও ক্লিয়ার রাখার জন্য
                          Colors.black.withOpacity(isDark ? 0.9 : 0.8),
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                // ২. কন্টেন্ট এরিয়া (Column)
                Padding(
                  padding: EdgeInsets.all(isWeb ? 40 : 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // কন্টেন্ট মাঝখানে থাকবে
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // টাইটেল (Flex এবং Overflow প্রোটেকশনসহ)
                      Flexible(
                        child: Text(
                          'Unveil Your Story\'s\nLight – Today!',
                          style: textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                            // রেসপনসিভ ফন্ট সাইজ যা স্ক্রিন অনুযায়ী অ্যাডজাস্ট হবে
                            fontSize: screenWidth < 360 ? 20 : (isWeb ? 36 : 26),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // বাটন (ওভারফ্লো ঠেকাতে ফিক্সড হাইট ও প্যাডিং)
                      SizedBox(
                        height: isWeb ? 45 : 38,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: isWeb ? 30 : 20),
                          ),
                          child: Text(
                            'Explore Now',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isWeb ? 14 : 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ৩. অ্যাপ আইকন (সবসময় উপরে পজিশন করা)
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: isWeb ? 45 : 30,
                      height: isWeb ? 45 : 30,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => Icon(
                        Icons.auto_awesome,
                        color: const Color(0xFFFFD700),
                        size: isWeb ? 30 : 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}