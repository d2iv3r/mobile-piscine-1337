import 'package:flutter/material.dart';
import '../models/city_result.dart';

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
    return ListView.builder(
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (ctx, i) {
          final c = suggestions[i];
          return ListTile(
            title: Text(c.name),
            subtitle: Text('${c.region}, ${c.country}'),
            onTap: () => onSelect(c),
          );
        },
    );
  }
}