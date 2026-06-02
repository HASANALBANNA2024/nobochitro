import 'package:flutter/material.dart';
import 'package:nobochitro/DatabaseHelper/database_helper.dart'; // তোমার পাথ অনুযায়ী দাও

import 'reviews_list_view.dart';

class ReviewsView extends StatefulWidget {
  const ReviewsView({super.key});

  @override
  State<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends State<ReviewsView> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);

    /// review fetch to database
    final data = await DatabaseHelper.instance.getData(table: 'reviews');
    setState(() {
      _reviews = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ReviewsListView(reviews: _reviews, onRefresh: _loadReviews),
        ),
      ),
    );
  }
}
