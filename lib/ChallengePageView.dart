import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class ChallengePageView extends StatefulWidget {
  @override
  _ChallengePageViewState createState() => _ChallengePageViewState();
}

class _ChallengePageViewState extends State<ChallengePageView> {
  final PageController _controller = PageController(viewportFraction: 0.8);

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('yyyy-MM-dd').format(dateTime);  
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('التحديات'),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('challenges').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();

            return PageView.builder(
              controller: _controller,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: SingleChildScrollView( // Allow scrolling within the card
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              "https://media.istockphoto.com/id/1359821482/vector/winner-human-or-happy-human-vector-logo-design.jpg?s=612x612&w=0&k=20&c=VPqmabJ_PAjIYz4Tuy-MAPLq5MjoH2c4DjLS6XMs_JE=",
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 10),
                          buildRow(Icons.title, doc['title'], isBold: true, fontSize: 22),
                          buildRow(Icons.description, doc['description'], fontSize: 18),
                          buildRow(Icons.flag, "الهدف: ${doc['goal']}"),
                          buildRow(Icons.business, "الراعي: ${doc['sponsor']} (${doc['sponsorContact']})"),
                          buildRow(Icons.date_range, "البداية: ${_formatDate(doc['startDate'])}", color: Colors.grey[600]),
                          buildRow(Icons.date_range, "النهاية: ${_formatDate(doc['endDate'])}", iconColor: Colors.red, color: Colors.grey[600]),
                          buildRow(Icons.link, doc['socialMediaLink'], color: Colors.blue, isUnderlined: true),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildRow(IconData icon, String text, {bool isBold = false, double fontSize = 16, Color? color, bool isUnderlined = false, Color iconColor = Colors.teal}) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
              decoration: isUnderlined ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}
