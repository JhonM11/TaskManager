/// Modelo que representa un usuario con solo un campo: username
class User {
  final String username;

  User({required this.username});

  /// Convierte el objeto User a un Map (para serialización simple)
  Map<String, dynamic> toMap() => {'username': username};

  /// Crea un objeto User a partir de un Map
  factory User.fromMap(Map<String, dynamic> map) => User(username: map['username']);
}
