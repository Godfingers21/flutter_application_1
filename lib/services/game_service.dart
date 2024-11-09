import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> startNewCycle(String groupId) async {
    final groupRef = _firestore.collection('groups').doc(groupId);
    final groupSnapshot = await groupRef.get();

    if (groupSnapshot.exists) {
      final groupData = groupSnapshot.data()!;
      final members = List<String>.from(groupData['members']);
      final pausedMembers = List<String>.from(groupData['pausedMembers']);

      // Filtrer les membres non pausing
      final activeMembers = members.where((memberId) => !pausedMembers.contains(memberId)).toList();
      if (activeMembers.isEmpty) return; // Pas de membres actifs

      // Redistribuer les rôles
      final hunterIndex = DateTime.now().millisecondsSinceEpoch % activeMembers.length;
      final hunterId = activeMembers[hunterIndex];
      final preyIndex = (hunterIndex + 1) % activeMembers.length; // Le chassé est le suivant dans la liste
      final preyId = activeMembers[preyIndex];

      // Créer un nouvel enregistrement pour le cycle
      await groupRef.update({
        'currentGame': {
          'startTime': FieldValue.serverTimestamp(),
          'endTime': FieldValue.serverTimestamp(), // On mettra à jour plus tard
          'hunter': hunterId,
          'prey': preyId,
          'isActive': true,
          'validated': false,
        },
      });

      // Envoi de notifications
      await _sendNotifications(activeMembers, hunterId, preyId);
    }
  }

  Future<void> _sendNotifications(List<String> members, String hunterId, String preyId) async {
    // Ici, tu peux intégrer la logique pour envoyer des notifications via FCM
    for (var memberId in members) {
      // Récupérer le token FCM de chaque membre
      final userDoc = await _firestore.collection('users').doc(memberId).get();
      if (userDoc.exists) {
        final fcmToken = userDoc.data()?['fcmToken'];
        // Logique pour envoyer la notification
        if (fcmToken != null) {
          // Envoi de la notification avec le FCM token
          // Utilise ta méthode de notification ici
        }
      }
    }
  }

  Future<void> validateTouch(String groupId, String hunterId, String preyId) async {
    final groupRef = _firestore.collection('groups').doc(groupId);
    final groupSnapshot = await groupRef.get();

    if (groupSnapshot.exists) {
      final currentGame = groupSnapshot.data()?['currentGame'];
      if (currentGame != null && currentGame['hunter'] == hunterId && currentGame['prey'] == preyId) {
        // Mise à jour des points
        await _updatePoints(hunterId, preyId);
        // Valider le cycle
        await groupRef.update({
          'currentGame.validated': true,
          'currentGame.isActive': false,
          'currentGame.endTime': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> _updatePoints(String hunterId, String preyId) async {
    final hunterRef = _firestore.collection('users').doc(hunterId);
    final preyRef = _firestore.collection('users').doc(preyId);

    await _firestore.runTransaction((transaction) async {
      final hunterDoc = await transaction.get(hunterRef);
      final preyDoc = await transaction.get(preyRef);

      if (hunterDoc.exists && preyDoc.exists) {
        final currentPoints = hunterDoc.data()?['points'] ?? 0;
        final survivalPoints = preyDoc.data()?['points'] ?? 0;

        // Mise à jour des points
        transaction.update(hunterRef, {'points': currentPoints + 10}); // Ajouter 10 points au chasseur
        transaction.update(preyRef, {'points': survivalPoints + 5}); // Ajouter 5 points au chassé
      }
    });
  }

  Future<void> pauseMember(String groupId, String memberId) async {
    final groupRef = _firestore.collection('groups').doc(groupId);
    await groupRef.update({
      'pausedMembers': FieldValue.arrayUnion([memberId]),
    });

    // Mettre à jour l'utilisateur
    await _firestore.collection('users').doc(memberId).update({
      'isPaused': true,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resumeMember(String groupId, String memberId) async {
    final groupRef = _firestore.collection('groups').doc(groupId);
    await groupRef.update({
      'pausedMembers': FieldValue.arrayRemove([memberId]),
    });

    // Mettre à jour l'utilisateur
    await _firestore.collection('users').doc(memberId).update({
      'isPaused': false,
    });
  }
}
