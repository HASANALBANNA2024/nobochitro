import 'package:flutter/material.dart';

class CategoriesGrid extends StatelessWidget {
  final Color primaryAccent;

  const CategoriesGrid({
    super.key,
    required this.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // --- DATA SECTION (Logic inside the file) ---
    // You can add or remove categories here in the future
    final List<Map<String, dynamic>> categories = [
      {'name': 'Wedding', 'icon': Icons.favorite_rounded},
      {'name': 'Newborn', 'icon': Icons.child_care_rounded},
      {'name': 'Birthday', 'icon': Icons.cake_rounded},
      {'name': 'Travel', 'icon': Icons.terrain_rounded},
      {'name': 'Event', 'icon': Icons.theater_comedy_rounded},
      {'name': 'Portrait', 'icon': Icons.portrait_rounded}, // Added extra for variety
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(), // Smooth scrolling
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];

          return Padding(
            padding: const EdgeInsets.only(right: 25),
            child: InkWell(
              onTap: () {
                // TODO: Firebase/n8n Logic for category filtering
              },
              borderRadius: BorderRadius.circular(30),
              child: Column(
                children: [
                  // Icon Circle
                  CircleAvatar(
                    backgroundColor: primaryAccent.withOpacity(0.1),
                    radius: 30,
                    child: Icon(
                        cat['icon'],
                        color: primaryAccent,
                        size: 28
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Category Name
                  Text(
                    cat['name'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface, // Adapts to Dark/Light mode
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/*
  ---------------------------------------------------------
  FUTURE INTEGRATION GUIDE:
  ---------------------------------------------------------

  1. FIREBASE/LIVE DATA:
     - To make these categories dynamic, fetch them from Firestore
       and replace the 'categories' list with the fetched data.

  2. N8N INTEGRATION:
     - If you use n8n to manage category names or icons via an API,
       fetch the API response in your Dashboard and pass it here.

  3. DARK & LIGHT MODE:
     - Uses 'theme.textTheme' and 'colorScheme.onSurface' to ensure
       text is visible regardless of the theme mode.
  ---------------------------------------------------------
*/