import 'dart:math';

class User {
  final String id = Random().nextInt(1000000).toString();
  String name;
  final String email;
  final String password;

  User({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, password: $password}'; 
  }

  get userId => id; 
  get userName => name; 
  get userEmail => email;
  get userPassword => password;
}