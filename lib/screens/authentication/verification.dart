// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'We have sent a verification email to your email address. If you did not receive the email, please click the button below to resend the email.',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ElevatedButton(
                  onPressed: () async {
                   
                  },
                  child: Text('Resend Verification Email'),
                );
              },
              child: Text('Resend Verification Email'),
            ),
          ],
        ),
      ),
    );
  }
}
