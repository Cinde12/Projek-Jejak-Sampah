import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Mengambil posisi GPS saat ini. Melempar Exception berisi pesan
  /// yang ramah pengguna jika GPS mati atau izin ditolak.
  Future<Position> getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('GPS belum aktif. Nyalakan lokasi di pengaturan.');
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      throw Exception('Izin lokasi ditolak.');
    }
    if (perm == LocationPermission.deniedForever) {
      throw Exception(
          'Izin lokasi ditolak permanen. Aktifkan lewat pengaturan aplikasi.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
