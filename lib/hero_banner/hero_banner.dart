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

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            // Constraints ensure height doesn't break on very small screens
            constraints: BoxConstraints(
              minHeight: isWeb ? 280 : 200,
              maxHeight: isWeb ? 350 : 250,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                // Future: Replace with Firebase/n8n dynamic URL
                image: NetworkImage('https://images.unsplash.com/photo-1519741497674-611481863552?w=1000'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
              padding: EdgeInsets.all(isWeb ? 40 : 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Flexible Headline to prevent vertical overflow
                  Flexible(
                    child: Text(
                      'Unveil Your Story\'s\nLight – Today!',
                      style: textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        // Responsive Font Size
                        fontSize: screenWidth < 360 ? 22 : (isWeb ? 40 : 28),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(height: isWeb ? 25 : 15),

                  // 2. Button with fixed constraints to prevent horizontal overflow
                  SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Firebase or n8n navigation logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                      ),
                      child: const Text(
                        'Explore Now',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
}

/*
  ---------------------------------------------------------
  PREVENTING OVERFLOW STRATEGY:
  ---------------------------------------------------------
  1. Flexible Widget: Used for the Title so it shrinks or wraps
     if the height of the container is limited.
  2. LayoutBuilder: Helps the widget adapt to its parent's constraints.
  3. Responsive Font: Font size decreases even further if the
     screen width is extremely small (under 360px).
  4. MaxLines: Ensures the text doesn't push the button out of
     view on very small mobile devices.
  ---------------------------------------------------------
*/