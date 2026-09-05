import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

const adminCode = 'BUKO-ADMIN-2026';
const green = Color(0xFF22C55E);
const blue = Color(0xFF2563EB);
const yellow = Color(0xFFFFC107);
const navy = Color(0xFF07131E);

class User {
  final String name;
  final String phone;
  final String password;
  final String role;
  User(this.name, this.phone, this.password, this.role);
}

class Car {
  final String name;
  final int year;
  final String price;
  final String city;
  final String type;
  final String seller;
  final List<String> images;
  Car(this.name, this.year, this.price, this.city, this.type,
      {this.seller = 'BUKO', this.images = const []});
}

class PurchaseRequest {
  final User buyer;
  final Car car;
  PurchaseRequest(this.buyer, this.car);
}

enum BukoTheme { midnight, emerald, royal }

ThemeData bukoTheme(BukoTheme theme) {
  final seed = theme == BukoTheme.royal ? blue : green;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: navy,
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    cardTheme: const CardThemeData(color: Color(0xFF102434)),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: Colors.black54),
      hintStyle: TextStyle(color: Colors.black45),
      prefixIconColor: Colors.black54,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BukoApp());
}

class BukoApp extends StatefulWidget {
  const BukoApp({super.key});
  @override
  State<BukoApp> createState() => _BukoAppState();
}

class _BukoAppState extends State<BukoApp> {
  BukoTheme theme = BukoTheme.midnight;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BUKO',
      theme: bukoTheme(theme),
      home: AuthScreen(onTheme: (value) => setState(() => theme = value)),
    );
  }
}

