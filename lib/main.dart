import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/user_info_screen.dart';
import 'screens/facial_capture_screen.dart';
import 'screens/face_validation_screen.dart';
import 'screens/success_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/user_info': (context) => const UserInfoScreen(),
        '/facial_capture': (context) => FacialCaptureScreen(),
        '/face_validation': (context) => const FaceValidationScreen(),
        '/success': (context) => const SuccessScreen(),
      },
    );
  }
}

