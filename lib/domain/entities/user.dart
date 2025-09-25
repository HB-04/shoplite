class User {
  final int id;
  final String email;
  final String name;
  final String token;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });

  User copyWith({
    int? id,
    String? email,
    String? name,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      token: token ?? this.token,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{id: $id, email: $email, name: $name}';
  }
}
