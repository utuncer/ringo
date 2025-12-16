import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/app_colors.dart';
import '../data/chat_repository.dart';
import '../domain/message.dart';
import '../../auth/data/auth_repository.dart';

part 'chat_room_screen.g.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatRoomScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    ref
        .read(chatRepositoryProvider)
        .sendMessage(content: content, receiverId: widget.otherUserId);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesStream = ref.watch(chatMessagesProvider(widget.otherUserId));
    final myId = ref.watch(authRepositoryProvider).currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        backgroundColor: AppColors.surfaceDark,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesStream.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Henüz mesaj yok',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true, // Show newest at bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[messages.length - 1 - index]; // Reverse index
                    final isMe = message.senderId == myId;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isMe ? AppColors.primary : AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message.content,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Hata: $err')),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceDark,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Mesaj yaz...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _messageController,
                      builder: (context, value, child) {
                        final length = value.text.length;
                        final isOverflow = length > 200;
                        final isDisabled = isOverflow || length == 0;

                        return IconButton(
                          icon: Icon(
                            Icons.send,
                            color: isDisabled ? Colors.grey : AppColors.primary,
                          ),
                          onPressed: isDisabled ? null : _sendMessage,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _messageController,
                  builder: (context, value, child) {
                    final length = value.text.length;
                    final isOverflow = length > 200;
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$length/200',
                        style: TextStyle(
                          color: isOverflow
                              ? const Color(0xFFDA291C)
                              : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@riverpod
Stream<List<Message>> chatMessages(Ref ref, String otherUserId) {
  return ref.read(chatRepositoryProvider).getMessages(otherUserId);
}
