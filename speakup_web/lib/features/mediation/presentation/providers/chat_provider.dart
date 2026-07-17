import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chat_model.dart';

// Service to handle Firestore operations
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ChatModel>> getMessages(String mediationId) {
    return _firestore
        .collection('mediations')
        .doc(mediationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> sendMessage(String mediationId, ChatModel message) async {
    await _firestore
        .collection('mediations')
        .doc(mediationId)
        .collection('messages')
        .add(message.toMap());
  }
}

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

// StreamProvider to listen to real-time chat updates
final chatStreamProvider = StreamProvider.family<List<ChatModel>, String>((ref, mediationId) {
  final chatService = ref.read(chatServiceProvider);
  return chatService.getMessages(mediationId);
});
