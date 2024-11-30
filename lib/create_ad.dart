import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  // Function to select an image
  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      image = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Create Ad'),
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
                    child: Icon(Icons.upload_file, size: 50),
                  )
                      : Image.file(File(image!.path)),
                ),
                SizedBox(height: 16),

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
                    Text('Lost'),
                    Radio<String>(
                      value: 'Found',
                      groupValue: postType,
                      onChanged: (value) {
                        setState(() {
                          postType = value;
                        });
                      },
                    ),
                    Text('Found'),
                  ],
                ),
                SizedBox(height: 16),

                // Title Input Field
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
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
                SizedBox(height: 16),

                // Description Input Field
                TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(labelText: 'Description'),
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
                SizedBox(height: 16),

                // Select Location Button (dummy placeholder)
                ElevatedButton(
                  onPressed: () {
                    // Handle location selection here
                  },
                  child: Text('Select Location'),
                ),
                SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Here you can submit the ad data (upload image, save title, description, etc.)
                      print('Title: $title, Description: $description, Post Type: $postType');
                    }
                  },
                  child: Text('Create Ad'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
