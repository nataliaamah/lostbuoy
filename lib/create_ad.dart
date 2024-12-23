import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class CreateAdPage extends StatefulWidget {
  const CreateAdPage({super.key});

  @override
  _CreateAdPageState createState() => _CreateAdPageState();
}

class _CreateAdPageState extends State<CreateAdPage> {
  final _formKey = GlobalKey<FormState>();
  String? title, description, postType;
  XFile? image;
  LatLng? selectedLocation; // Store the selected location

  final Set<Marker> _markers = {}; // To hold markers on the map

  // Function to select an image
  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      image = pickedImage;
    });
  }

  // Function to select location using Google Maps (user tapping)
  void _onMapTapped(LatLng location) {
    setState(() {
      selectedLocation = location;
      // Add a marker where the user tapped
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('selected_location'),
        position: location,
        infoWindow: const InfoWindow(title: 'Selected Location'),
      ));
    });
  }

  // Function to save the ad and upload to Firestore and Storage
  Future<void> _saveAd() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a location')));
        return;
      }

      // Upload the image and get the download URL
      String? imageUrl = await _uploadImage(File(image!.path));

      if (imageUrl != null) {
        // Save the ad data to Firestore
        try {
          await FirebaseFirestore.instance.collection('ads').add({
            'title': title,
            'description': description,
            'postType': postType,
            'imageUrl': imageUrl,
            'location': GeoPoint(selectedLocation!.latitude, selectedLocation!.longitude), // Store location
            'createdAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ad created successfully')));
          // Optionally, navigate back or reset the form
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating ad: $e')));
        }
      }
    }
  }

  // Function to upload the image to Firebase Storage
  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      TaskSnapshot uploadTask = await FirebaseStorage.instance.ref('ad_images/$fileName').putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create Ad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Upload Section
                GestureDetector(
                  onTap: _selectImage,
                  child: image == null
                      ? Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.upload_file, size: 50),
                  )
                      : Image.file(File(image!.path)),
                ),
                const SizedBox(height: 16),

                // Post Type (Radio Buttons)
                Row(
                  children: [
                    Radio<String>(
                      value: 'Lost',
                      groupValue: postType,
                      onChanged: (value) {
                        setState(() {
                          postType = value;
                        });
                      },
                    ),
                    const Text('Lost'),
                    Radio<String>(
                      value: 'Found',
                      groupValue: postType,
                      onChanged: (value) {
                        setState(() {
                          postType = value;
                        });
                      },
                    ),
                    const Text('Found'),
                  ],
                ),
                const SizedBox(height: 16),

                // Title Input Field
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    title = value;
                  },
                ),
                const SizedBox(height: 16),

                // Description Input Field
                TextFormField(
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    description = value;
                  },
                ),
                const SizedBox(height: 16),

                // Google Maps Section (Select Location)
                SizedBox(
                  height: 250,
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(5.261832, 103.165598),
                      zoom: 18,
                    ),
                    markers: _markers,
                    onTap: _onMapTapped, // Set the location on tap
                  ),
                ),
                const SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: _saveAd,
                  child: const Text('Create Ad'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
