import 'package:flutter/material.dart';


class WeatherAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WeatherAppBar({
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(180, 48, 62, 73),
      elevation: 0,
      title: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.white),
                labelText: 'Search location',
                labelStyle: TextStyle(color: Colors.white),
                floatingLabelStyle: TextStyle(color: Colors.white),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
            ),
          ),
          const SizedBox(
            height: 28,
            child: VerticalDivider(color: Colors.white, thickness: 1, width: 20),
          ),
          IconButton(
            icon: const Icon(Icons.near_me, color: Colors.white),
            onPressed: onLocationPressed,
          ),
        ],
      ),
    );
  }
}
