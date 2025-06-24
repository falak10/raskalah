import 'package:flutter/material.dart';

class RecyclingInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('وش يعني رسكلة؟'),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'ما هي الرسكلة؟',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
              Text(
                'رسكلة هي كلمة معاصرة تشير إلى عملية إعادة التدوير. نهدف من خلال تطبيق "رسكلة" إلى تحفيز وإلهام المستخدمين على إعادة التدوير وجمع النفايات باستخدام تقنية الذكاء الاصطناعي. نهدف أيضًا إلى دعم المشاركة المجتمعية في حماية البيئة وتشجيع المستخدمين على القيام بأعمال تبرع والمساهمة في المحافظة على نظافة البيئة.',
                style: TextStyle(
                  fontSize: 18,
                  height: 1.4,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
              Text(
                'كيف يعمل التطبيق؟',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 10),
              Text(
                'يستخدم تطبيق "رسكلة" تقنيات متقدمة مثل الذكاء الاصطناعي لتحديد نوع النفايات وتصنيفها بشكل تلقائي. يمكن للمستخدمين ببساطة التقاط صورة للنفايات وسيقوم التطبيق بإرشادهم إلى الطريقة الصحيحة لإعادة التدوير.',
                style: TextStyle(
                  fontSize: 18,
                  height: 1.4,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
               
            ],
          ),
        ),
      ),
    );
  }
}
