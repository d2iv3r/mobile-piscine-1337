import 'package:flutter/material.dart';

class CityResultsList extends StatelessWidget {
  const CityResultsList({
    super.key,
    required this.results,
    required this.onCitySelected,
  });

  final List<dynamic> results;
  final ValueChanged<dynamic> onCitySelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final city = results[index];
        return ListTile(
          title: Text(city['name']),
          subtitle: Text('${city['admin1']}, ${city['country']}'),
          onTap: () => onCitySelected(city),
        );
      },
    );
  }
}
