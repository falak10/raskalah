import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserInfoPage extends StatefulWidget {
  @override
  _EditUserInfoPageState createState() => _EditUserInfoPageState();
}

class _EditUserInfoPageState extends State<EditUserInfoPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();  
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _loadUserData();
    }
  }

  void _loadUserData() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    _nameController.text = userData['name'];
    _emailController.text = userData['email'];
  }
void _updateUserData() async {
  if (_formKey.currentState!.validate()) {  
    setState(() {
      _loading = true;
    });
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'name': _nameController.text,
        'email': _emailController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث المعلومات بنجاح'),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context);
    } catch (e) {
      print(e);  

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تحديث المعلومات'),
          backgroundColor: Colors.red,
        )
      );
    }
    setState(() {
      _loading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              color: Colors.green,
            ),
          ),
          title: Text('تحديث المعلومات الشخصية'),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'الاسم',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء اختيار بريد الكتروني';
                          } else if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(value)) {
                            return 'أدخل عنوان بريد إلكتروني صحيح';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _updateUserData,
                        child: Text('حفظ التغييرات'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
