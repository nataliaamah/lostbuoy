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

  // UiTM campus boundaries with tighter limits
  final LatLngBounds _uitmBounds = LatLngBounds(
    southwest: LatLng(5.2605, 103.1645), // Slightly reduced boundary
    northeast: LatLng(5.2630, 103.1667),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (controller) async {
          _mapController = controller;

          // Move the camera to focus tightly within UiTM's boundaries
          await _mapController.moveCamera(
            CameraUpdate.newLatLngBounds(_uitmBounds, 25), // Reduced padding to tighten view
          );

          // Apply custom map style
          _mapController.setMapStyle(mapStyle);
        },
        initialCameraPosition: CameraPosition(
          target: _center, // Center of UiTM
          zoom: 18.5, // Start closer for better detail
        ),
        mapType: MapType.normal,
        minMaxZoomPreference: MinMaxZoomPreference(18.5, 22), // Focus on zooming in, restrict zooming out
        cameraTargetBounds: CameraTargetBounds(_uitmBounds), // Constrain camera movement to UiTM bounds
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }
}
