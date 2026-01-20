import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class PickLocationPage extends StatefulWidget {
  const PickLocationPage({super.key});

  @override
  State<PickLocationPage> createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  LatLng? _selectedLatLng;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    final location = Location();

    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) return;
    }

    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) return;
    }

    final current = await location.getLocation();
    setState(() {
      _selectedLatLng = LatLng(current.latitude!, current.longitude!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedLatLng == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn địa chỉ giao hàng')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _selectedLatLng!,
          initialZoom: 16,
          onTap: (_, latLng) {
            setState(() {
              _selectedLatLng = latLng;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.kfc',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedLatLng!,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, _selectedLatLng),
        icon: const Icon(Icons.check),
        label: const Text('Xác nhận'),
      ),
    );
  }
}
