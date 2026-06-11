String weatherIcon(int code) {
  if (code == 0)  return '☀️';
  if (code <= 2)  return '🌤️';
  if (code == 3)  return '☁️';
  if (code <= 49) return '🌫️';
  if (code <= 59) return '🌦️';
  if (code <= 69) return '🌧️';
  if (code <= 79) return '❄️';
  if (code <= 84) return '🌧️';
  if (code <= 99) return '⛈️';
  return '🌡️';
}

// Also map description → icon (for when we only have the string)
String weatherIconFromDesc(String desc) {
  final d = desc.toLowerCase();
  if (d.contains('clear') || d.contains('sunny')) return '☀️';
  if (d.contains('partly')) return '🌤️';
  if (d.contains('cloud') || d.contains('overcast')) return '☁️';
  if (d.contains('fog'))  return '🌫️';
  if (d.contains('drizzle')) return '🌦️';
  if (d.contains('thunder')) return '⛈️';
  if (d.contains('snow')) return '❄️';
  if (d.contains('shower')) return '🌧️';
  if (d.contains('rain')) return '🌧️';
  if (d.contains('hail')) return '🌨️';
  return '🌡️';
}