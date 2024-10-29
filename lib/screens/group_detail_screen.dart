import 'package:flutter/material.dart';

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du Groupe')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Statut du Jeu : Chasseur & Chassé', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Chasseur actuel : [Nom]'),
            const Text('Chassé actuel : [Nom]'),
            ElevatedButton(onPressed: () {}, child: const Text('Toucher le Chassé')),
          ],
        ),
      ),
    );
  }
}
