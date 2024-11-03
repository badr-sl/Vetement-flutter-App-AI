<<<<<<< HEAD
# Vetement-flutter-App-AI
=======
# vetements_app
pour les compte :

login : badr.eddine@gmail.com / password : 123456
login : a.badido620gmt@gmail.com /password : 123456

pour le code de  AI  :

pour la  spécification de la catégorie il prend un peut du temps pour affiche la catégorie dan le formuler 
mai la catégorie s'affiche dans les detail aprée l'ajout du vetement et ce stock dans la db 

<< HEAD
Future<void> _detectCategoryFromImageHuggingFace(Uint8List imageData) async {
  final String apiToken = "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"; 
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




A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
>>>>>>> 4d83c40 (Initial commit)
