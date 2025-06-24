import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class NearestCenterPage extends StatefulWidget {
  @override
  _NearestCenterPageState createState() => _NearestCenterPageState();
}

class _NearestCenterPageState extends State<NearestCenterPage> {
  List<Map<String, dynamic>> centers = [];
  Map<String, bool> hasRequested = {};

  bool isLoading = true;
  Position? currentUserPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showError('خدمات الموقع غير مفعلة.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showError('تم رفض إذن الموقع.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showError('تم رفض إذن الموقع بشكل دائم.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentUserPosition = position;
    });
    fetchNearestCenters();
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('خطأ', textAlign: TextAlign.right),
        content: Text(message, textAlign: TextAlign.right),
        actions: <Widget>[
          TextButton(
            child: Text('حسنًا', style: TextStyle(color: Colors.green)),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

 void fetchNearestCenters() async {
    if (currentUserPosition == null) {
      return;
    }

    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('type', isEqualTo: 'recycling_center')
        .get();

    var currentUser = FirebaseAuth.instance.currentUser;
    var requestsSnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('sender_id', isEqualTo: currentUser?.uid)
        .where('status', isEqualTo: 'pending')
        .get();

    var pendingRequests = {
      for (var doc in requestsSnapshot.docs) doc.data()['center_id']: true
    };

    var loadedCenters = snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      double lat = double.parse(data['location'].split(', ')[0]);
      double lng = double.parse(data['location'].split(', ')[1]);
      double distance = Geolocator.distanceBetween(
        currentUserPosition!.latitude, currentUserPosition!.longitude, lat, lng);

      return {
        'id': doc.id,
        'name': data['name'],
        'distance': distance / 1000,
        'location': data['location'],
        'email': data['email'],
        'phone': data['phone'],
        'isRequested': pendingRequests.containsKey(doc.id)
      };
    }).toList();

    loadedCenters.sort((a, b) => a['distance'].compareTo(b['distance']));

    setState(() {
      centers = loadedCenters;
      isLoading = false;
    });
  }
   void sendRequest(String centerId) {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && !(hasRequested[centerId] ?? false)) {
      FirebaseFirestore.instance.collection('requests').add({
        'sender_id': currentUser.uid,
        'center_id': centerId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending'
      }).then((value) {
        setState(() {
          hasRequested[centerId] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إرسال الطلب بنجاح!'))
        );
      }).catchError((error) {
        showError('فشل في إرسال الطلب: $error');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم بالفعل إرسال طلب وهو قيد التنفيذ.'))
      );
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختر مركز التدوير الأقرب'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: centers.length,
              separatorBuilder: (context, index) => Divider(color: Colors.grey),
              itemBuilder: (context, index) {
                var center = centers[index];
                bool isRequested = center['isRequested'];
                return ListTile(
                  leading: Icon(Icons.location_on, color: Colors.green),
                  title: Text(center['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${center['distance'].toStringAsFixed(2)} كم'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.directions, color: Colors.blue),
                        onPressed: () => launchUrl(Uri.parse("google.navigation:q=${center['location']}")),
                      ),
                      IconButton(
                        icon: Icon(Icons.call, color: Colors.blue),
                        onPressed: () => launchUrl(Uri.parse("tel:${center['phone']}")),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: isRequested ? Colors.grey : Colors.red),
                        onPressed: isRequested ? null : () => sendRequest(center['id']),
                      ),
                    ],
                  ),
                  onTap: () {

                  },
                );
              },
            ),
    );
  }
}