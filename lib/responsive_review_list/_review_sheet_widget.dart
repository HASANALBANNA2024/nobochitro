import 'package:flutter/material.dart';

class ReviewService {
  // UI এর জন্য ডিফল্ট কালার
  static const Color goldColor = Color(0xFFD4AF37);
  static const Color tealColor = Color(0xFF008080);
  static const Color surfaceColor = Color(0xFF131313);

  // এখানে আমরা সরাসরি context নিচ্ছি, তাই main.dart এ কিছু করা লাগবে না
  static void showReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _DynamicReviewSheet(),
    );
  }
}

class _DynamicReviewSheet extends StatefulWidget {
  const _DynamicReviewSheet({super.key});

  @override
  State<_DynamicReviewSheet> createState() => _DynamicReviewSheetState();
}

class _DynamicReviewSheetState extends State<_DynamicReviewSheet> {
  int _rating = 0;
  String _selectedType = "Client";
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 15, 20, bottomInset + 20),
      decoration: const BoxDecoration(
        color: ReviewService.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handlebar (UI Design)
            Center(
              child: Container(
                width: 45,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const Text(
              "Create Review",
              style: TextStyle(
                color: ReviewService.goldColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),

            // রিভিউ টাইপ চিপস (UI)
            Row(
              children: [
                _buildTypeChip("Client", Icons.verified),
                const SizedBox(width: 10),
                _buildTypeChip("Fan", Icons.favorite),
              ],
            ),

            const SizedBox(height: 30),

            // স্টার রেটিং UI
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => GestureDetector(
                    onTap: () => setState(() => _rating = index + 1),
                    child: Icon(
                      index < _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: index < _rating ? Colors.amber : Colors.grey[700],
                      size: 45,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // রিভিউ টেক্সট বক্স
            TextField(
              controller: _reviewController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Write your feedback...",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // সাবমিট বাটন
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ReviewService.goldColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "POST REVIEW",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // চিপস উইজেট
  Widget _buildTypeChip(String type, IconData icon) {
    bool isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? ReviewService.tealColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ReviewService.tealColor : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? ReviewService.tealColor : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
