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

  // Center of UiTM Kuala Terengganu (smaller bounds center)
  final LatLng _center = LatLng(5.2618, 103.1656);

  // Smaller UiTM Kuala Terengganu bounds
  final LatLngBounds _uitmBounds = LatLngBounds(
    southwest: LatLng(5.2611, 103.1653), // Tighter southwest corner
    northeast: LatLng(5.2625, 103.1659), // Tighter northeast corner
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost Buoy'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;

          // Move the camera to fit the smaller UiTM bounds
          _mapController.animateCamera(
            CameraUpdate.newLatLngBounds(_uitmBounds, 50),
          );
        },
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 17, // Slightly higher zoom for smaller area
        ),
        markers: _markers,
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        buildingsEnabled: true,

        // Restrict camera movements to the smaller UiTM bounds
        cameraTargetBounds: CameraTargetBounds(_uitmBounds),
      ),
    );
  }
}
