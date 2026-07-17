import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../../data/models/chat_model.dart';

class MediationChatScreen extends ConsumerStatefulWidget {
  final String mediationId;
  const MediationChatScreen({super.key, required this.mediationId});

  @override
  ConsumerState<MediationChatScreen> createState() => _MediationChatScreenState();
}

class _MediationChatScreenState extends ConsumerState<MediationChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final authState = ref.read(authProvider);
    final user = authState is AuthSuccess ? authState.user : null;

    final newMessage = ChatModel(
      id: '',
      senderId: user?.id.toString() ?? '',
      senderName: user?.name ?? 'Unknown',
      text: _messageController.text.trim(),
      createdAt: DateTime.now(),
    );

    ref.read(chatServiceProvider).sendMessage(widget.mediationId, newMessage);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatAsyncValue = ref.watch(chatStreamProvider(widget.mediationId));
    final authState = ref.watch(authProvider);
    final currentUserId = authState is AuthSuccess ? authState.user.id.toString() : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Chat Mediasi', style: TextStyle(color: AppTheme.neutral900)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppTheme.neutral900),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatAsyncValue.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('Belum ada pesan. Mulai diskusi!'));
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;
                    return _buildChatBubble(message, isMe);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primary600 : AppTheme.neutral100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(message.senderName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.neutral500)),
            if (!isMe) const SizedBox(height: 4),
            Text(
              message.text,
              style: TextStyle(color: isMe ? Colors.white : AppTheme.neutral900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.neutral100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppTheme.primary600,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
