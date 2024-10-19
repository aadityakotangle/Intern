import 'package:flutter/material.dart';
import 'package:saloonapp/InternHome.dart';
import 'package:saloonapp/add_product.dart';
import 'package:saloonapp/home_page.dart';
import 'package:saloonapp/internLogin.dart';
import 'package:saloonapp/login_page.dart';
import 'package:saloonapp/pages/booking.dart';
import 'package:saloonapp/pages/home.dart';
import 'package:saloonapp/pages/login.dart';
import 'package:saloonapp/pages/onbiarding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home_page.dart';  // Ensure this is pointing to the correct path of your HomePage file


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

