import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;

class CreateAdPage extends StatefulWidget {
  const CreateAdPage({super.key});

  @override
  State<CreateAdPage> createState() => _CreateAdPageState();
}

class _CreateAdPageState extends State<CreateAdPage> {
  final _formKey = GlobalKey<FormState>();
  String? title, description;
  String postType = 'Lost'; // Default post type
  XFile? image;
  LatLng? selectedLocation;

  final Set<Marker> _markers = {};

  // Function to select an image
  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
      print('Image selected: ${pickedImage.path}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected!')),
      );
    }
  }

  // Function to handle map taps
  void _onMapTapped(LatLng location) {
    setState(() {
      selectedLocation = location;
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('selected_location'),
        position: location,
        infoWindow: const InfoWindow(title: 'Selected Location'),
      ));
    });
  }

  Future<String> _compressAndEncodeImage(File imageFile) async {
    try {
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Decode the image
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) throw Exception('Error decoding image');

      // Resize the image (e.g., max width = 500px while maintaining aspect ratio)
      final resizedImage = img.copyResize(decodedImage, width: 500);

      // Compress the image and encode to Base64
      final compressedBytes = img.encodeJpg(resizedImage, quality: 75); // Adjust quality (0-100)
      return base64Encode(compressedBytes);
    } catch (e) {
      throw Exception('Error compressing image: $e');
    }
  }

  // Function to save ad to Firestore
  Future<void> _saveAd() async {
    if (!_formKey.currentState!.validate()) {
      // Validate all fields
      return;
    }

    // Check if image is selected
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image.')),
      );
      return;
    }

    // Check if location is selected
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map.')),
      );
      return;
    }

    try {
      // Compress and encode image to Base64
      final base64Image = await _compressAndEncodeImage(File(image!.path));

      // Save ad to Firestore
      await FirebaseFirestore.instance.collection('ads').add({
        'title': title,
        'description': description,
        'postType': postType,
        'imageBase64': base64Image, // Use compressed Base64 string
        'location': GeoPoint(selectedLocation!.latitude, selectedLocation!.longitude),
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad created successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating ad: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('Create Ad', style: TextStyle(color: Colors.black),),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSection(
                title: "Upload Item Photo",
                child: GestureDetector(
                  onTap: _selectImage,
                  child: Container(
                    height: 180,
                    width: 400,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 1.0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color.fromRGBO(
                          255, 255, 255, 1.0)),
                    ),
                    child: image == null
                        ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload, size: 50, color: Colors.black),
                        SizedBox(height: 8),
                        Text('Tap to upload', style: TextStyle(color: Colors.black),),
                      ],
                    )
                        : Image.file(
                      File(image!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              _buildSection(
                title: "Post Type",
                child: DropdownButtonFormField<String>(
                  value: postType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Lost', child: Text('Lost')),
                    DropdownMenuItem(value: 'Found', child: Text('Found')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      postType = value!;
                    });
                  },
                ),
              ),

              _buildSection(
                title: "Details",
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please provide a title.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        title = value;
                      },
                    ),

                    TextFormField(
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please provide a description.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        description = value;
                      },
                    ),
                  ],
                ),
              ),

              _buildSection(
                title: "Location",
                child: SizedBox(
                  height: 250,
                  child: GestureDetector(
                    onVerticalDragUpdate: (_) {}, // Prevent gesture conflicts
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(5.261832, 103.165598),
                        zoom: 18.5,
                      ),
                      markers: _markers,
                      onTap: _onMapTapped,
                      scrollGesturesEnabled: true, // Allow scrolling gestures
                      zoomControlsEnabled: true, // Show zoom controls
                      zoomGesturesEnabled: true, // Allow zoom gestures
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
                  ),
                ),
              ),


              ElevatedButton.icon(
                onPressed: _saveAd,
                label: const Text(
                  'Create Ad',
                  style: TextStyle(
                    fontSize: 18, // Make the text slightly larger
                    fontWeight: FontWeight.bold, // Emphasize the text
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(103, 51, 152, 1.0), // Custom background color
                  foregroundColor: Colors.white, // Text and icon color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14.0, // Increase padding for a larger button
                    horizontal: 24.0,
                  ),
                  elevation: 5, // Add a shadow for depth
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      color: const Color(0xFFF1F1F1),
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
