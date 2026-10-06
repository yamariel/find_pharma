import 'package:flutter/material.dart';

class AdminSectionPage extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const AdminSectionPage({
    required this.title,
    required this.message,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
