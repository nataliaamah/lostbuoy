import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lostbuoy/Utils/map_style.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late GoogleMapController _mapController;

  // Center of UiTM campus
  final LatLng _center = LatLng(5.261832, 103.165598);

  // UiTM campus boundaries
  final LatLngBounds _uitmBounds = LatLngBounds(
    southwest: LatLng(5.2600, 103.1640), // Adjusted campus boundary
    northeast: LatLng(5.2630, 103.1670),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;

          // Move the camera to focus on UiTM's boundaries
          _mapController.moveCamera(
            CameraUpdate.newLatLngBounds(_uitmBounds, 50),
          );
        },
        initialCameraPosition: CameraPosition(
          target: _center, // Center of UiTM
          zoom: 18, // Default zoom level to start closer
        ),
        mapType: MapType.normal,
        minMaxZoomPreference: MinMaxZoomPreference(18, 22), // Focus on zooming in
        cameraTargetBounds: CameraTargetBounds(_uitmBounds), // Constrain movement to UiTM bounds
        style: mapStyle, // Apply map styling directly
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }
}
