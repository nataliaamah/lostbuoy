import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:lostbuoy/Utils/custom_navigation_bar.dart';
import 'view_ad.dart';

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

  BitmapDescriptor? lostMarkerIcon;
  BitmapDescriptor? foundMarkerIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkerIcons().then((_) => _listenToAdUpdates());
  }

  Future<BitmapDescriptor> _resizeAndCreateMarker(String assetPath, int width) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width, // Adjust width to control size
    );
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? resizedData =
    await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(resizedData!.buffer.asUint8List());
  }

  Future<void> _loadCustomMarkerIcons() async {
    lostMarkerIcon = await _resizeAndCreateMarker(
      'lib/asset/lost_marker.png',
      100, // Adjust marker size here
    );
    foundMarkerIcon = await _resizeAndCreateMarker(
      'lib/asset/found_marker.png',
      100, // Adjust marker size here
    );
  }

  void _listenToAdUpdates() {
    FirebaseFirestore.instance.collection('ads').snapshots().listen((snapshot) {
      setState(() {
        _markers.clear(); // Clear existing markers
        for (var ad in snapshot.docs) {
          final data = ad.data();
          data['id'] = ad.id; // Add the document ID to the ad data

          // Skip ads marked as solved
          if (data.containsKey('status') && data['status'] == 'solved') {
            continue;
          }

          final markerId = MarkerId(ad.id);
          final LatLng position = LatLng(
            data['location'].latitude,
            data['location'].longitude,
          );

          // Choose the appropriate icon based on post type
          final BitmapDescriptor markerIcon = data['postType'] == 'Lost'
              ? lostMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose)
              : foundMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

          _markers[markerId] = Marker(
            markerId: markerId,
            position: position,
            icon: markerIcon,
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
          ),
          if (_selectedAd != null) _buildAdPopup(),
        ],
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }

  Widget _buildAdPopup() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter, // Keep it aligned at the bottom
          child: Padding(
            padding: const EdgeInsets.only(bottom: 35), // Adjust the bottom padding to move up or down
            child: Card(
              color: Colors.white,
              elevation: 4, // Adds shadow for better separation
              shadowColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16), // Adds spacing around the card
              child: Container(
                height: 100, // Adjust the height for a taller card
                padding: const EdgeInsets.all(8), // Add padding inside the card
                child: Row(
                  children: [
                    // Leading image with placeholder
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(_selectedAd!['imageBase64']),
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10), // Space between image and text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Title
                          Text(
                            _selectedAd!['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Description
                          Text(
                            _selectedAd!['description'] ?? 'No Description',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8), // Add spacing between text and trailing icons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Post Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _selectedAd!['postType'] == 'Lost'
                                ? Colors.redAccent
                                : Colors.greenAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedAd!['postType'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10), // Space between badge and arrow
                        // Trailing Arrow
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewAdPage(adData: _selectedAd!),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
