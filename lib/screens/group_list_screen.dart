import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  String? groupId;
  bool isLoading = true;
  Map<String, dynamic>? groupData;

  @override
  void initState() {
    super.initState();
    _fetchUserGroup();
  }

  Future<void> _fetchUserGroup() async {
  final authService = Provider.of<AuthService>(context, listen: false);
  final userId = authService.currentUserId;
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final userData = userDoc.data();
  
  if (userData != null && userData['group'] != null && userData['group'].isNotEmpty) {
    print("ON EST DEDANS");
    setState(() {
      groupId = userData['group'];
      
    });
    await _fetchGroupData();
  } else {
    setState(() {
      groupId = null; // Pas de groupe associé
    });
  }
  isLoading = false;
}

Future<void> _fetchGroupData() async {
  if (groupId == null || groupId!.isEmpty) return;

  final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
  setState(() {
    groupData = groupDoc.data();
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Groupe")),
      body: Center(
        child: isLoading
          ? const CircularProgressIndicator.adaptive()
          : groupData != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Nom du groupe : ${groupData!['name']}'),
                Text('Membres : ${groupData!['members'].length}'),
                // Afficher les autres détails du groupe ici
              ],
            )
          : ElevatedButton(
              onPressed: () {
                // Logique pour rejoindre un groupe
              },
              child: const Text("Rejoindre un Groupe"),
            ),
      ),
    );
  }
}
