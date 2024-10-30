import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'group_list_screen.dart';
import 'profile_screen.dart';

class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState(){
    return _AccueilScreenState();
  }
}

  class _AccueilScreenState extends State<AccueilScreen>{

    final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUserName();
  }

  Future<void> _checkUserName() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final uid = authService.currentUser?.uid;

    if (uid != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      print(userSnapshot['name']);

      if (userSnapshot.exists && (userSnapshot['name'] == null || userSnapshot['name'].isEmpty)) {
        _showNameDialog();
      }
    }
  }

  void _showNameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Your Name'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Name'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String name = _nameController.text.trim();
                if (name.isNotEmpty) {
                  final authService = Provider.of<AuthService>(context, listen: false);
                  final uid = authService.currentUser?.uid;

                  await FirebaseFirestore.instance.collection('users').doc(uid).update({'name': name});
                  if (context.mounted) Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jeu IRL - Accueil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bienvenue dans le jeu IRL !', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                print("go to profile");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: const Text('Mon Profil'),
            ),
          ],
        ),
      ),
    );
  }
}
