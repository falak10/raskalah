
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'dart:ui' as ui;

class AddChallengeScreen extends StatefulWidget {
  @override
  _AddChallengeScreenState createState() => _AddChallengeScreenState();
}

class _AddChallengeScreenState extends State<AddChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController(text: 'تحدي جديد');
  TextEditingController _descriptionController = TextEditingController(text: 'تحدي جديد عبارة عن ...');
  TextEditingController _goalController = TextEditingController(text: 'الهدف هو');
  TextEditingController _sponsorController = TextEditingController(text: 'كافي ');
  TextEditingController _sponsorContactController = TextEditingController(text: '00000000');
  TextEditingController _socialMediaLinkController = TextEditingController(text: 'x.com/coffee');
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أضف تحدياً جديداً'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Directionality(
textDirection: ui.TextDirection.rtl,
       
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'عنوان التحدي'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a challenge title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'وصف التحدي'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a challenge description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _goalController,
                  decoration: InputDecoration(labelText: 'الهدف'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a goal for the challenge';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _sponsorController,
                  decoration: InputDecoration(labelText: 'داعم المكافئة'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a sponsor name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _sponsorContactController,
                  decoration: InputDecoration(labelText: 'رقم الداعم'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a contact number for the sponsor';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _socialMediaLinkController,
                  decoration: InputDecoration(labelText: 'رابط سوشيال ميديا'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a social media link';
                    }
                    return null;
                  },
                ),
                ListTile(
                  title: Text('تاريخ بداية التحدي: ${_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'Select date'}'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _startDate = pickedDate;
                      });
                    }
                  },
                ),
                ListTile(
                  title: Text('تاريخ نهاية التحدي: ${_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'Select date'}'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _endDate = pickedDate;
                      });
                    }
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        var newChallenge = Challenge(
                          title: _titleController.text,
                          description: _descriptionController.text,
                          goal: _goalController.text,
                          sponsor: _sponsorController.text,
                          startDate: _startDate!.toLocal()!,
                          endDate: _endDate!.toLocal()!,
                          sponsorContact: _sponsorContactController.text,
                          socialMediaLink: _socialMediaLinkController.text,
                        );
                        addChallengeToFirestore(newChallenge);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('أضف التحدي'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addChallengeToFirestore(Challenge challenge) {
    FirebaseFirestore.instance.collection('challenges').add(challenge.toMap());
  }
}





class Challenge {
  String title;
  String description;
  String goal;
  String sponsor;
  DateTime startDate;
  DateTime endDate;
  String sponsorContact;
  String socialMediaLink;

  Challenge({
    required this.title,
    required this.description,
    required this.goal,
    required this.sponsor,
    required this.startDate,
    required this.endDate,
    required this.sponsorContact,
    required this.socialMediaLink,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'goal': goal,
      'sponsor': sponsor,
      'startDate':  startDate.toString(),
      'endDate': endDate.toString(),
      'sponsorContact': sponsorContact,
      'socialMediaLink': socialMediaLink,
    };
  }
}
