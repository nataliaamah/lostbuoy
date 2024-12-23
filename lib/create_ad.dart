import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class CreateAdPage extends StatefulWidget {
  @override
  State<CreateAdPage> createState() => _CreateAdPageState();
}

class _CreateAdPageState extends State<CreateAdPage> {
  final _formKey = GlobalKey<FormState>();
  String? title, description, postType = 'Lost';
  XFile? image;
  LatLng? selectedLocation;

  final Set<Marker> _markers = {};

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      image = pickedImage;
    });
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

  Future<void> _saveAd() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check if an image has been selected
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload an image.')));
        return;
      }

      // Check if a location has been selected
      if (selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a location on the map.')));
        return;
      }

      // Upload the image to Firebase Storage
      String? imageUrl = await _uploadImage(File(image!.path));

      // Check if the image upload succeeded
      if (imageUrl != null) {
        try {
          // Save the ad data to Firestore
          await FirebaseFirestore.instance.collection('ads').add({
            'title': title,
            'description': description,
            'postType': postType,
            'imageUrl': imageUrl,
            'location': GeoPoint(selectedLocation!.latitude, selectedLocation!.longitude),
            'createdAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ad created successfully')));
          Navigator.of(context).pop();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating ad: $e')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error uploading the image.')));
      }
    }
  }


  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      TaskSnapshot uploadTask =
      await FirebaseStorage.instance.ref('ad_images/$fileName').putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Soft white background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Create Ad',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Upload Section
            _buildSection(
              title: "Upload Item Photo",
              child: GestureDetector(
                onTap: _selectImage,
                child: Container(
                  height: 180,
                  width: 400,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: image == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.upload, size: 50, color: Colors.black),
                      SizedBox(height: 8),
                      Text(
                        'Tap to Upload',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(image!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Google Maps Section
            _buildSection(
              title: "Select Location",
              child: SizedBox(
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
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
            ),
            const SizedBox(height: 20),

            // Title and Description Section
            _buildSection(
              title: "Details",
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Title',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    onSaved: (value) => title = value,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    onSaved: (value) => description = value,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Floating Action Button
            ElevatedButton(
              onPressed: _saveAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50), // Green
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Create Ad',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Color.fromRGBO(231, 231, 231, 1.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
