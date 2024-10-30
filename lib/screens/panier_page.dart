import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetements_app/screens/VetementListScreen.dart';
import 'package:vetements_app/screens/profil_page.dart';
import '../widgets/CustomBottomNavigationBar.dart';

class PanierPage extends StatefulWidget {
  @override
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  int _currentIndex = 1;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> panierItems = [];
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPanierItems();
  }

  Future<void> _loadPanierItems() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot panierSnapshot = await _firestore.collection('Users').doc(uid).collection('Panier').get();

    List<Map<String, dynamic>> items = [];
    double calculatedTotal = 0.0;

    for (var doc in panierSnapshot.docs) {
      Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
      item['id'] = doc.id; // Store the document ID to reference for deletion
      items.add(item);
      calculatedTotal += item['prix'] ?? 0.0;
    }

    setState(() {
      panierItems = items;
      total = calculatedTotal;
    });
  }

  Future<void> _removeFromPanier(String itemId, double itemPrice) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await _firestore.collection('Users').doc(uid).collection('Panier').doc(itemId).delete();

    setState(() {
      panierItems.removeWhere((item) => item['id'] == itemId);
      total -= itemPrice;
    });
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
        title: Text("Panier"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: panierItems.length,
        itemBuilder: (context, index) {
          final item = panierItems[index];
          final itemPrice = item['prix'] ?? 0.0;

          // Decode the image if it exists
          Widget imageWidget;
          if (item['image'] != null) {
            try {
              final bytes = base64Decode(item['image']);
              imageWidget = Image.memory(bytes, fit: BoxFit.cover, height: 100, width: 100);
            } catch (e) {
              imageWidget = Icon(Icons.error, color: Colors.red, size: 100);
            }
          } else {
            imageWidget = Icon(Icons.image_not_supported, size: 100);
          }

          return Card(
            margin: EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imageWidget, 
                      SizedBox(width: 16), 
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nom'] ?? 'Sans nom',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text("Marque : ${item['marque'] ?? 'N/A'}"),
                            Text("categorie :${item['categorie'] ?? 'N/A'}"),
                            Text("Taille : ${item['taille'] ?? 'N/A'}"),
                            Text("Prix : ${itemPrice != null ? '${itemPrice} €' : 'N/A'}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () => _removeFromPanier(item['id'], itemPrice),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Total: $total €",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          CustomBottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onBottomNavigationTapped,
          ),
        ],
      ),
    );
  }
}
