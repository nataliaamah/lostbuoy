import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class ViewMyAdsPage extends StatefulWidget {
  const ViewMyAdsPage({Key? key}) : super(key: key);

  @override
  _ViewMyAdsPageState createState() => _ViewMyAdsPageState();
}

class _ViewMyAdsPageState extends State<ViewMyAdsPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(
        child: Text("You need to log in to view your ads."),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Ads"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ads')
            .where('createdBy', isEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  const Text(
                    "No ads created yet",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Create your first ad to see it here!",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final activeAds = snapshot.data!.docs
              .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return !data.containsKey('status') || data['status'] != 'solved';
          })
              .toList();

          final solvedAds = snapshot.data!.docs
              .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data.containsKey('status') && data['status'] == 'solved';
          })
              .toList();

          return ListView(
            children: [
              if (activeAds.isNotEmpty) _buildSectionHeader("Active Ads"),
              ...activeAds.map((doc) => _buildAdCard(doc)),

              if (solvedAds.isNotEmpty) _buildSectionHeader("Solved Ads"),
              ...solvedAds.map((doc) => _buildAdCard(doc, isSolved: true)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAdCard(QueryDocumentSnapshot doc, {bool isSolved = false}) {
    final adData = doc.data() as Map<String, dynamic>? ?? {};
    final String adId = doc.id;

    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                base64Decode(adData['imageBase64'] ?? ''),
                fit: BoxFit.cover,
                width: 60,
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported);
                },
              ),
            ),
            title: Text(
              adData['title'] ?? "No Title",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              adData['description'] ?? "No Description",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              adData['createdAt'] != null
                  ? DateFormat('EEE, MMM d').format(
                (adData['createdAt'] as Timestamp).toDate(),
              )
                  : "Unknown Date",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          if (!isSolved) _buildRequestSection(adId),
        ],
      ),
    );
  }

  Widget _buildRequestSection(String adId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ads')
          .doc(adId)
          .collection('requests')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "No requests yet.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final requests = snapshot.data!.docs;

        return Column(
          children: requests.map((requestDoc) {
            final requestData = requestDoc.data() as Map<String, dynamic>;

            return ListTile(
              title: Text(requestData['requesterName'] ?? "Unknown"),
              subtitle: Text(
                "Request Type: ${requestData['type']}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              trailing: ElevatedButton(
                onPressed: () async {
                  await _acceptRequest(adId, requestDoc.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Accept", style: TextStyle(color: Colors.white),),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _acceptRequest(String adId, String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('ads')
          .doc(adId)
          .collection('requests')
          .doc(requestId)
          .update({'status': 'solved'});

      await FirebaseFirestore.instance
          .collection('ads')
          .doc(adId)
          .update({'status': 'solved'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request accepted. Ad marked as solved.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error accepting request: $e")),
      );
    }
  }
}
