import 'package:flutter/material.dart';

class TemporaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Récupère les données de l'utilisateur transmises via les arguments
    final Map<String, dynamic> userInfo = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Page Temporaire'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenue, ${userInfo['email']}', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Détails du compte:', style: TextStyle(fontSize: 18)),
            Text('Email : ${userInfo['email']}'),
            Text('Adresse : ${userInfo['address']}'),
            Text('Ville : ${userInfo['ville']}'),
            Text('Code Postal : ${userInfo['codePostal']}'),
            Text('Anniversaire : ${userInfo['anniversaire'].toDate()}'), 
            Text('Créé le : ${userInfo['createdAt'].toDate()}'), 
          ],
        ),
      ),
    );
  }
}
