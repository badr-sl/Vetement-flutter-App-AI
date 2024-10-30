class User {
  final String id;
  final String anniversaire;
  final String adresse;
  final String codePostal;
  final String ville;

  User({required this.id,  required this.anniversaire, required this.adresse, required this.codePostal, required this.ville});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'anniversaire': anniversaire,
      'adresse': adresse,
      'codePostal': codePostal,
      'ville': ville,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      anniversaire: map['anniversaire'],
      adresse: map['adresse'],
      codePostal: map['codePostal'],
      ville: map['ville'],
    );
  }
}
