import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/user_info_screen.dart';
import 'screens/facial_capture_screen.dart';
import 'screens/face_validation_screen.dart';
import 'screens/success_screen.dart';

void main() {
  runApp(const GistRationApp());
}

class GistRationApp extends StatelessWidget {
  const GistRationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gist Ration App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/user_info': (context) => const UserInfoScreen(),
        '/facial_capture': (context) => const FacialCaptureScreen(),
        '/face_validation': (context) => const FaceValidationScreen(),
        '/success': (context) => const SuccessScreen(),
      },
    );
  }
}
