import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState(){
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen>{
  int points = 0;
  int survivalChain = 0;
  String name = "";
  @override
  void initState(){
    super.initState();
    _fetchUserData();
  }

  
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          points = userDoc['points'] ?? 0;
          survivalChain = userDoc['survivalChain'] ?? 0;
          name = userDoc['name'] ?? "";
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: 
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Score de $name',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Points : $points'),
            Text('Chaîne de survie : $survivalChain'),
            ElevatedButton(
              onPressed: () {
                // Gérer le bouton d'historique des parties ici
              },
              child: const Text('Historique des Parties'),
            ),
            ElevatedButton(
              onPressed: () async {
                await authService.signOut(); // Attendre que la déconnexion soit terminée
                print("test");
                // Vérifier si le widget est toujours monté avant d'utiliser BuildContext
                if (context.mounted) {
                  print("test");
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false, // Supprime toutes les routes précédentes
                  );
                }
              },
              child: const Text('Sign Out'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
