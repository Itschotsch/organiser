import 'package:flutter/material.dart';
import 'package:organiser/pages/home_page.dart';
import 'package:organiser/pages/modify_entity_page.dart';
import 'package:organiser/pages/scanner_page.dart';

void main() {
  runApp(const OrganiserApp());
}

class OrganiserApp extends StatelessWidget {
  const OrganiserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Organiser App",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        "/": (context) => const HomePage(),
        "/modify-entity": (context) => const ModifyEntityPage(),
        "/scanner": (context) => const ScannerPage(),
      },
    );
  }
}
