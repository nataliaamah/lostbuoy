import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewAdPage extends StatefulWidget {
  final Map<String, dynamic> adData;

  const ViewAdPage({Key? key, required this.adData}) : super(key: key);

  @override
  _ViewAdPageState createState() => _ViewAdPageState();
}

class _ViewAdPageState extends State<ViewAdPage> {
  String creatorName = 'Loading...';
  String phoneNumber = '+60123456789'; // Placeholder phone number

  @override
  void initState() {
    super.initState();
    fetchCreatorDetails(widget.adData['createdBy']);
  }

  Future<void> fetchCreatorDetails(String userId) async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          creatorName = data['displayName'] ?? 'No Name';
          phoneNumber = data['phoneNumber'] ?? '+60123456789'; // Replace with real phone logic
        });
      } else {
        setState(() {
          creatorName = 'Unknown User';
        });
      }
    } catch (e) {
      setState(() {
        creatorName = 'Error fetching name';
      });
      debugPrint('Error fetching user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final GeoPoint location = widget.adData['location'];
    final LatLng adLocation = LatLng(location.latitude, location.longitude);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar with image
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.memory(
                base64Decode(widget.adData['imageBase64']),
                fit: BoxFit.cover,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Ad content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Type
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.adData['postType'] == 'Found'
                          ? Colors.green[100]
                          : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.adData['postType'],
                      style: TextStyle(
                        color: widget.adData['postType'] == 'Found'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    widget.adData['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Time
                  // Date Row
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        DateFormat('EEE, MMM d, yyyy').format(
                          (widget.adData['createdAt'] as Timestamp).toDate(),
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 20, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        DateFormat('h:mm a').format(
                          (widget.adData['createdAt'] as Timestamp).toDate(),
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  const Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.adData['description'] ?? 'No Description',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  // Map Section
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: adLocation,
                        zoom: 16,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('adLocation'),
                          position: adLocation,
                        ),
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),

                  // Contact Information
                  // Contact Section
                  const Text(
                    'Contact Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.person, size: 30, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            creatorName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phoneNumber,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

// WhatsApp Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final whatsappUrl = 'https://wa.me/$phoneNumber';
                        launchUrl(Uri.parse(whatsappUrl));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                      label: const Text(
                        'Contact via WhatsApp',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

// Claim/Solve Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.adData['createdBy'] == FirebaseAuth.instance.currentUser?.uid) {
                          // Logic to mark the ad as solved
                          FirebaseFirestore.instance
                              .collection('ads')
                              .doc(widget.adData['id']) // Ensure ad document ID is passed
                              .update({'status': 'solved'}).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ad marked as solved')),
                            );
                            Navigator.pop(context); // Go back to the previous screen
                          });
                        } else {
                          // Logic to claim the item
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('You have claimed the item!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.adData['createdBy'] ==
                            FirebaseAuth.instance.currentUser?.uid
                            ? Colors.redAccent
                            : Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.adData['createdBy'] == FirebaseAuth.instance.currentUser?.uid
                            ? 'Solve Ad'
                            : 'Claim Item',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
