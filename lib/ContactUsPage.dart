import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تواصل معنا'),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'أرسل لنا رسالة',
                style: TextStyle(
                  color: Colors.green[800],
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _messageController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك هنا...',
                  hintStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _isSending
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: Icon(Icons.send),
                      label: Text('إرسال الرسالة'),
                      onPressed: _sendMessage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.green, 
                        padding: EdgeInsets.symmetric(vertical: 12),
                        textStyle: TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
              SizedBox(height: 30),
              Text(
                'أو تواصل معنا عبر الطرق التالية:',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildContactOption(
                icon: Icons.email,
                text: 'Rasskalh@gmail.com',
                onTap: _sendEmail,
              ),
              _buildContactOption(
                icon: Icons.phone,
                text: '+1234567890',
                onTap: () => _makePhoneCall('+1234567890'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactOption({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(text),
      onTap: onTap,
    );
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a message to send.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final Email email = Email(
        body: _messageController.text,
        subject: 'Contact Us Message',
        recipients: ['Rasskalh@gmail.com'],
        isHTML: false,
      );
      await FlutterEmailSender.send(email);
      _showSentDialog();
    } catch (e) {
      print('Failed to send email: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send email.'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showSentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تم الإرسال'),
        content: Text('تم إرسال رسالتك بنجاح'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('حسنًا', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmail() async {
    try {
      final Email email = Email(
        body: 'Hello from Rasskalh app!',
        subject: 'Email Subject',
        recipients: ['Rasskalh@gmail.com'],
        isHTML: false,
      );
      await FlutterEmailSender.send(email);
    } catch (e) {
      print('Failed to send email: $e');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $phoneNumber');
    }
  }
}
