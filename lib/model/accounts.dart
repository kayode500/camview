// import 'package:camview/model/user.dart';
// import 'package:flutter/material.dart';

// class Accounts {
//   List<User> accounts = [];

//   void addAccount(User user) {
//     accounts.add(user);
//   }

//   User getAccount(String email) {
//     for (var account in accounts) {
//       if (account.userEmail == email) {
//         return account;
//       }
//     }
//     throw Exception('Account with email $email not found');
//   }
// }

// final Accounts accountsDb = Accounts()
//   ..addAccount(
//       User(name: 'Alice', email: 'alice@example.com', password: 'alice123'))
//   ..addAccount(User(name: 'Bob', email: 'bob@example.com', password: 'bob456'))
//    ..addAccount(User(name: 'test', email: 'test@test.com', password: '1234'))
//   ..addAccount(User(
//       name: 'Charlie', email: 'charlie@example.com', password: 'charlie789'));
