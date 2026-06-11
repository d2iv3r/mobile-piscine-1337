import 'package:geolocator/geolocator.dart';


Future<Position> getCurrentPosition() async {
  LocationPermission perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied) {
    perm = await Geolocator.requestPermission();
  }
  if (perm == LocationPermission.deniedForever ||
      perm == LocationPermission.denied) {
    throw 'Geolocation is not available, please enable it in your App settings.';
  }
  return await Geolocator.getCurrentPosition();
}
