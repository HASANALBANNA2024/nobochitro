import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart';

class ResponsiveReviewList extends StatefulWidget {
  final Color primaryAccent;
  final String sectionTitle;

  // Dynamic parameters for filtering reviews
  final String? filterPackageName;
  final String? filterPhotographerName;
  final String? filterCategoryName;

  const ResponsiveReviewList({
    super.key,
    required this.primaryAccent,
    this.sectionTitle = 'Client Testimonials',
    this.filterPackageName,
    this.filterPhotographerName,
    this.filterCategoryName,
  });

  @override
  State<ResponsiveReviewList> createState() => _ResponsiveReviewListState();
}

class _ResponsiveReviewListState extends State<ResponsiveReviewList> {
  late PageController _pageController;
  Timer? _autoTimer;
  int _currentPage = 0;

  List<Map<String, dynamic>> _allReviews = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _initializeData();
  }

  /// Fetch current user context and reviews sequentially
  Future<void> _initializeData() async {
    try {
      _currentUserId = await DatabaseHelper.instance.getCurrentUserId();
    } catch (_) {
      _currentUserId = null;
    }
    await _fetchAndFilterReviews();
  }

  /// Fetch reviews from Supabase and apply precise multi-level filtering
  Future<void> _fetchAndFilterReviews() async {
    try {
      /// to call data from real database of use of database helper
      List<Map<String, dynamic>> rawReviews = await DatabaseHelper.instance
          .getData(table: 'reviews');

      if (!mounted) return;

      List<Map<String, dynamic>> filtered = [];

      /// filter of real database value
      for (var review in rawReviews) {
        bool matches = true;

        if (widget.filterPackageName != null &&
            review['package_name']?.toString().toLowerCase() !=
                widget.filterPackageName!.toLowerCase()) {
          matches = false;
        }
        if (widget.filterPhotographerName != null &&
            review['photographer_name']?.toString().toLowerCase() !=
                widget.filterPhotographerName!.toLowerCase()) {
          matches = false;
        }
        if (widget.filterCategoryName != null) {
          String cat = review['category_name']?.toString().toLowerCase() ?? '';
          String pkg = review['package_name']?.toString().toLowerCase() ?? '';
          if (cat != widget.filterCategoryName!.toLowerCase() &&
              !pkg.contains(widget.filterCategoryName!.toLowerCase())) {
            matches = false;
          }
        }

        if (matches) filtered.add(review);
      }

      setState(() {
        _allReviews = filtered;
        _isLoading = false;
      });

      if (_allReviews.isNotEmpty) {
        _startAutoScroll();
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
      setState(() => _isLoading = false);
    }
  }

  void _startAutoScroll() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_pageController.hasClients && _allReviews.isNotEmpty) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage % _allReviews.length,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _editReviewDialog(Map<String, dynamic> review) {
    final commentController = TextEditingController(text: review['comment']);
    double currentRating = (review['rating'] ?? 5.0).toDouble();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            "Edit Your Review",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () =>
                        setDialogState(() => currentRating = index + 1.0),
                    child: Icon(
                      Icons.star_rounded,
                      color: index < currentRating
                          ? Colors.amber
                          : Colors.grey[700],
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: commentController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Update your experience...",
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.black87,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryAccent,
              ),
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                try {
                  await DatabaseHelper.update(
                    table: 'reviews',
                    column: 'id',
                    value: review['id'],
                    data: {
                      'comment': commentController.text.trim(),
                      'rating': currentRating,
                    },
                  );
                  _fetchAndFilterReviews();
                } catch (e) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to update review: $e")),
                  );
                }
              },
              child: const Text(
                "Update",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteReviewConfirm(dynamic reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Delete Review",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you completely sure you want to remove this review permanently?",
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await DatabaseHelper.instance.deleteReview(
                  column: 'id',
                  value: reviewId,
                );
                _fetchAndFilterReviews();
              } catch (e) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete review: $e")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAllReviewsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF131313),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.sectionTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _allReviews.isEmpty
                    ? const Center(
                        child: Text(
                          "No reviews found for this category.",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        itemCount: _allReviews.length,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: _ReviewCard(
                            review: _allReviews[i],
                            primaryAccent: widget.primaryAccent,
                            currentUserId: _currentUserId,
                            onEdit: () => _editReviewDialog(_allReviews[i]),
                            onDelete: () =>
                                _deleteReviewConfirm(_allReviews[i]['id']),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fraction = screenWidth > 1400
        ? 0.25
        : (screenWidth > 1000 ? 0.35 : (screenWidth > 600 ? 0.5 : 1.0));

    _pageController = PageController(
      viewportFraction: fraction,
      initialPage:
          _currentPage % (_allReviews.isEmpty ? 1 : _allReviews.length),
    );

    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(color: Colors.amber),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 15),
            child: Text(
              widget.sectionTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        _allReviews.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No reviews found.",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            : ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: SizedBox(
                  height: screenWidth > 600 ? 250 : 210,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _allReviews.length,
                    padEnds: false,
                    onPageChanged: (i) => _currentPage = i,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.all(8),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: _ReviewCard(
                          review: _allReviews[i],
                          primaryAccent: widget.primaryAccent,
                          currentUserId: _currentUserId,
                          onEdit: () => _editReviewDialog(_allReviews[i]),
                          onDelete: () =>
                              _deleteReviewConfirm(_allReviews[i]['id']),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        if (_allReviews.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 5),
            child: TextButton.icon(
              onPressed: _showAllReviewsSheet,
              icon: const Icon(Icons.grid_view_rounded, size: 16),
              label: const Text(
                "View All",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: widget.primaryAccent,
              ),
            ),
          ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final Color primaryAccent;
  final String? currentUserId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.review,
    required this.primaryAccent,
    this.currentUserId,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _buildFormattedComment(String comment) {
    if (!comment.contains('#') && !comment.contains('@')) {
      return Text(
        comment,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white70,
          height: 1.4,
        ),
      );
    }

    final List<InlineSpan> spans = [];
    final words = comment.split(' ');

    for (var word in words) {
      if (word.startsWith('#')) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: TextStyle(
              color: primaryAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      } else if (word.startsWith('@')) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        );
      }
    }

    return RichText(text: TextSpan(children: spans));
  }

  List<String> _parseReviewImages(dynamic rawUrl) {
    if (rawUrl == null) return [];
    String urlStr = rawUrl.toString().trim();
    if (urlStr.isEmpty || urlStr == 'null' || urlStr == 'EMPTY') return [];

    if (urlStr.startsWith('{') && urlStr.endsWith('}')) {
      urlStr = urlStr.substring(1, urlStr.length - 1);
    }
    if (urlStr.startsWith('[') && urlStr.endsWith(']')) {
      urlStr = urlStr.substring(1, urlStr.length - 1);
    }

    return urlStr
        .split(',')
        .map((e) => e.replaceAll('"', '').replaceAll("'", "").trim())
        .where((e) => e.isNotEmpty && e.startsWith('http'))
        .toList();
  }

  void _openImageLightbox(BuildContext context, String url) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Lightbox",
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF131313),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InteractiveViewer(
                    clipBehavior: Clip.none,
                    maxScale: 2.5,
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        height: 150,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white30,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = review['user_name'] ?? "Anonymous";
    final String comment = review['comment'] ?? "";
    final double rating = (review['rating'] ?? 5.0).toDouble();
    final String rUserId = review['user_id'] ?? "anonymous_user";

    final bool isOwnReview = currentUserId != null && currentUserId == rUserId;
    final bool isAnonymous =
        name.toLowerCase() == 'anonymous' || rUserId == 'anonymous_user';

    final List<String> parsedUrls = _parseReviewImages(
      review['review_image_url'],
    );

    /// user image
    final String? userAvatarData = review['user_avatar'];
    final bool hasValidAvatar =
        userAvatarData != null &&
        userAvatarData.toString().trim().isNotEmpty &&
        userAvatarData.toString().trim() != 'null' &&
        userAvatarData.toString().trim() != 'EMPTY';

    final String profileUrl = hasValidAvatar
        ? userAvatarData.toString().trim()
        : "https://ijxtbmgvtwvpkbshunwf.supabase.co/storage/v1/object/public/user_assets/profile_user_image/$rUserId.jpg";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,

        /// automatic comments content area size for facebook style
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[800],
                child: ClipOval(
                  child: isAnonymous
                      ? const Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.amber,
                        )
                      : Image.network(
                          profileUrl,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,

                            /// to failed image load
                            size: 16,
                            color: Colors.white60,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
              Text(
                " $rating",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isOwnReview)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(maxWidth: 100),
                  color: const Color(0xFF2C2C2C),
                  onSelected: (action) {
                    if (action == 'edit') onEdit();
                    if (action == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      height: 35,
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            color: Colors.white70,
                            size: 14,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Edit",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      height: 35,
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            size: 14,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),

          /// 📝 face comments style content area
          _buildFormattedComment(comment),

          /// 📸 custom review image for gallery loader
          if (parsedUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: parsedUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _openImageLightbox(context, parsedUrls[index]),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                        image: DecorationImage(
                          image: NetworkImage(parsedUrls[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
