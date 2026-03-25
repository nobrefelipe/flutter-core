import 'package:flutter/material.dart';

class AppLoaderScreen extends StatelessWidget {
  const AppLoaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
