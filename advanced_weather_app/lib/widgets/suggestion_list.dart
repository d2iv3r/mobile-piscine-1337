import 'package:flutter/material.dart';
import '../models/city_result.dart';
import '../utils/app_colors.dart';

class SuggestionList extends StatelessWidget {
  final List<CityResult> suggestions;
  final ValueChanged<CityResult> onSelect;

  const SuggestionList({
    super.key,
    required this.suggestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length > 5 ? 5 : suggestions.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
        itemBuilder: (ctx, i) {
          final c = suggestions[i];
          return ListTile(
            leading: const Icon(Icons.location_on, color: AppColors.accent, size: 20),
            title: Text(c.name,
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            subtitle: Text('${c.region}, ${c.country}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            onTap: () => onSelect(c),
            dense: true,
          );
        },
      ),
    );
  }
}