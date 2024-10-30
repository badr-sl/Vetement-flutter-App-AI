import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tflite/tflite.dart';

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
  TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    String? result = await Tflite.loadModel(
      model: "assets/model_unquant.tflite", 
      labels: "assets/labels.txt",           
    );
    print(result);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _detectCategoryFromImage(_imageFile!);
    }
  }

  Future<void> _detectCategoryFromImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,  
      threshold: 0.5, 
    );

    if (output != null && output.isNotEmpty) {
      setState(() {
        _categoryController.text = output[0]["label"];  
      });
    } else {
      setState(() {
        _categoryController.text = "Inconnu";
      });
    }
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
          'nom': _titleController.text,
          'categorie': _categoryController.text,
          'taille': _sizeController.text,
          'marque': _brandController.text,
          'prix': double.tryParse(_priceController.text),
          'image': base64Image,
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
                controller: _categoryController,
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

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
