import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class EditChallengeScreen extends StatefulWidget {
  final String challengeId;  

  EditChallengeScreen({required this.challengeId});

  @override
  _EditChallengeScreenState createState() => _EditChallengeScreenState();
}

class _EditChallengeScreenState extends State<EditChallengeScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController = TextEditingController();
  late TextEditingController _descriptionController = TextEditingController();
  late TextEditingController _goalController = TextEditingController();
  late TextEditingController _sponsorController = TextEditingController();
  late TextEditingController _sponsorContactController =
      TextEditingController();
  late TextEditingController _socialMediaLinkController =
      TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    loadChallengeData();
  }

  void loadChallengeData() async {
    DocumentSnapshot challengeSnapshot = await FirebaseFirestore.instance
        .collection('challenges')
        .doc(widget.challengeId)
        .get();

    var challenge = challengeSnapshot.data() as Map<String, dynamic>;


    _titleController.text = challenge['title'] ?? '';
    _descriptionController.text = challenge['description'] ?? '';
    _goalController.text = challenge['goal'] ?? '';
    _sponsorController.text = challenge['sponsor'] ?? '';
    _sponsorContactController.text = challenge['sponsorContact'] ?? '';
    _socialMediaLinkController.text = challenge['socialMediaLink'] ?? '';
    _startDate = DateTime.tryParse(challenge['startDate']);
    _endDate = DateTime.tryParse(challenge['endDate']);


    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل التحدي'),
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
                buildTextField(_titleController, 'عنوان التحدي'),
                buildTextField(_descriptionController, 'وصف التحدي'),
                buildTextField(_goalController, 'الهدف'),
                buildTextField(_sponsorController, 'داعم المكافئة'),
                buildTextField(_sponsorContactController, 'رقم الداعم'),
                buildTextField(_socialMediaLinkController, 'رابط سوشيال ميديا'),
                buildDateTile(context, 'تاريخ بداية التحدي:', _startDate,
                    (dt) => _startDate = dt),
                buildDateTile(context, 'تاريخ نهاية التحدي:', _endDate,
                    (dt) => _endDate = dt),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        updateChallenge();
                        Navigator.pop(context);
                      }
                    },
                    child: Text('تحديث التحدي'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Widget buildDateTile(BuildContext context, String label, DateTime? date,
      Function(DateTime) onDateSelected) {
    return ListTile(
      title: Text(
          '$label ${date != null ? DateFormat('yyyy-MM-dd').format(date) : 'Select date'}'),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            onDateSelected(pickedDate);
          });
        }
      },
    );
  }

  void updateChallenge() {
    var challenge = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'goal': _goalController.text,
      'sponsor': _sponsorController.text,
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
      'sponsorContact': _sponsorContactController.text,
      'socialMediaLink': _socialMediaLinkController.text,
    };

    FirebaseFirestore.instance
        .collection('challenges')
        .doc(widget.challengeId)
        .update(challenge);
  }
}
