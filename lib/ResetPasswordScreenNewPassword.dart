import 'package:flutter/material.dart';
import 'package:wastmanagement/CustomAppBar.dart';

class ResetPasswordNewPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'إعادة تعيين كلمة مرور جديدة',
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
                  hintText: 'كلمة المرور',
                  suffixIcon: Icon(Icons.password),
                  border: OutlineInputBorder(),
                ),

              ), 
              SizedBox(height: 20,),
              
              TextField(
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: ' تأكيد كلمة المرور',
                  suffixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                                obscureText: true, 

              ),
              
              
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                 },
                child: Text('تأكيد ومتابعة'),
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
