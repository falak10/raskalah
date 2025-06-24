import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      try {
        User? user = FirebaseAuth.instance.currentUser;
        String email = user!.email!;


        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: email, password: _passwordController.text),
        );


        await user.updatePassword(_newPasswordController.text);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("تم تغيير كلمة المرور بنجاح1"),
          backgroundColor: Colors.green,
        ));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("خطا في تغيير كلمة المرور ${e.message}"),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تغيير كلمة المرور'),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: <Widget>[
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور الحالية',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'ادخل كلمة المرور الحالية';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور الجديدة',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'ادخل كلمة مرور جديدة';
                        } else if (value.length < 6) {
                          return 'كلمة المرور يجب ان تكون اكبر من 6 خانات';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'تأكيد كلمة المرور الجديدة',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'قم بتأكيد كلمة المرور الجديدة';
                        } else if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _changePassword,
                      child: Text('تغيير كلمة المرور'),
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
    );
  }
}
