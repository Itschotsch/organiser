import 'package:flutter/material.dart';

import 'pages/entity_page.dart';
import 'pages/home_page.dart';
import 'pages/modify_entity_page.dart';
import 'pages/scanner_page.dart';
import 'pages/tags_page.dart';

void main() {
  runApp(const OrganiserApp());
}

class OrganiserApp extends StatelessWidget {
  const OrganiserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Inventory",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        "/": (context) => const HomePage(),
        "/entity": (context) => const EntityPage(),
        "/modify-entity": (context) => const ModifyEntityPage(),
        "/scanner": (context) => const ScannerPage(),
        "/tags": (context) => const TagsPage(),
      },
    );
  }
}
