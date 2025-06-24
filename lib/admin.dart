import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastmanagement/ManageChallengesScreen.dart';
import 'package:wastmanagement/ManageUsersScreen.dart';
import 'package:wastmanagement/RewardManagementScreen.dart';
import 'package:wastmanagement/login.dart';   

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}
class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('لوحة تحكم الإدارة'),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: ListView(
          children: <Widget>[
            _buildDashboardTile('إدارة المكافآت', Icons.card_giftcard, () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => RewardsListScreen()));
            }),
            _buildDashboardTile('إدارة التحديات', Icons.card_giftcard, () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ManageChallengesScreen()));
            }),
            _buildDashboardTile('إدارة المستخدمين', Icons.person, () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ManageUsersScreen()));
            }),
            _buildDashboardTile('تسجيل الخروج', Icons.exit_to_app, () {
              _logout();
            }),
          ],
        ),
      ),
    );
  }
  ListTile _buildDashboardTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 30.0),
      title: Text(title, style: TextStyle(fontSize: 18.0)),
      onTap: onTap,
    );
  }
  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
  }
}

 