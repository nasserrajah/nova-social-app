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
import '../bloc/messages_bloc.dart';
import '../bloc/messages_event.dart';
import '../bloc/messages_state.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MessagesBloc(repository: context.read<MessagesRepository>()),
      child: const _MessagesView(),
    );
  }
}

class _MessagesView extends StatefulWidget {
  const _MessagesView();

  @override
  State<_MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<_MessagesView> {
  final _notificationController = TopNotificationController();
  bool _requestedInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_requestedInitialLoad) return;
    _requestedInitialLoad = true;

    context.read<MessagesBloc>().add(
      MessagesLoadRequested(isArabic: context.isArabic),
    );
  }

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return BlocListener<MessagesBloc, MessagesState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        _notificationController.show(
          context,
          message: state.message!,
          isSuccess: state.isSuccess,
        );
        context.read<MessagesBloc>().add(const MessagesMessageCleared());
      },
      child: Directionality(
        textDirection: context.appTextDirection,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text(
              isArabic ? 'الرسائل' : 'Messages',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          body: BlocBuilder<MessagesBloc, MessagesState>(
            builder: (context, state) {
              if (state.isLoading && state.conversations.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.purple),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<MessagesBloc>().add(
                    MessagesRefreshRequested(isArabic: isArabic),
                  );
                },
                backgroundColor: Colors.black,
                color: AppColors.purple,
                child: _buildContent(state, isArabic),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(MessagesState state, bool isArabic) {
    if (state.conversations.isNotEmpty) {
      return ListView.builder(
        itemCount: state.conversations.length,
        itemBuilder: (context, index) {
          return _buildConversationItem(
            state.conversations[index],
            state.currentUserId,
            isArabic,
          );
        },
      );
    }

    if (state.friends.isNotEmpty) {
      return ListView.builder(
        itemCount: state.friends.length,
        itemBuilder: (context, index) {
          return _buildFriendItem(
            state.friends[index],
            state.currentUserId,
            isArabic,
          );
        },
      );
    }

    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Icon(Icons.chat_bubble_outline, color: Colors.grey[600], size: 64),
        const SizedBox(height: 16),
        Text(
          isArabic ? 'لا توجد محادثات' : 'No conversations',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isArabic
              ? 'ابدأ محادثة جديدة مع أصدقائك'
              : 'Start a new conversation with your friends',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildConversationItem(
    Conversation conversation,
    int? currentUserId,
    bool isArabic,
  ) {
    final lastMessage = conversation.lastMessage;
    final otherUser = conversation.otherUser;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: _avatar(otherUser, radius: 28),
        title: Row(
          children: [
            Expanded(
              child: Text(
                otherUser.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              DateFormatter.conversationTime(
                lastMessage?.time ?? DateTime.now(),
                isArabic: isArabic,
              ),
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            if (lastMessage != null) ...[
              if (lastMessage.isMe)
                Icon(
                  Icons.done_all,
                  color: lastMessage.isRead
                      ? AppColors.purple
                      : Colors.grey[500],
                  size: 16,
                ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  lastMessage.text,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else
              Text(
                isArabic ? 'ابدأ محادثة جديدة' : 'Start new chat',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            if (conversation.unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  conversation.unreadCount > 9
                      ? '9+'
                      : conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () => _openChat(otherUser, currentUserId),
      ),
    );
  }

  Widget _buildFriendItem(User friend, int? currentUserId, bool isArabic) {
    final subtitle = friend.bio?.isNotEmpty == true
        ? friend.bio!
        : (isArabic ? 'متاح للدردشة' : 'Available for chat');

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: _avatar(friend, radius: 28),
        title: Text(
          friend.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.chat_bubble_outline,
            color: AppColors.purple,
            size: 20,
          ),
        ),
        onTap: () => _openChat(friend, currentUserId),
      ),
    );
  }

  Widget _avatar(User user, {required double radius}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[800],
      backgroundImage: user.profileImage != null
          ? NetworkImage('${ApiConstants.storageUrl}/${user.profileImage}')
          : null,
      child: user.profileImage == null
          ? Text(
              user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  void _openChat(User friend, int? currentUserId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ChatScreen(friend: friend, currentUserId: currentUserId),
      ),
    );
  }
}
