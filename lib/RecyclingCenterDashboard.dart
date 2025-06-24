import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wastmanagement/EditUserInfoPage.dart';
import 'package:wastmanagement/RequestsPage.dart';
import 'package:wastmanagement/login.dart';

class RecyclingCenterDashboard extends StatefulWidget {
  @override
  _RecyclingCenterDashboardState createState() => _RecyclingCenterDashboardState();
}

class _RecyclingCenterDashboardState extends State<RecyclingCenterDashboard> {
  final User? user = FirebaseAuth.instance.currentUser;
  double totalWeightAccepted = 0.0;
  int totalDoneRequests = 0;

  @override
  void initState() {
    super.initState();
    setupRealtimeUpdates();
  }

  void setupRealtimeUpdates() {
    if (user != null) {

      FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots().listen((snapshot) {
        if (snapshot.exists && snapshot.data()!.containsKey('total_weight_accepted')) {
          setState(() {
            totalWeightAccepted = (snapshot.data()!['total_weight_accepted'] as num).toDouble();
          });
        }
      });


      FirebaseFirestore.instance
          .collection('requests')
          .where('center_id', isEqualTo: user!.uid)
          .where('status', isEqualTo: 'done')
          .snapshots()
          .listen((snapshot) {
            setState(() {
              totalDoneRequests = snapshot.docs.length;
            });
          });
    }
  }

Widget build(BuildContext context) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(
        title: Text('لوحة التحكم لمركز التدوير'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              'مرحباً بك في لوحة التحكم الخاصة بمركز التدوير!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            buildStatCard('المواد المدورة المقبولة', '${totalWeightAccepted.toStringAsFixed(2)} كغ', Icons.recycling, Colors.green),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditUserInfoPage()));
              },
              child: buildStatCard('معلومات الحساب', '', Icons.account_box_sharp, Colors.green),
            ),
            buildStatCard('عدد الطلبات المكتملة', '$totalDoneRequests طلب', Icons.person_add_alt_1, Colors.amber),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.list),
              label: Text('عرض الطلبات'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => RequestsPage()));
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget buildStatCard(String title, String subtitle, IconData icon, Color iconColor) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
