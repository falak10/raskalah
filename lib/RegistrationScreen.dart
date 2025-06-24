import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'package:wastmanagement/CustomAppBar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:wastmanagement/RecyclingCenterDashboard.dart';

import 'package:wastmanagement/main_page.dart';
import 'package:wastmanagement/login.dart';

class RegistrationScreen extends StatefulWidget {
  final String userType;

  RegistrationScreen({required this.userType});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  // final TextEditingController nameController = TextEditingController();
  // final TextEditingController emailController = TextEditingController();
  // final TextEditingController passwordController = TextEditingController();
  // final TextEditingController confirmPasswordController = TextEditingController();
  // final TextEditingController locationController = TextEditingController();  
  // final TextEditingController phoneController = TextEditingController();  

    final TextEditingController nameController = TextEditingController(text: "أحمد علي");
  final TextEditingController emailController = TextEditingController(text: "a@a.com");
  final TextEditingController passwordController = TextEditingController(text: "123456");
  final TextEditingController confirmPasswordController = TextEditingController(text: "123456");
  final TextEditingController locationController = TextEditingController(); 
  final TextEditingController phoneController = TextEditingController(text: "0591234567"); 

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _errorMessage = '';
 
@override
  void initState() {
    super.initState();
    if (widget.userType == "recycling_center") {
      _determinePosition();
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    } 

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      locationController.text = "${position.latitude}, ${position.longitude}";
    });
  }
 
 
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'حياتك برسكلة',
          onBackTap: () => Navigator.of(context).pop(),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'أنشئ حساب جديد',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 32),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'الاسم',
                    suffixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'الرجاء إدخال الاسم';
                    }
                    if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]').hasMatch(value)) {
                      return 'الاسم يجب أن لا يحتوي على أرقام أو رموز';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'البريد الإلكتروني',
                    suffixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
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
                SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintText: 'رقم الهاتف (اختياري)',
                    suffixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value!.isNotEmpty && value.length < 10) {
                      return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                if (widget.userType == "recycling_center")
                  TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      hintText: 'الموقع',
                      suffixIcon: Icon(Icons.map),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'الرجاء إدخال الموقع';
                      }
                      return null;
                    },
                  ),
                SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'كلمة المرور',
                    suffixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: 'تأكيد كلمة المرور',
                    suffixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'الرجاء تأكيد كلمة المرور';
                    }
                    if (value != passwordController.text) {
                      return 'كلمات المرور غير متطابقة';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        User? user = (await _auth.createUserWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        ))
                            .user;

                        if (user != null) {
                          await _db.collection('users').doc(user.uid).set({
                            'name': nameController.text.trim(),
                            'email': emailController.text.trim(),
                            'phone': phoneController.text.trim(),
                            'type': widget.userType,
                            'location': widget.userType == "recycling_center" ? locationController.text.trim() : "N/A",
                          });
                           if (widget.userType == "recycling_center") {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => RecyclingCenterDashboard())
                          );
                        } else {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
                        }
                        }
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'email-already-in-use') {
                          setState(() {
                            _errorMessage = 'البريد الإلكتروني هذا مستخدم بالفعل';
                          });
                        } else {
                          setState(() {
                            _errorMessage = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
                          });
                        }
                      }
                    }
                  },
                  child: Text('تسجيل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 24),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
                  },
                  child: Text(
                    'لديك حساب بالفعل؟ تسجيل دخول',
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
