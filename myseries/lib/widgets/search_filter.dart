import 'package:flutter/material.dart';

class SearchFilter extends StatelessWidget {
  final bool isSearching;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleSearch;

  const SearchFilter({
    super.key,
    required this.isSearching,
    required this.controller,
    required this.onChanged,
    required this.onToggleSearch,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF313743),
      title: isSearching
          ? TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Zoek een serie...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            )
          : const Text(
              'MySeries',
              style: TextStyle(color: Colors.white),
            ),
      actions: [
        IconButton(
          icon: Icon(
            isSearching ? Icons.close : Icons.search,
            color: Colors.white,
          ),
          onPressed: onToggleSearch,
        ),
      ],
    );
  }
}
