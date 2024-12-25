import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:lostbuoy/Utils/custom_navigation_bar.dart';
import 'package:lostbuoy/Utils/map_style.dart'; // Import the map style

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late GoogleMapController _mapController;

  // Center of UiTM campus
  final LatLng _center = const LatLng(5.261832, 103.165598);

  // UiTM campus boundaries
  final LatLngBounds _uitmBounds = LatLngBounds(
    southwest: const LatLng(5.2605, 103.1645),
    northeast: const LatLng(5.2630, 103.1667),
  );

  final Map<MarkerId, Marker> _markers = {};
  Map<String, dynamic>? _selectedAd;

  @override
  void initState() {
    super.initState();
    _listenToAdUpdates();
  }

  void _listenToAdUpdates() {
    FirebaseFirestore.instance.collection('ads').snapshots().listen((snapshot) {
      setState(() {
        _markers.clear(); // Clear existing markers
        for (var ad in snapshot.docs) {
          final data = ad.data();
          final markerId = MarkerId(ad.id);
          final LatLng position = LatLng(
            data['location'].latitude,
            data['location'].longitude,
          );

          // Determine marker color based on post type
          final BitmapDescriptor markerColor = data['postType'] == 'Lost'
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

          _markers[markerId] = Marker(
            markerId: markerId,
            position: position,
            icon: markerColor,
            onTap: () {
              setState(() {
                _selectedAd = data;
              });
            },
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) async {
              _mapController = controller;
              await _mapController.moveCamera(
                CameraUpdate.newLatLngBounds(_uitmBounds, 25),
              );
            },
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 18.5,
            ),
            markers: Set<Marker>.of(_markers.values),
            cameraTargetBounds: CameraTargetBounds(_uitmBounds),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            style: mapStyle, // Apply the map style directly here
          ),
          if (_selectedAd != null) _buildAdPopup(),
        ],
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }

  Widget _buildAdPopup() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color.fromRGBO(255, 251, 238, 1.0),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: MemoryImage(
                    base64Decode(_selectedAd!['imageBase64']),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              _selectedAd!['title'] ?? 'No Title',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              _selectedAd!['description'] ?? 'No Description',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _selectedAd = null;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
