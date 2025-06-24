import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastmanagement/RecyclingCenterDashboard.dart';
import 'package:wastmanagement/UserRewardsScreen.dart';
import 'package:wastmanagement/admin.dart';
import 'package:wastmanagement/login.dart';
import 'package:wastmanagement/main_page.dart';

 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Cairo',
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.done) {
                    if (userSnapshot.data != null && userSnapshot.data!.exists) {
                      Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                      if (userData['type'] == 'admin') {
                      return AdminDashboard();  
                    } else if (userData['type'] == 'recycling_center') {
                      return RecyclingCenterDashboard();  
                    } else {

                      return MainScreen();  
                    }
                    } else {
                      return LoginScreen();  
                    }
                  }
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),  
                    ),
                  );
                },
              );
            } else {
              return LoginScreen();
            }
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),   
            ),
          );
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
