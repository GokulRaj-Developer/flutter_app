import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final String firstName = args?['firstName'] ?? 'User';

    return Scaffold(
      appBar: AppBar(title: const Text("Validation Success")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 20),
              const Text(
                "All Checks Passed!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const SuccessCheckItem(label: "✅ Uniform Matched"),
              const SuccessCheckItem(label: "✅ Mask removed"),
              const SuccessCheckItem(label: "✅ Religious headwear removed"),
              const SuccessCheckItem(label: "✅ Live face validated"),
              const SizedBox(height: 40),
              Text(
                "Welcome, $firstName!",
                style: const TextStyle(fontSize: 20, color: Colors.brown),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SuccessCheckItem extends StatelessWidget {
  final String label;

  const SuccessCheckItem({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
