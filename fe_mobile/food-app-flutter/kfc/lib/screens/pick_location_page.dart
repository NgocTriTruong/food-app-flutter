import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class PickLocationPage extends StatefulWidget {
  const PickLocationPage({super.key});

  @override
  State<PickLocationPage> createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  LatLng? _selectedLatLng;
  final Set<Marker> _markers = {};

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
    final latLng = LatLng(current.latitude!, current.longitude!);

    setState(() {
      _selectedLatLng = latLng;
      _markers.add(
        Marker(markerId: const MarkerId('current'), position: latLng),
      );
    });
  }

  void _onTapMap(LatLng latLng) {
    setState(() {
      _selectedLatLng = latLng;
      _markers
        ..clear()
        ..add(
          Marker(
            markerId: const MarkerId('selected'),
            position: latLng,
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn địa chỉ giao hàng')),
      body: _selectedLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedLatLng!,
          zoom: 16,
        ),
        onTap: _onTapMap,
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, _selectedLatLng),
        icon: const Icon(Icons.check),
        label: const Text('Xác nhận'),
      ),
    );
  }
}
