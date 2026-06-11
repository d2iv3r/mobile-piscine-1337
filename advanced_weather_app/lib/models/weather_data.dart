class WeatherData {
  final String city, region, country;
  // current
  final double currentTemp, currentWind;
  final String currentDesc;
  final int currentCode;
  // hourly (today)
  final List<String> hours;
  final List<double> hourlyTemps, hourlyWinds;
  final List<String> hourlyDescs;
  final List<int> hourlyCodes;
  // daily (weekly)
  final List<String> dates;
  final List<double> minTemps, maxTemps;
  final List<String> dailyDescs;
  final List<int> dailyCodes;

  WeatherData({
    required this.city,
    required this.region,
    required this.country,
    required this.currentTemp,
    required this.currentWind,
    required this.currentDesc,
    required this.currentCode,
    required this.hours,
    required this.hourlyTemps,
    required this.hourlyWinds,
    required this.hourlyDescs,
    required this.hourlyCodes,
    required this.dates,
    required this.minTemps,
    required this.maxTemps,
    required this.dailyDescs,
    required this.dailyCodes,
  });
}