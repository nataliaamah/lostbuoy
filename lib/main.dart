import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late GoogleMapController mapController;

  // Center coordinates for UiTM Kuala Terengganu campus
  static const LatLng _center = LatLng(5.4085, 103.0930);

  // Camera bounds for limiting map view
  static final LatLngBounds _mapBounds = LatLngBounds(
    southwest: LatLng(5.4065, 103.0910), // Adjust these coordinates
    northeast: LatLng(5.4105, 103.0950), // to match campus boundaries
  );

  // Dummy markers for lost/found items
  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('lost_item_1'),
      position: LatLng(5.4087, 103.0932),
      infoWindow: InfoWindow(
        title: 'Lost Wallet',
        snippet: 'Black leather wallet lost near cafeteria',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ),
    Marker(
      markerId: MarkerId('found_item_1'),
      position: LatLng(5.4083, 103.0928),
      infoWindow: InfoWindow(
        title: 'Found Water Bottle',
        snippet: 'Blue water bottle found at library',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ),
    // Add more dummy markers as needed
  };

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Set map bounds
    controller.setMapStyle('''
      [
        {
          "featureType": "poi",
          "elementType": "labels",
          "stylers": [
            {
              "visibility": "off"
            }
          ]
        }
      ]
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UiTM KT Lost & Found'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Add navigation to create post page
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 17.0,
            ),
            markers: _markers,
            // Restrict map movement
            minMaxZoomPreference: MinMaxZoomPreference(16, 18),
            cameraTargetBounds: CameraTargetBounds(_mapBounds),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
          ),
          // Optional: Add a floating action button for creating new posts
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                // Add navigation to create post page
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}