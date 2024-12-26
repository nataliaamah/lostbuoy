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
  String phoneNumber = '+60123456789'; // Default placeholder
  final currentUser = FirebaseAuth.instance.currentUser;

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
          phoneNumber = data['phoneNumber'] ?? '+60123456789'; // Adjust as necessary
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

  Future<void> handleAction() async {
    try {
      if (widget.adData['createdBy'] == currentUser?.uid) {
        // If the current user is the creator, verify claims
        await FirebaseFirestore.instance
            .collection('ads')
            .doc(widget.adData['id'])
            .update({'status': 'solved'});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad marked as solved')),
        );
        Navigator.pop(context);
      } else {
        // If the current user is not the creator, request to claim/return the item
        await FirebaseFirestore.instance
            .collection('ads')
            .doc(widget.adData['id'])
            .collection('requests')
            .doc(currentUser?.uid)
            .set({
          'requesterId': currentUser?.uid,
          'requesterName': currentUser?.displayName,
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent to the ad owner.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final GeoPoint location = widget.adData['location'];
    final LatLng adLocation = LatLng(location.latitude, location.longitude);

    return Scaffold(
      backgroundColor: Colors.white,
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

                  // Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 20, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        DateFormat('EEE, MMM d, yyyy').format(
                          (widget.adData['createdAt'] as Timestamp).toDate(),
                        ),
                        style:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Time
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 20, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        DateFormat('h:mm a').format(
                          (widget.adData['createdAt'] as Timestamp).toDate(),
                        ),
                        style:
                        const TextStyle(fontSize: 14, color: Colors.grey),
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
                  const Text(
                    'Contact Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // User Details
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 30, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              creatorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              phoneNumber,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // WhatsApp Button
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.green,
                        child: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                          onPressed: () {
                            final whatsappUrl = 'https://wa.me/$phoneNumber';
                            launchUrl(Uri.parse(whatsappUrl));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Claim/Return Button
                  Center(
                    child: ElevatedButton(
                      onPressed: handleAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.adData['createdBy'] ==
                            currentUser?.uid
                            ? Colors.redAccent
                            : Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: Text(
                        widget.adData['createdBy'] == currentUser?.uid
                            ? 'Verify Request'
                            : (widget.adData['postType'] == 'Found'
                            ? 'Claim Item'
                            : 'Return Item'),
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
