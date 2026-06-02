import 'package:flutter/material.dart';

class HeroBanner extends StatelessWidget {
  final Color primaryAccent;

  const HeroBanner({super.key, required this.primaryAccent});

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
            constraints: BoxConstraints(
              minHeight: isWeb ? 280 : 200,
              maxHeight: isWeb ? 350 : 250,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1519741497674-611481863552?w=1000',
                ),
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(isDark ? 0.9 : 0.8),
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(isWeb ? 40 : 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          'Unveil Your Story\'s\nLight – Today!',
                          style: textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                            fontSize: screenWidth < 360
                                ? 20
                                : (isWeb ? 36 : 26),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 12),

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
                            padding: EdgeInsets.symmetric(
                              horizontal: isWeb ? 30 : 20,
                            ),
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
