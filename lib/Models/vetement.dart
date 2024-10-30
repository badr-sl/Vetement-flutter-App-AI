class Vetement {
  final String? categorie;
  final String? image;
  final String? marque;
  final String? nom;
  final String? taille;
  final double? prix;

  Vetement({
    this.categorie,
    this.image,
    this.marque,
    this.nom,
    this.taille,
    this.prix,
  });

  // Méthode pour convertir un document Firestore en un objet Vetement
  factory Vetement.fromMap(Map<String, dynamic> data) {
    final categorie = data['categorie']?.toString().trim();
    final image = data['image']?.toString().trim();
    final marque = data['marque']?.toString().trim();
    final nom = data['nom']?.toString().trim();
    final taille = data['taille']?.toString().trim();
    final prix = data['prix'] != null ? double.tryParse(data['prix'].toString()) : null;

    return Vetement(
      categorie: categorie,
      image: image,
      marque: marque,
      nom: nom,
      taille: taille,
      prix: prix,
    );
  }
}

