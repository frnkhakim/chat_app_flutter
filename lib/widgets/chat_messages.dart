import 'package:chat_app/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (chatSnapshot.hasError) {
          return const Center(child: Text('An error occurred!'));
        }

        final chatDocs = chatSnapshot.data?.docs;
        if (chatDocs == null || chatDocs.isEmpty) {
          return const Center(child: Text('No messages found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            top: 10.0,
            left: 15.0,
            right: 15.0,
            bottom: 14.0,
          ),
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) {
            final chatMessage = chatDocs[index].data() as Map<String, dynamic>;
            final nextChatMessage = index + 1 < chatDocs.length
                ? chatDocs[index + 1].data() as Map<String, dynamic>
                : null;

            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId = nextChatMessage != null
                ? nextChatMessage['userId']
                : null;

            final isSameUserAsNext = currentMessageUserId == nextMessageUserId;

            // Return the appropriate bubble
            if (isSameUserAsNext) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                message: chatMessage['text'],
                username: chatMessage['username'],
                userImage: chatMessage['userImage'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
