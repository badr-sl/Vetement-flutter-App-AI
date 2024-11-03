Here’s a structured README for your project:

---

# Vetement AI Flutter App

This application allows users to upload images of clothing, which the app then classifies into categories using AI image recognition from Hugging Face. The detected category, along with other details, is stored in a Firestore database.

## Features
- **User Authentication**: Users can log in with pre-created accounts.
- **AI-Powered Image Classification**: Uses Hugging Face’s `google/vit-base-patch16-224` model for category classification.
- **Firestore Integration**: Saves clothing items and their categories in a database.
- **Real-Time UI Updates**: Displays the detected category in the form after image upload.

---

## Account Information
To log in to the application, use one of the following credentials:

- **Email**: `badr.eddine@gmail.com`  
  **Password**: `123456`

- **Email**: `a.badido620gmt@gmail.com`  
  **Password**: `123456`

---

## AI Image Classification
> **Note**: The AI model may take a moment to load before it displays the category in the form. However, the category will be visible in the details section once the item is saved and added to the database.

### API Integration Code Snippet
The following function integrates with Hugging Face’s API to classify clothing images. It retries up to 5 times in case the model is still loading and the image must be small taille and if it give errer of classification Retry to upload the image.

```dart
Future<void> _detectCategoryFromImageHuggingFace(Uint8List imageData) async {
  final String apiToken = "YOUR_HUGGING_FACE_API_TOKEN"; 
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
        await Future.delayed(Duration(seconds: 5)); 
        retries++;
      } else {
        print("Failed to classify image: ${response.statusCode}");
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
```

---

## Getting Started with Flutter

This project is built with Flutter. To start working with Flutter, here are some useful resources:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/): Offers tutorials, samples, and a comprehensive API reference.

---

This README provides an overview of the app’s features and setup. For additional information, refer to the Flutter documentation and Hugging Face's API documentation for integrating machine learning models.
