import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true, // Automatically opens keyboard
          decoration: const InputDecoration(
            hintText: 'Search styles, people, etc...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // FUTURE INTEGRATION:
            // 1. Trigger live Firebase queries as user types.
            // 2. Or send value to n8n webhook for processing results.
          },
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 80, color: colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  const Text('Start typing to see results'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
  ---------------------------------------------------------
  SEARCH LOGIC GUIDE (FOR FUTURE):
  ---------------------------------------------------------
  1. FIREBASE:
     - Use a StreamBuilder inside the body.
     - Filter your Firestore 'photographers' collection using _searchController.text.

  2. N8N INTEGRATION:
     - Use an n8n HTTP Request node.
     - Send the query on every character change (with debounce) or on search submission.
     - Display the returned JSON list in a ListView.
  ---------------------------------------------------------
*/