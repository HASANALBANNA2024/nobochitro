import 'package:flutter/material.dart';

class PhotographerSelector extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> photographersFuture;
  final Function(Map<String, dynamic>) onPhotographerSelected;

  const PhotographerSelector({
    super.key,
    required this.photographersFuture,
    required this.onPhotographerSelected,
  });

  @override
  State<PhotographerSelector> createState() => _PhotographerSelectorState();
}

class _PhotographerSelectorState extends State<PhotographerSelector> {
  int? _selectedPhotographerIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: widget.photographersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 210,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 210,
            child: Center(child: Text("No photographers found")),
          );
        }

        final photographers = snapshot.data!;
        return SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            itemCount: photographers.length,
            itemBuilder: (context, index) {
              return _buildEnhancedPhotographerCard(
                photographers[index],
                theme,
                isDark,
                context,
                index,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEnhancedPhotographerCard(
      Map<String, dynamic> photographer,
      ThemeData theme,
      bool isDark,
      BuildContext context,
      int index,
      ) {
    final accentColor = theme.colorScheme.primary;
    final isSelected = _selectedPhotographerIndex == index;

    return Padding(
      padding: const EdgeInsets.only(right: 20, bottom: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPhotographerIndex = index;
          });
          // মেইন স্ক্রিনে ডাটা পাঠানোর জন্য কলব্যাক
          widget.onPhotographerSelected(photographer);
        },
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 160,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withOpacity(isDark ? 0.15 : 0.05)
                : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : (isDark ? Colors.white12 : Colors.black.withOpacity(0.08)),
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? accentColor.withOpacity(0.2)
                    : Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? accentColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: NetworkImage(
                        photographer['profile_image_url'] ??
                            "https://via.placeholder.com/150",
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 16),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                photographer['name'] ?? "Unknown Artist",
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  photographer['specialty'] ?? "Wedding Expert",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payments_outlined,
                      size: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    "${photographer['per_hours_fee'] ?? '0'} BDT/hr",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}