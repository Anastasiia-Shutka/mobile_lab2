class User {
  String email;
  String name;
  String password;

  User({required this.email, required this.name, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'password': password,
  };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      name: json['name'] as String,
      password: json['password'] as String,
    );
  }
}
