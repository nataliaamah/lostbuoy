import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/gestures.dart';

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

  Future<void> _selectImage() async {
    final picker = ImagePicker();

    // Show options to the user
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop('camera');
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop('gallery');
                },
              ),
            ],
          ),
        );
      },
    );

    if (action == null) return; // User dismissed the dialog

    XFile? pickedImage;

    try {
      if (action == 'camera') {
        // Capture a photo using the camera
        pickedImage = await picker.pickImage(source: ImageSource.camera);
      } else if (action == 'gallery') {
        // Select an image from the gallery
        pickedImage = await picker.pickImage(source: ImageSource.gallery);
      }

      if (pickedImage != null) {
        setState(() {
          image = pickedImage;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }


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
      final imageBytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) throw Exception('Error decoding image');
      final resizedImage = img.copyResize(decodedImage, width: 500);
      final compressedBytes = img.encodeJpg(resizedImage, quality: 75);
      return base64Encode(compressedBytes);
    } catch (e) {
      throw Exception('Error compressing image: $e');
    }
  }

  Future<void> _saveAd() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (image == null || selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image and select a location.')),
      );
      return;
    }

    try {
      final base64Image = await _compressAndEncodeImage(File(image!.path));
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in!')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('ads').add({
        'title': title,
        'description': description,
        'postType': postType,
        'imageBase64': base64Image,
        'location': GeoPoint(selectedLocation!.latitude, selectedLocation!.longitude),
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser.uid,
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
      backgroundColor: Color.fromRGBO(245, 254, 255, 1),
      appBar: AppBar(
        title: const Text('Create Ad', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(245, 254, 255, 1),
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
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white),
                    ),
                    child: image == null
                        ? const Center(
                      child: Icon(Icons.upload, size: 50, color: Colors.black),
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
                  onChanged: (value) => setState(() => postType = value!),
                ),
              ),
              _buildSection(
                title: "Details",
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Please provide a title.' : null,
                      onSaved: (value) => title = value,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description'),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Please provide a description.'
                          : null,
                      onSaved: (value) => description = value,
                    ),
                  ],
                ),
              ),
              _buildSection(
                  title: "Location",
                  child: SizedBox(
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(5.261832, 103.165598),
                              zoom: 18.5,
                            ),
                            markers: _markers,
                            onTap: _onMapTapped,
                            scrollGesturesEnabled: true,
                            zoomControlsEnabled: true,
                            myLocationEnabled: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ElevatedButton.icon(
                onPressed: _saveAd,
                label: const Text('Create Ad', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(36, 95, 117, 1),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 35),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      color: Colors.grey[100],
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
