import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'delivery_location_service.dart';

/// Tap the map to drop a pin; confirm to reverse-geocode into a delivery string.
/// Uses OpenStreetMap tiles (no Google Maps API key). Use [DeliveryLocationService.openGoogleMapsAt] from the app bar to open Google Maps externally.
class AddressMapPickerScreen extends StatefulWidget {
  const AddressMapPickerScreen({
    super.key,
    required this.initialCenter,
    this.initialPin,
  });

  final LatLng initialCenter;
  final LatLng? initialPin;

  @override
  State<AddressMapPickerScreen> createState() => _AddressMapPickerScreenState();
}

class _AddressMapPickerScreenState extends State<AddressMapPickerScreen> {
  final MapController _mapController = MapController();
  late LatLng _pin;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _pin = widget.initialPin ?? widget.initialCenter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(widget.initialCenter, 16);
    });
  }

  Future<void> _confirm() async {
    setState(() => _busy = true);
    final addr = await DeliveryLocationService.addressFromCoordinates(
      _pin.latitude,
      _pin.longitude,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (addr != null && addr.trim().isNotEmpty) {
      Navigator.of(context).pop<String>(addr.trim());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not resolve an address for this pin. Try another spot.'),
        ),
      );
    }
  }

  Future<void> _recenterGps() async {
    setState(() => _busy = true);
    final ll = await DeliveryLocationService.getCurrentLatLng();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ll == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get GPS position.')),
      );
      return;
    }
    setState(() => _pin = ll);
    _mapController.move(ll, 17);
  }

  Future<void> _openGoogleMaps() async {
    final ok = await DeliveryLocationService.openGoogleMapsAt(
      lat: _pin.latitude,
      lng: _pin.longitude,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select on map'),
        actions: [
          IconButton(
            tooltip: 'Open in Google Maps',
            icon: const Icon(Icons.map_outlined),
            onPressed: _busy ? null : _openGoogleMaps,
          ),
          IconButton(
            tooltip: 'Use current GPS location',
            icon: const Icon(Icons.my_location),
            onPressed: _busy ? null : _recenterGps,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialCenter,
              initialZoom: 16,
              onTap: (_, point) => setState(() => _pin = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.insect_crop_camera',
                maxNativeZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pin,
                    width: 48,
                    height: 48,
                    alignment: Alignment.bottomCenter,
                    child: Icon(
                      Icons.location_pin,
                      size: 48,
                      color: scheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              color: scheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tap the map to move the pin. Use toolbar for GPS or Google Maps.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _busy ? null : () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: _busy ? null : _confirm,
                            child: _busy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Use this location'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
