import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/top_notification.dart';
import '../../../posts/presentation/screens/post_detail_screen.dart';
import '../../data/models/app_notification.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationController = TopNotificationController();
  bool _requestedInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_requestedInitialLoad) return;
    _requestedInitialLoad = true;

    final state = context.read<NotificationsBloc>().state;
    if (!state.isLoading && state.notifications.isEmpty) {
      context.read<NotificationsBloc>().add(
        NotificationsLoadRequested(isArabic: context.isArabic),
      );
    }
  }

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return BlocListener<NotificationsBloc, NotificationsState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        _notificationController.show(
          context,
          message: state.message!,
          isSuccess: state.isSuccess,
        );
        context.read<NotificationsBloc>().add(
          const NotificationsMessageCleared(),
        );
      },
      child: Directionality(
        textDirection: context.appTextDirection,
        child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.background,
                title: Text(
                  isArabic ? 'الإشعارات' : 'Notifications',
                  style: const TextStyle(
                    color: AppColors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '✅${state.readCount}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '🔴${state.unreadCount}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.unreadCount > 0)
                    IconButton(
                      icon: const Icon(Icons.done_all, color: AppColors.amber),
                      tooltip: isArabic
                          ? 'تحديد الكل كمقروء'
                          : 'Mark all as read',
                      onPressed: () {
                        context.read<NotificationsBloc>().add(
                          NotificationsMarkAllReadRequested(isArabic: isArabic),
                        );
                      },
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.amber),
                    onSelected: (value) {
                      if (value == 'clear') {
                        context.read<NotificationsBloc>().add(
                          NotificationsClearReadRequested(isArabic: isArabic),
                        );
                      } else if (value == 'refresh') {
                        context.read<NotificationsBloc>().add(
                          NotificationsLoadRequested(isArabic: isArabic),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'refresh',
                        child: Row(
                          children: [
                            const Icon(Icons.refresh, color: AppColors.amber),
                            const SizedBox(width: 8),
                            Text(isArabic ? 'تحديث' : 'Refresh'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'clear',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(isArabic ? 'مسح المقروء' : 'Clear Read'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              body: _buildBody(state, isArabic),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(NotificationsState state, bool isArabic) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.amber),
      );
    }

    if (state.notifications.isEmpty) {
      return Center(
        child: Text(
          isArabic ? 'لا توجد إشعارات' : 'No notifications',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      backgroundColor: Colors.black,
      color: AppColors.amber,
      onRefresh: () async {
        context.read<NotificationsBloc>().add(
          NotificationsLoadRequested(isArabic: isArabic),
        );
      },
      child: ListView.builder(
        itemCount: state.notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationItem(state.notifications[index], isArabic);
        },
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification, bool isArabic) {
    return GestureDetector(
      onTap: () => _handleNotificationTap(notification, isArabic),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.read ? Colors.grey[900] : const Color(0xFF2A1A4A),
          borderRadius: BorderRadius.circular(12),
          border: notification.read ? null : Border.all(color: Colors.purple),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: _avatarColor(notification.type),
                  radius: 20,
                  child: Text(
                    _initial(notification.fromUser?['name']),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                if (!notification.read)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _notificationMessage(notification, isArabic),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: notification.read
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _notificationIcon(notification.type),
                      const SizedBox(width: 6),
                      Text(
                        _actionText(notification.type, isArabic),
                        style: TextStyle(
                          color: _actionColor(notification.type),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormatter.relative(
                          notification.createdAt,
                          isArabic: isArabic,
                        ),
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      if (notification.read) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification, bool isArabic) {
    if (!notification.read) {
      context.read<NotificationsBloc>().add(
        NotificationMarkedAsRead(notification.id),
      );
    }

    switch (notification.type) {
      case 'friend_request':
        _showFriendRequestDialog(notification, isArabic);
        break;
      case 'like':
      case 'comment':
        if (notification.postId != null) {
          _openFullPost(notification.postId!);
        }
        break;
      default:
        if (notification.postId != null) {
          _openFullPost(notification.postId!);
        }
    }
  }

  void _showFriendRequestDialog(AppNotification notification, bool isArabic) {
    final name =
        notification.fromUser?['name']?.toString() ??
        (isArabic ? 'مستخدم' : 'User');

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          isArabic ? 'طلب صداقة' : 'Friend Request',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isArabic
              ? '$name يريد إضافتك كصديق'
              : '$name wants to add you as a friend',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<NotificationsBloc>().add(
                FriendRequestRejected(
                  notification.fromUserId,
                  isArabic: isArabic,
                ),
              );
            },
            child: Text(
              isArabic ? 'رفض' : 'Reject',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<NotificationsBloc>().add(
                FriendRequestAccepted(
                  notification.fromUserId,
                  isArabic: isArabic,
                ),
              );
            },
            child: Text(
              isArabic ? 'قبول' : 'Accept',
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFullPost(int postId) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PostDetailScreen(postId: postId)),
    );
  }

  String _notificationMessage(AppNotification notification, bool isArabic) {
    final name =
        notification.fromUser?['name']?.toString() ??
        (isArabic ? 'مستخدم' : 'User');

    switch (notification.type) {
      case 'like':
        return isArabic ? 'أعجب $name بمنشورك' : '$name liked your post';
      case 'comment':
        return isArabic
            ? 'علق $name على منشورك'
            : '$name commented on your post';
      case 'friend_request':
        return isArabic
            ? 'أرسل $name طلب صداقة لك'
            : '$name sent you a friend request';
      default:
        return notification.message;
    }
  }

  String _actionText(String type, bool isArabic) {
    switch (type) {
      case 'like':
        return isArabic ? 'إعجاب' : 'Like';
      case 'comment':
        return isArabic ? 'تعليق' : 'Comment';
      case 'friend_request':
        return isArabic ? 'طلب صداقة' : 'Friend Request';
      default:
        return isArabic ? 'تفاعل' : 'Interaction';
    }
  }

  Color _actionColor(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'friend_request':
        return Colors.green;
      default:
        return Colors.yellow;
    }
  }

  Color _avatarColor(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'friend_request':
        return Colors.green;
      default:
        return AppColors.purple;
    }
  }

  Widget _notificationIcon(String type) {
    switch (type) {
      case 'like':
        return const Icon(Icons.favorite, color: Colors.red, size: 16);
      case 'comment':
        return const Icon(Icons.comment, color: Colors.blue, size: 16);
      case 'friend_request':
        return const Icon(Icons.person_add, color: Colors.green, size: 16);
      default:
        return const Icon(Icons.notifications, color: Colors.yellow, size: 16);
    }
  }

  String _initial(dynamic value) {
    final name = value?.toString() ?? '?';
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }
}
