import 'package:flutter/material.dart';
import 'package:wastmanagement/CustomAppBar.dart';

class ResetPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'استعادة كلمة المرور',
          onBackTap: () => Navigator.of(context).pop(),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 100,),
              TextField(
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ادخل البريد الإلكتروني',
                  suffixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),  
              Text(
                'اكتب عنوان بريدك الإلكتروني وسوف نرسل تعليمات لإعادة تعيين كلمة المرور الخاصة بك.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,  
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                 },
                child: Text('إرسال'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
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
