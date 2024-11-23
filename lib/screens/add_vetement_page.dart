import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class AddVetementPage extends StatefulWidget {
  @override
  _AddVetementPageState createState() => _AddVetementPageState();
}

class _AddVetementPageState extends State<AddVetementPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Uint8List? _imageData;
  File? _imageFile;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _sizeController = TextEditingController();
  TextEditingController _brandController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  String _categorie = "";
  bool _isCategoryLoading = false; 

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageData = bytes;
          _imageFile = null;
        });
        _detectCategoryFromImageHuggingFace(bytes);
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageData = null;
        });
        _detectCategoryFromImageHuggingFace(await _imageFile!.readAsBytes());
      }
    }
  }

  Future<void> _detectCategoryFromImageHuggingFace(Uint8List imageData) async {
  final String apiToken = ""; // add your API token here from the hugging face website
  
  final url = Uri.parse("https://api-inference.huggingface.co/models/google/vit-base-patch16-224");

  bool isLoading = true;
  int retries = 0;
  const maxRetries = 5;

  while (isLoading && retries < maxRetries) {
    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $apiToken",
          "Content-Type": "application/octet-stream",
        },
        body: imageData,
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          _categorie = result[0]["label"] ?? "";
        });
        isLoading = false;
      } else if (response.statusCode == 503) {
        print("Model loading, retrying in a few seconds...");
        await Future.delayed(Duration(seconds: 0)); 
        retries++;
      } else {
        print("Failed to classify image: ${response.statusCode}");
        print("Response body: ${response.body}");
        setState(() {
          _categorie = "Erreur de classification";
        });
        isLoading = false;
      }
    } catch (e) {
      print("Error during API call: $e");
      setState(() {
        _categorie = "Erreur de classification";
      });
      isLoading = false;
    }
  }

  if (isLoading && retries >= maxRetries) {
    print("Model failed to load after multiple retries.");
    setState(() {
      _categorie = "Erreur de classification";
    });
  }
}




  Future<void> _saveVetement() async {
    if (_formKey.currentState!.validate()) {
      try {
        String base64Image = '';
        if (_imageData != null) {
          base64Image = base64Encode(_imageData!);
        } else if (_imageFile != null) {
          final bytes = await _imageFile!.readAsBytes();
          base64Image = base64Encode(bytes);
        }

        await _firestore.collection('Vetements').add({
          'nom': _titleController.text,
          'categorie': _categorie,
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
                  child: _imageData != null
                      ? Image.memory(_imageData!, fit: BoxFit.cover)
                      : _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : Icon(Icons.add_a_photo, color: Colors.white70, size: 50),
                ),
              ),
              SizedBox(height: 16),
              if (_isCategoryLoading)
                CircularProgressIndicator()
              else
                Text("Catégorie : $_categorie", style: TextStyle(fontSize: 16)),
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
