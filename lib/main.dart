// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("Starting Firebase initialization");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase initialized successfully");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeu IRL',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AccueilScreen(),
    );
  }
}

class AccueilScreen extends StatelessWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeu IRL - Accueil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenue dans le jeu IRL !',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),  
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GroupListScreen()),
                );
              },
              child: const Text('Voir les Groupes'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: const Text('Mon Profil'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groupes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Liste des Groupes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GroupDetailScreen()),
                );
              },
              child: const Text('Accéder à un Groupe'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logique de création d'un groupe
              },
              child: const Text('Créer un Nouveau Groupe'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Groupe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Statut du Jeu : Chasseur & Chassé',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chasseur actuel : [Nom]',
            ),
            const Text(
              'Chassé actuel : [Nom]',
            ),
            ElevatedButton(
              onPressed: () {
              },
              child: const Text('Toucher le Chassé'),
            ),
          ],
        ),
      ),
    );
  }
}


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Profil et Score',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Points : 160',
            ),
            const Text(
              'Chaîne de survie : 3 cycles',
            ),
            ElevatedButton(
              onPressed: () {
              },
              child: const Text('Historique des Parties'),
            ),
            ElevatedButton(
              onPressed: () async {
                try{
                  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
                  if (googleUser != null){
                    print("Signed in as ${googleUser.displayName}");
                  }
                }
                catch(e){
                  print("Sign In failed");
                }
              }, child: const Text('Sign in with Google'),
            )  
          ],
        ),
      ),
    );
  }
}

