import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// GPS + reverse geocoding + opening Google Maps in the browser / Maps app.
class DeliveryLocationService {
  DeliveryLocationService._();

  /// Rough centre of India when no position is known (map default).
  static const LatLng defaultMapCenter = LatLng(20.5937, 78.9629);

  static Future<LocationPermission> ensureLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  static Future<LatLng> initialMapCenter() async {
    final last = await Geolocator.getLastKnownPosition();
    if (last != null) return LatLng(last.latitude, last.longitude);
    return defaultMapCenter;
  }

  static Future<LatLng?> getCurrentLatLng() async {
    final permission = await ensureLocationPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) return null;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (e, st) {
      debugPrint('getCurrentLatLng: $e\n$st');
      return null;
    }
  }

  static Future<String?> getCurrentAddress() async {
    final permission = await ensureLocationPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) return null;

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return addressFromCoordinates(pos.latitude, pos.longitude);
    } catch (e, st) {
      debugPrint('getCurrentAddress: $e\n$st');
      return null;
    }
  }

  static Future<String?> addressFromCoordinates(double lat, double lng) async {
    try {
      final list = await placemarkFromCoordinates(lat, lng);
      if (list.isEmpty) return null;
      return formatPlacemark(list.first);
    } catch (e, st) {
      debugPrint('addressFromCoordinates: $e\n$st');
      return null;
    }
  }

  static String formatPlacemark(Placemark p) {
    final parts = <String>[];
    void add(String? s) {
      final t = (s ?? '').trim();
      if (t.isNotEmpty && !parts.contains(t)) parts.add(t);
    }

    final street = [p.street, p.subThoroughfare, p.thoroughfare]
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(' ')
        .trim();
    if (street.isNotEmpty) add(street);
    add(p.subLocality);
    add(p.locality);
    add(p.postalCode);
    add(p.administrativeArea);
    add(p.country);
    return parts.join(', ');
  }

  /// Opens Google Maps at coordinates (app or browser).
  static Future<bool> openGoogleMapsAt({
    required double lat,
    required double lng,
  }) async {
    final web = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    return _launchPreferExternal(web);
  }

  /// Opens Google Maps search; [query] may be an address string or null for generic Maps.
  static Future<bool> openGoogleMapsSearch([String? query]) async {
    final uri = (query == null || query.trim().isEmpty)
        ? Uri.parse('https://www.google.com/maps')
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query.trim())}',
          );
    return _launchPreferExternal(uri);
  }

  static Future<bool> _launchPreferExternal(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e, st) {
      debugPrint('launchUrl: $e\n$st');
    }
    return false;
  }
}
