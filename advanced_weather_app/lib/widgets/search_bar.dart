import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

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
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
        hintText: 'Search location...',
        hintStyle: TextStyle(color: AppColors.textSecondary),
      ),
      onChanged: onChanged,
      onSubmitted: (_) => onSubmitted(),
    );
  }
}