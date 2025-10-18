import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder<User?>(
        // changed to authStateChanges() and added debug print so the UI reacts to sign-in/out
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          // debug: remove or comment out in production
          print(
              'ProfilePage: connection=${snapshot.connectionState}, user=${snapshot.data}, uid=${snapshot.data?.uid}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(
              child: Text(
                'No user logged in',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                user.photoURL != null
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user.photoURL!),
                      )
                    : const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepPurple,
                        child:
                            Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                const SizedBox(height: 20),
                Text(
                  user.displayName ?? user.email ?? 'No Email',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'UID: ${user.uid}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title: const Text('Account Settings',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: Colors.white),
                  title:
                      const Text('Help', style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text('Sign Out',
                      style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
