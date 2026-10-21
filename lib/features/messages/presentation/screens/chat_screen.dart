import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/user.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/top_notification.dart';
import '../../data/models/chat_message.dart';
import '../../data/repositories/messages_repository.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.friend, this.currentUserId});

  final User friend;
  final int? currentUserId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        repository: context.read<MessagesRepository>(),
        currentUserId: currentUserId,
      ),
      child: _ChatView(friend: friend, currentUserId: currentUserId),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({required this.friend, this.currentUserId});

  final User friend;
  final int? currentUserId;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _notificationController = TopNotificationController();
  bool _requestedInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_requestedInitialLoad) return;
    _requestedInitialLoad = true;

    final bloc = context.read<ChatBloc>();
    bloc.add(
      ChatLoadRequested(friendId: widget.friend.id, isArabic: context.isArabic),
    );
  }

  @override
  void dispose() {
    _notificationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    context.read<ChatBloc>().add(
      ChatMessageSent(
        friendId: widget.friend.id,
        text: text,
        isArabic: context.isArabic,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        _notificationController.show(
          context,
          message: state.message!,
          isSuccess: state.isSuccess,
        );
        context.read<ChatBloc>().add(const ChatMessageCleared());
      },
      child: BlocListener<ChatBloc, ChatState>(
        listenWhen: (previous, current) =>
            current.messages.length != previous.messages.length,
        listener: (_, __) => _scrollToBottom(),
        child: Directionality(
          textDirection: context.appTextDirection,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(isArabic),
            body: Column(
              children: [
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.purple,
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(
                            state.messages[index],
                            isArabic,
                          );
                        },
                      );
                    },
                  ),
                ),
                _buildInput(isArabic),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isArabic) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[700],
            backgroundImage: widget.friend.profileImage != null
                ? NetworkImage(
                    '${ApiConstants.storageUrl}/${widget.friend.profileImage}',
                  )
                : null,
            child: widget.friend.profileImage == null
                ? Text(
                    widget.friend.name.isEmpty
                        ? '?'
                        : widget.friend.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friend.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isArabic ? 'متصل الآن' : 'Online now',
                  style: TextStyle(color: Colors.green[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isArabic) {
    final isArabicText = _containsArabic(message.text);
    final isSystemMessage =
        message.text.contains('Reacted') ||
        message.text.contains('تفاعل') ||
        message.text.contains('sent an attachment') ||
        message.text.contains('تم إرسال مرفق') ||
        message.text.contains('Ad');

    if (isSystemMessage) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.text,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[700],
              backgroundImage: widget.friend.profileImage != null
                  ? NetworkImage(
                      '${ApiConstants.storageUrl}/${widget.friend.profileImage}',
                    )
                  : null,
              child: widget.friend.profileImage == null
                  ? Text(
                      widget.friend.name.isEmpty
                          ? '?'
                          : widget.friend.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isMe ? AppColors.purple : AppColors.cardLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textDirection: isArabicText
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormatter.messageTime(
                          message.time,
                          isArabic: isArabic,
                        ),
                        style: TextStyle(
                          color: message.isMe
                              ? Colors.white70
                              : Colors.grey[400],
                          fontSize: 11,
                        ),
                      ),
                      if (message.isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          color: message.isRead ? Colors.white : Colors.white70,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.card,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.purple),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.photo_camera, color: AppColors.purple),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: isArabic
                            ? 'اكتب رسالة...'
                            : 'Type a message...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state.isSending) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.purple,
                    ),
                  ),
                );
              }

              return CircleAvatar(
                backgroundColor: AppColors.purple,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _send,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _containsArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }
}
