import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  // Define the UiTM Kuala Terengganu bounds
  final LatLng _center = LatLng(5.3296, 103.1370); // Center of UiTM
  final LatLngBounds _uitmBounds = LatLngBounds(
    southwest: LatLng(5.2602, 103.1647), // Adjust southwest corner
    northeast: LatLng(5.2636, 103.1663), // Adjust northeast corner
  );

  bool _isAnimatingToBounds = false;

  /// Ensure the map camera position is within bounds
  void _enforceBounds() async {
    if (_mapController != null) {
      final LatLngBounds visibleBounds = await _mapController.getVisibleRegion();

      // Check if the visible bounds are outside the defined bounds
      if (!_uitmBounds.contains(visibleBounds.northeast) ||
          !_uitmBounds.contains(visibleBounds.southwest)) {
        if (!_isAnimatingToBounds) {
          _isAnimatingToBounds = true;

          // Calculate the current visible region's approximate center
          final double centerLat = (visibleBounds.northeast.latitude + visibleBounds.southwest.latitude) / 2;
          final double centerLng = (visibleBounds.northeast.longitude + visibleBounds.southwest.longitude) / 2;

          // Clamp the latitude and longitude to the bounds
          final double clampedLat = centerLat.clamp(
            _uitmBounds.southwest.latitude,
            _uitmBounds.northeast.latitude,
          );
          final double clampedLng = centerLng.clamp(
            _uitmBounds.southwest.longitude,
            _uitmBounds.northeast.longitude,
          );

          // Move the camera to the clamped position
          _mapController
              .animateCamera(CameraUpdate.newLatLng(LatLng(clampedLat, clampedLng)))
              .then((_) => _isAnimatingToBounds = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost Buoy'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;

          // Ensure the camera starts within bounds
          _mapController.animateCamera(CameraUpdate.newLatLngBounds(_uitmBounds, 50));
        },
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 16,
          tilt: 45, // Adds a 3D tilt effect
        ),
        markers: _markers,
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        buildingsEnabled: true,
        onCameraIdle: _enforceBounds, // Trigger bounds enforcement after camera stops
      ),
    );
  }
}
