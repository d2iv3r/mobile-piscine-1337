import 'package:flutter/material.dart';

class SearchControls extends StatelessWidget {
  const SearchControls({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onLocationPressed,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onLocationPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter city name'),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.location_pin),
          onPressed: onLocationPressed,
        ),
      ],
    );
  }
}
