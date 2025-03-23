import 'package:flutter/material.dart';

class AuthVerificationLoadingPage extends StatefulWidget {
  const AuthVerificationLoadingPage({Key? key}) : super(key: key);

  @override
  State<AuthVerificationLoadingPage> createState() => _AuthVerificationLoadingPageState();
}

class _AuthVerificationLoadingPageState extends State<AuthVerificationLoadingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('본인인증 진행중'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

