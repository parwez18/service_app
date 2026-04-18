import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // Open email app
  Future<void> _openEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'khujoapp@gmail.com',
      queryParameters: {'subject': 'Hello Dost App Support'},
    );
    if (!await launchUrl(emailLaunchUri)) {
      throw Exception('Could not open email app');
    }
  }

  // Open phone dialer
  Future<void> _callNumber() async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: '+919242925400');
    if (!await launchUrl(phoneLaunchUri)) {
      throw Exception('Could not launch phone dialer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Help & Support",
          style: TextStyle(color: Colors.white, fontSize: 26.sp),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 29, 28, 28),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: ListView(
          children: [
            Card(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text(
                  'Email Support',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('khujoapp@gmail.com'),
                onTap: _openEmail,
              ),
            ),
            SizedBox(height: 5.h),
            Card(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: const Text(
                  'Call Support',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('+91 9242925400'),
                onTap: _callNumber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
