import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  const SearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(Icons.search, color: Colors.white),
        hintText: 'Search location...',
        hintStyle: TextStyle(color: Colors.white),
      ),
      onChanged: onChanged,
      onSubmitted: (_) => onSubmitted(),
    );
  }
}