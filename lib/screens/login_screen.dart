import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';
import '../services/auth_service.dart';
import 'accueil_screen.dart'; // Import the AccueilScreen
import 'register_screen.dart'; // Importer le RegisterScreen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Variable d'état pour le chargement

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
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Connexion en cours..."),
                ],
              )
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
                      obscureText: true,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true; // Démarre le chargement
                        });
                        final user =
                            await authService.signInWithEmailAndPassword(
                          _emailController.text,
                          _passwordController.text,
                        );
                        setState(() {
                          _isLoading = false; // Arrête le chargement
                        });
                        if (user != null) {
                          //Try to save UserData if it don't exist already
                          await _saveUserData();

                          // Rediriger vers l'écran d'accueil
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const AccueilScreen()),
                              (Route<dynamic> route) => false,
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Login failed')),
                            );
                          }
                        }
                      },
                      child: const Text('Sign in'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Naviguer vers la page d'inscription
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text('Don\'t have an account? Register'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SignInButton(
                      Buttons.google,
                      text: "Sign in with Google",
                      onPressed: () async {
                        setState(() {
                          _isLoading = true; // Démarre le chargement
                        });
                        final user = await authService.signInWithGoogle();
                        if (user != null) {
                          await _saveUserData();
                          setState(() {
                            _isLoading = false; // Arrête le chargement
                          });
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const AccueilScreen()),
                              (Route<dynamic> route) => false,
                            );
                          }
                        } else {
                          setState(() {
                            _isLoading = false; // Arrête le chargement
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Login failed')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
