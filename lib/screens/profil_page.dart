import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetements_app/screens/UserSession.dart';
import 'package:vetements_app/screens/VetementListScreen.dart';
import 'package:vetements_app/screens/panier_page.dart';
import 'package:vetements_app/widgets/CustomBottomNavigationBar.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController anniversaireController = TextEditingController();
  TextEditingController adresseController = TextEditingController();
  TextEditingController codePostalController = TextEditingController();
  TextEditingController villeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = true;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

   void _loadUserInfo() {
    final session = UserSession();

    setState(() {
      emailController.text = session.email ?? '';
      passwordController.text = session.password ?? '';
      anniversaireController.text = session.additionalInfo?['anniversaire'] ?? '';
      adresseController.text = session.additionalInfo?['address'] ?? '';
      codePostalController.text = session.additionalInfo?['codePostal']?.toString() ?? '';
      villeController.text = session.additionalInfo?['ville'] ?? '';
      isLoading = false;
    });
  }

  Future<void> _updateUserInfo() async {
    if (_formKey.currentState!.validate()) {
      String uid = _auth.currentUser!.uid;
      try {
        await _firestore.collection('Users').doc(uid).update({
          'email': emailController.text,
          'anniversaire': anniversaireController.text,
          'address': adresseController.text,
          'codePostal': int.tryParse(codePostalController.text) ?? 0,
          'ville': villeController.text,
        });

        if (passwordController.text.isNotEmpty) {
          try {
            String currentPassword = await _promptCurrentPassword();
            User? user = _auth.currentUser;
            AuthCredential credential = EmailAuthProvider.credential(
              email: user!.email!,
              password: currentPassword,
            );
            await user.reauthenticateWithCredential(credential);
            await user.updatePassword(passwordController.text);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mot de passe mis à jour")));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Erreur lors de la mise à jour du mot de passe : ${e}"),
              backgroundColor: Colors.red,
            ));
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profil mis à jour")));
      } catch (e) {
        log("Error updating user data: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Erreur lors de la mise à jour du profil"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<String> _promptCurrentPassword() async {
    String currentPassword = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer le mot de passe actuel'),
        content: TextField(
          autofocus: true,
          obscureText: true,
          decoration: InputDecoration(labelText: 'Mot de passe actuel'),
          onChanged: (value) => currentPassword = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Confirmer'),
          ),
        ],
      ),
    );
    return currentPassword;
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  void _onBottomNavigationTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      Widget destination;
      switch (index) {
        case 0:
          destination = VetementListScreen();
          break;
        case 1:
          destination = PanierPage();
          break;
        case 2:
          destination = ProfilPage();
          break;
        default:
          return;
      }
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon profil', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/addVetement');
            },
            tooltip: 'Ajouter un vêtement',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.check, size: 24),
              label: Text('Valider', style: TextStyle(fontSize: 18)),
              onPressed: _updateUserInfo,
              style: ElevatedButton.styleFrom(
                 foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 44, 255, 51),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(emailController, 'Login', readOnly: true),
                            SizedBox(height: 12),
                            _buildTextField(passwordController, 'Password', obscureText: true),
                            SizedBox(height: 12),
                            _buildTextField(anniversaireController, 'Anniversaire', keyboardType: TextInputType.datetime, onTap: _pickDate),
                            SizedBox(height: 12),
                            _buildTextField(adresseController, 'Adresse'),
                            SizedBox(height: 12),
                            _buildTextField(codePostalController, 'Code Postal', keyboardType: TextInputType.number),
                            SizedBox(height: 12),
                            _buildTextField(villeController, 'Ville'),
                            
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: Icon(Icons.logout),
                      label: Text('Se déconnecter', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                         foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 255, 144, 144),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavigationTapped,
      ),
    );
  }

  TextFormField _buildTextField(TextEditingController controller, String label,
      {bool readOnly = false, TextInputType? keyboardType, VoidCallback? onTap, bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 18, color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      readOnly: readOnly,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onTap: onTap,
      style: TextStyle(fontSize: 18),
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      anniversaireController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    }
  }
}
