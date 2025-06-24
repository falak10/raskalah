import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wastmanagement/RecyclingCenterDashboard.dart';
import 'package:wastmanagement/admin.dart';
import 'package:wastmanagement/home.dart';
import 'package:wastmanagement/main_page.dart';
import 'package:wastmanagement/usertype.dart';
 

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController(text: 'c@a.com');
  final TextEditingController passwordController = TextEditingController(text: '123456');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _errorMessage = '';
 @override
  void initState() {
    super.initState();

  }

  _checkLogin() async {
    if (_auth.currentUser != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      

        if (userDoc.exists && userDoc.data()!['type'] == 'admin') {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => AdminDashboard()));
        } else if (userDoc.exists &&
            userDoc.data()!['type'] == 'recycling_center') {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => RecyclingCenterDashboard()));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => MainScreen()));
        }
      } else {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
        return;
      
    }
  }

void _sendPasswordResetEmail() async {
  if (emailController.text.isEmpty || !EmailValidator.validate(emailController.text.trim())) {
    setState(() {
      _errorMessage = 'Please enter a valid email address for password reset.';
    });
    return;
  }

  try {
    await _auth.sendPasswordResetEmail(email: emailController.text.trim());
    setState(() {
      _errorMessage = 'Password reset link sent to ${emailController.text}. Please check your email.';
    });
  } catch (e) {
     setState(() {
      _errorMessage = 'Error sending password reset email: ${e.toString()}';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تسجيل دخول'),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 40),
                Text('مرحباً بعودتك!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                SizedBox(height: 30),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    if (!EmailValidator.validate(value)) {
                      return 'البريد الإلكتروني غير صالح';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      User? user = (await _auth.signInWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      ))
                          .user;
                      if (user != null) {
                        _checkLogin();
                      }
                    } catch (e) {
                      setState(() {
                        _errorMessage = e.toString();
                      });
                    }
                  },
                  child: Text('تسجيل دخول'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                TextButton(
                  onPressed: _sendPasswordResetEmail,
                  child: Text(
                    'نسيت كلمة المرور؟',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => UserTypePage()));
                  },
                  child: Text(
                    'ليس لديك حساب؟ انقر للتسجيل',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

