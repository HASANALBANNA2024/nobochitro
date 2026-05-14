import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class AddOnsSelector extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onSelectionChanged;

  const AddOnsSelector({
    super.key,
    required this.onSelectionChanged,
  });

  @override
  State<AddOnsSelector> createState() => _AddOnsSelectorState();
}

class _AddOnsSelectorState extends State<AddOnsSelector> {
  final Set<Map<String, dynamic>> _selectedAddons = {};
  late Future<List<Map<String, dynamic>>> _addonsFuture;

  @override
  void initState() {
    super.initState();
    _addonsFuture = DatabaseHelper.instance.getAddons();
  }

  @override
  Widget build(BuildContext context) {
    // স্ক্রিন সাইজ অনুযায়ী রেসপনসিভ করার জন্য MediaQuery ব্যবহার
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _addonsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final addons = snapshot.data!;

        return Container(
          width: double.infinity,
          alignment: Alignment.centerLeft, // সব সাইজের স্ক্রিনে বাম দিক থেকে সাজানো থাকবে
          child: Wrap(
            spacing: 12, // পাশাপাশি গ্যাপ
            runSpacing: 12, // উপর-নিচ গ্যাপ
            children: addons.map((addon) {
              final isSelected = _selectedAddons.contains(addon);

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedAddons.remove(addon);
                    } else {
                      _selectedAddons.add(addon);
                    }
                  });
                  widget.onSelectionChanged(_selectedAddons.toList());
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  // ছোট স্ক্রিনে যেন টেক্সট ওভারফ্লো না হয় তার জন্য constraints
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.9, // স্ক্রিনের ৯০% এর বেশি বড় হবে না
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primaryColor.withOpacity(isDark ? 0.2 : 0.1)
                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor
                          : (isDark ? Colors.white12 : Colors.black.withOpacity(0.05)),
                      width: isSelected ? 1.5 : 1,
                    ),
                    // ডার্ক মোডে হালকা শ্যাডো যাতে কার্ডটি ফুটে ওঠে
                    boxShadow: isSelected && !isDark
                        ? [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (addon['iamge_url'] != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              addon['iamge_url'],
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              // ইমেজ লোড হতে দেরি হলে বা এরর দিলে ব্যাকআপ
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.add_circle_outline, size: 20, color: theme.primaryColor),
                            ),
                          ),
                        ),
                      Flexible( // লম্বা টেক্সট হলেও স্ক্রিন ফেটে যাবে না
                        child: Text(
                          "${addon['title']} +৳${addon['price']}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? Colors.white : theme.primaryColor)
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}