import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetements_app/screens/panier_page.dart';
import 'package:vetements_app/screens/profil_page.dart';
import '../widgets/CustomBottomNavigationBar.dart';
import '../models/vetement.dart';

class VetementListScreen extends StatefulWidget {
  @override
  _VetementListScreenState createState() => _VetementListScreenState();
}

class _VetementListScreenState extends State<VetementListScreen> {
  int _currentIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Vetement>> _fetchVetements() async {
    QuerySnapshot querySnapshot = await _firestore.collection('Vetements').get();
    return querySnapshot.docs.map((doc) => Vetement.fromMap(doc.data() as Map<String, dynamic>)).toList();
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



  void _showVetementDetailsPopup(Vetement vetement) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.all(16),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (vetement.image != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.memory(
                      base64Decode(vetement.image!),
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: 16),
              Text(
                vetement.nom ?? 'Nom indisponible',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text("Categorie : ${vetement.categorie ?? 'N/A'}", style: TextStyle(color: Colors.grey[700])),
              Text("Taille : ${vetement.taille ?? 'N/A'}", style: TextStyle(color: Colors.grey[700])),
              Text("Marque : ${vetement.marque ?? 'N/A'}", style: TextStyle(color: Colors.grey[700])),
              Text("Prix : ${vetement.prix != null ? '${vetement.prix} €' : 'N/A'}", style: TextStyle(fontSize: 16, color: Colors.green)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 18),
                    label: Text(
                      "Retour",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      backgroundColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add_shopping_cart, color: Colors.white, size: 18),
                    label: Text(
                      "Ajouter au panier",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    onPressed: () async {
                      await _ajouterAuPanier(vetement);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Produit ajouté au panier !")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Future<void> _ajouterAuPanier(Vetement vetement) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await _firestore.collection('Users').doc(uid).collection('Panier').add({
      'nom': vetement.nom,
      'categorie': vetement.categorie,
      'marque': vetement.marque,
      'taille': vetement.taille,
      'prix': vetement.prix,
      'image': vetement.image,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des Vêtements"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Vetement>>(
        future: _fetchVetements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement des produits'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun produit disponible'));
          } else {
            final vetements = snapshot.data!;
            return ListView.builder(
              itemCount: vetements.length,
              itemBuilder: (context, index) {
                final vetement = vetements[index];

                Widget imageWidget;
                if (vetement.image != null) {
                  try {
                    final bytes = base64Decode(vetement.image!);
                    imageWidget = Image.memory(bytes, fit: BoxFit.cover, height: 100, width: 100);
                  } catch (e) {
                    imageWidget = Icon(Icons.error, color: Colors.red, size: 100);
                  }
                } else {
                  imageWidget = Icon(Icons.image_not_supported, size: 100);
                }

                return GestureDetector(
                  onTap: () => _showVetementDetailsPopup(vetement),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    child: Padding(
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
                                  vetement.nom ?? 'N/A',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                SizedBox(height: 8),
                                Text("Taille : ${vetement.taille ?? 'N/A'}", style: TextStyle(color: Colors.grey[700])),
                                Text("Prix : ${vetement.prix != null ? '${vetement.prix} €' : 'N/A'}", style: TextStyle(fontSize: 16, color: Colors.green)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavigationTapped,
      ),
    );
  }
}
