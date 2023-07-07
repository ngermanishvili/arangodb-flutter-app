import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AuthenticationApp());
}

class AuthenticationApp extends StatelessWidget {
  const AuthenticationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthorizationPage(),
    );
  }
}

class AuthorizationPage extends StatefulWidget {
  const AuthorizationPage({Key? key}) : super(key: key);

  @override
  _AuthorizationPageState createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  bool _showSmsCodeField = false;
  bool _showVerifyButton = false;

  Future<void> sendSms(String phoneNumber) async {
    const url = 'https://db.kheti-badi.com/_db/kb-2023/samxara/createSession';
    const headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization':
          'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwcmVmZXJyZWRfdXNlcm5hbWUiOiJmcmVlbGFuY2VyIiwiaXNzIjoiYXJhbmdvZGIiLCJpYXQiOjE2ODg2MzEzMzEsImV4cCI6MTY4ODYzNDkzMX0.uTs7Un-_afS3tNVVIFNlMWPpRDlyCma9ydrj78S9AVs',
    };
    final body = jsonEncode({'phoneNumber': phoneNumber});

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final sessionId = responseData['sessionId'];

      setState(() {
        _showSmsCodeField = true;
        _showVerifyButton = true;
      });

      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString('sessionId', sessionId);
    } else {
      print('Failed to send SMS');
    }
  }

  Future<void> verifyOtp(String otp) async {
    const url = 'https://db.kheti-badi.com/_db/kb-2023/samxara/verifyOTP';
    const headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization':
          'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwcmVmZXJyZWRfdXNlcm5hbWUiOiJmcmVlbGFuY2VyIiwiaXNzIjoiYXJhbmdvZGIiLCJpYXQiOjE2ODg2MzEzMzEsImV4cCI6MTY4ODYzNDkzMX0.uTs7Un-_afS3tNVVIFNlMWPpRDlyCma9ydrj78S9AVs',
    };

    final sharedPreferences = await SharedPreferences.getInstance();
    final sessionId = sharedPreferences.getString('sessionId');

    if (sessionId != null) {
      final body = jsonEncode({
        'sessionId': otp,
      });

      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        // OTP verification successful
        // TODO: Handle the successful verification case
        print(response.body);
      } else {
        // OTP verification failed
        print('Failed to verify OTP. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } else {
      print('SessionId is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authorization')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Enter your phone number (India only):',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  hintText: 'Phone number',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                style: const TextStyle(fontSize: 18),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length != 10 || !value.startsWith('91')) {
                    return 'Please enter a valid Indian phone number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final phoneNumber = _phoneNumberController.text;
                  await sendSms(phoneNumber);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            if (_showSmsCodeField)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Enter the SMS code:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _smsCodeController,
                      decoration: const InputDecoration(
                        hintText: 'SMS code',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final otp = _smsCodeController.text;
                        await verifyOtp(otp);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Verify',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
