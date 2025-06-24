import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wastmanagement/ContactUsPage.dart';
import 'package:wastmanagement/EditUserInfoPage.dart';
import 'package:wastmanagement/ChangePasswordPage.dart';  
import 'package:wastmanagement/SomeInfoPage.dart';

import 'package:wastmanagement/login.dart';

class PersonalPage extends StatefulWidget {
  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  User? user = FirebaseAuth.instance.currentUser;
  String username = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        username = userData['name'];
        email = userData['email'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('الصفحة الشخصية'),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: buildBody(),
      ),
    );
  }

  ListView buildBody() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(username, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(email, style: TextStyle(fontSize: 16, color: Colors.grey)),
              Divider(),
              _buildListTile('معلوماتك الشخصية', Icons.person_outline, EditUserInfoPage()),
              _buildListTile('تغيير كلمة المرور', Icons.lock_outline, ChangePasswordPage()),
              _buildListTile('وش يعني رسكلة؟', Icons.info_outline, RecyclingInfoPage()),
              _buildListTile('تواصل معنا', Icons.phone, ContactUsPage()),
              _buildLogOutTile('تسجيل الخروج', Icons.exit_to_app),
            ],
          ),
        ),
      ],
    );
  }

  ListTile _buildListTile(String title, IconData icon, Widget destinationPage) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => destinationPage)),
    );
  }

  ListTile _buildLogOutTile(String title, IconData icon) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.red)),
      leading: Icon(icon, color: Colors.red),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.red),
      onTap: () {
        FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      },
    );
  }
}
