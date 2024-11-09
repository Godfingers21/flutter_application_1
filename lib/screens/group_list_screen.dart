import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
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
  List<Map<String, dynamic>> membersWithRoles = [];
  String? groupCode;


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
      setState(() {
        groupId = userData['group'];
      });
      await _fetchGroupData();
      await _fetchMembersWithRoles();
    } else {
      setState(() {
        groupId = null;
      });
    }
    isLoading = false;
  }

  Future<void> _fetchGroupData() async {
    if (groupId == null || groupId!.isEmpty) return;

    final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
    setState(() {
      groupData = groupDoc.data();
      groupCode = groupData?['code'];
    });
  }

  Future<void> _fetchMembersWithRoles() async {
    if (groupData == null || groupData!['members'] == null) return;

    final List<dynamic> memberIds = groupData!['members'] as List<dynamic>;
    List<Map<String, dynamic>> fetchedMembers = [];

    for (var memberId in memberIds) {
      final memberDoc = await FirebaseFirestore.instance.collection('users').doc(memberId).get();
      if (memberDoc.exists) {
        final memberData = memberDoc.data()!;
        fetchedMembers.add({
          'name': memberData['name'],
          'role': memberData['role'] ?? 'Normal',
        });
      } 
    }

    setState(() {
      membersWithRoles = fetchedMembers;
    });
  }
void _showJoinGroupByCodeDialog() {
  final TextEditingController codeController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Enter Group Code"),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(hintText: "Group Code"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String code = codeController.text.trim();
              await _joinGroupByCode(code);
              if(context.mounted) Navigator.pop(context);
            },
            child: const Text("Join"),
          ),
        ],
      );
    },
  );
}

Future<void> _joinGroupByCode(String code) async {
  final authService = Provider.of<AuthService>(context, listen: false);
  final userId = authService.currentUserId;

  // Fetch groups where the code matches
  final groupSnapshot = await FirebaseFirestore.instance
      .collection('groups')
      .where('code', isEqualTo: code)
      .get();

  if (groupSnapshot.docs.isNotEmpty) {
    final groupId = groupSnapshot.docs.first.id;

    // Update user's document with the new group
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'group': groupId,
    });

    // Add user ID to the group's members
    await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([userId]),
    });

    // Refresh user group data
    await _fetchUserGroup();
  } else {
    // Handle invalid code (e.g., show an error message)
    if(context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invalid group code.")),
    );
    }
  }
}

void _showCreateGroupDialog() {
  final TextEditingController groupNameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Create a Group"),
        content: TextField(
          controller: groupNameController,
          decoration: const InputDecoration(hintText: "Group Name"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String groupName = groupNameController.text.trim();
              await _createGroup(groupName);
              if(context.mounted) Navigator.pop(context);
            },
            child: const Text("Create"),
          ),
        ],
      );
    },
  );
}

Future<void> _createGroup(String groupName) async {
  final authService = Provider.of<AuthService>(context, listen: false);
  final userId = authService.currentUserId;

  // Generate a unique code (could use a random string or a combination)
  String uniqueCode = DateTime.now().millisecondsSinceEpoch.toString();

  // Create a new group document
  DocumentReference groupRef = await FirebaseFirestore.instance.collection('groups').add({
    'name': groupName,
    'members': [userId], // Add the creator as a member
    'admin': userId, // Set the creator as the admin
    'code': uniqueCode, // Save the unique code
  });
  // Optionally, update the user's document to reflect their group
  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'group': groupRef.id, // You could also store the group ID if needed
  });

  // Fetch the user group again to refresh data
  await _fetchUserGroup();
}

Future<void> _showCodeDialog() async {
  String? code = groupCode;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Voici le code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(code!),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Code copié dans le presse-papiers !")),
                );
              },
              child: const Text("Copier le code"),
            ),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false); 
    final isAdmin = authService.currentUserId == groupData?['admin'];
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Groupe")),
      body: Center(
        child: isLoading
          ? 
          const CircularProgressIndicator.adaptive()
          : 
          groupData != null
          ? 
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('${groupData!['name']}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Membres', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: membersWithRoles.length,
                    itemBuilder: (context, index) {
                      final member = membersWithRoles[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(member['name']),
                      );
                    },
                  ),
                ),
                if (isAdmin)
                  ElevatedButton(
                    onPressed: () => _showCodeDialog(),
                    child: const Text("Voir le code de groupe"),
                  ),
                
              ],
            )
          :
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          ElevatedButton(
            onPressed: _showJoinGroupByCodeDialog, 
            child: const Text("Rejoindre un Groupe")
            ),
          const SizedBox(height:20),
          ElevatedButton(
              onPressed: _showCreateGroupDialog,
              child: const Text("Créer un groupe"),
            ),
          ],
        ),
      ),
    );
  }
}
