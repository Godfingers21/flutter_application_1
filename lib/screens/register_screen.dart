import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'accueil_screen.dart'; // Importer le LoginScreen

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override

  State<RegisterScreen> createState(){
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentReference userRef = _firestore.collection('users').doc(user.uid);
      print("On est dedans");
      // Check if user already exists
      DocumentSnapshot userSnapshot = await userRef.get();
      if (!userSnapshot.exists) {
        // Create a new user document
        await userRef.set({
          'name': '', // Set default or prompt user for their name later
          'points': 0,
          'survivalChain': 0,
          'group': '', // Set group later
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Affiche le loader pendant l'inscription
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true, // Pour masquer le mot de passe
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true; // Démarre le chargement
                        });
                        final user = await authService.registerWithEmailAndPassword(
                          _emailController.text,
                          _passwordController.text,
                        );
                        setState(() {
                          _isLoading = false; // Arrête le chargement
                        });
                        if (user != null) {
                          await _saveUserData();
                          // Rediriger vers l'écran d'accueil
                          if(context.mounted){
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const AccueilScreen()),
                            (Route<dynamic> route) => false,
                          );
                          }
                        } else {
                          if(context.mounted){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Registration failed')),
                          );
                          }
                        }
                      },
                      child: const Text('Register'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Naviguer vers la page de connexion
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text('Already have an account? Sign in'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
