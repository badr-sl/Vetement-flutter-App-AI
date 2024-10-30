import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddVetementPage extends StatefulWidget {
  @override
  _AddVetementPageState createState() => _AddVetementPageState();
}

class _AddVetementPageState extends State<AddVetementPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _imageFile;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _sizeController = TextEditingController();
  TextEditingController _brandController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  String? _category;

 Future<void> _pickImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Change here
  if (pickedFile != null) {
    setState(() {
      _imageFile = File(pickedFile.path);
      _category = _detectCategoryFromImage(_imageFile!);
    });
  }
}


  String _detectCategoryFromImage(File image) {
    // Placeholder for actual image recognition logic
    return "Haut"; // Update as needed based on the image
  }

  Future<void> _saveVetement() async {
    if (_formKey.currentState!.validate()) {
      try {
        String base64Image = '';
        if (_imageFile != null) {
          final bytes = await _imageFile!.readAsBytes();
          base64Image = base64Encode(bytes);
        }

        await _firestore.collection('Vetements').add({
          'titre': _titleController.text,
          'categorie': _category,
          'taille': _sizeController.text,
          'marque': _brandController.text,
          'prix': double.tryParse(_priceController.text),
          'imageBase64': base64Image,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vêtement ajouté avec succès")));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur lors de l'ajout du vêtement")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter un vêtement"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: _imageFile == null
                      ? Icon(Icons.add_a_photo, color: Colors.white70, size: 50)
                      : Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre'),
                validator: (value) => value!.isEmpty ? "Veuillez saisir un titre" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _sizeController,
                decoration: InputDecoration(labelText: 'Taille'),
                validator: (value) => value!.isEmpty ? "Veuillez saisir une taille" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(labelText: 'Marque'),
                validator: (value) => value!.isEmpty ? "Veuillez saisir une marque" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Veuillez saisir un prix" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _category,
                decoration: InputDecoration(labelText: 'Catégorie'),
                readOnly: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveVetement,
                child: Text('Valider'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
