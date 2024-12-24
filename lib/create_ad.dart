import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';

class CreateAdPage extends StatefulWidget {
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

  // Function to save ad to Firestore
  Future<void> _saveAd() async {
    if (!_formKey.currentState!.validate()) {
      return; // If validation fails, exit the function
    }

    // Save form fields
    _formKey.currentState!.save();

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
      final bytes = await File(image!.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      // Save to Firestore
      await FirebaseFirestore.instance.collection('ads').add({
        'title': title,
        'description': description,
        'postType': postType,
        'imageBase64': base64Image,
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
      appBar: AppBar(
        title: const Text('Create Ad', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: image == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.upload, size: 50),
                        SizedBox(height: 8),
                        Text('Tap to upload'),
                      ],
                    )
                        : Image.file(
                      File(image!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              _buildSection(
                title: "Details",
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Title'),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      maxLines: 3,
                      decoration: InputDecoration(labelText: 'Description'),
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
              const SizedBox(height: 20),
              _buildSection(
                title: "Location",
                child: SizedBox(
                  height: 250,
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(5.261832, 103.165598),
                      zoom: 18,
                    ),
                    markers: _markers,
                    onTap: _onMapTapped,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAd,
                child: const Text('Create Ad'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
