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
    return Container(
      color: Colors.white.withOpacity(0.92),
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8),
        itemCount: results.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFB7C0CD),
        ),
        itemBuilder: (context, index) {
          final city = results[index];
          final admin1 = (city['admin1'] ?? '').toString();
          final country = (city['country'] ?? '').toString();

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: const Icon(
              Icons.location_city_outlined,
              color: Color(0xFF9AA3AF),
            ),
            title: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: city['name'].toString(),
                    style: const TextStyle(
                      color: Color(0xFF222222),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (admin1.isNotEmpty || country.isNotEmpty)
                    TextSpan(
                      text: ' ${[admin1, country].where((value) => value.isNotEmpty).join(', ')}',
                      style: const TextStyle(
                        color: Color(0xFF9AA3AF),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
            onTap: () => onCitySelected(city),
          );
        },
      ),
    );
  }
}
