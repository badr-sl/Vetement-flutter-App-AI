import 'package:flutter/material.dart';
import 'package:vetements_app/screens/add_vetement_page.dart';
import 'package:vetements_app/screens/panier_page.dart';
import 'package:vetements_app/screens/profil_page.dart';
import 'screens/LoginScreen.dart';
import 'screens/TemporaryPage.dart'; 
import 'screens/VetementListScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Application de Vêtements',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/temporary': (context) => TemporaryPage(),
        '/listVetements': (context)=> VetementListScreen(),
        '/panier': (context) => PanierPage(),
        '/profil': (context) => ProfilPage(),
        '/addVetement': (context) => AddVetementPage(),
      },
    );
  }
}
