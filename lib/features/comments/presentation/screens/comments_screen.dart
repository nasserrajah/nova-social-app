import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/top_notification.dart';
import '../../data/models/comment.dart';
import '../../data/repositories/comments_repository.dart';
import '../bloc/comments_bloc.dart';
import '../bloc/comments_event.dart';
import '../bloc/comments_state.dart';

class CommentsScreen extends StatelessWidget {
  const CommentsScreen({
    super.key,
    required this.postId,
    required this.currentUserId,
  });

  final int postId;
  final int currentUserId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CommentsBloc(repository: context.read<CommentsRepository>())
            ..add(CommentsLoadRequested(postId, isArabic: context.isArabic)),
      child: _CommentsView(postId: postId, currentUserId: currentUserId),
    );
  }
}

class _CommentsView extends StatefulWidget {
  const _CommentsView({required this.postId, required this.currentUserId});

  final int postId;
  final int currentUserId;

  @override
  State<_CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends State<_CommentsView> {
  final _commentController = TextEditingController();
  final _notificationController = TopNotificationController();

  @override
  void dispose() {
    _notificationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    context.read<CommentsBloc>().add(
      CommentSubmitted(
        postId: widget.postId,
        content: content,
        isArabic: context.isArabic,
      ),
    );

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return BlocListener<CommentsBloc, CommentsState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        _notificationController.show(
          context,
          message: state.message!,
          isSuccess: state.isSuccess,
        );
        context.read<CommentsBloc>().add(const CommentsMessageCleared());
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(isArabic ? 'التعليقات' : 'Comments'),
          backgroundColor: Colors.black,
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<CommentsBloc, CommentsState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.yellow),
                    );
                  }

                  if (state.comments.isEmpty) {
                    return Center(
                      child: Text(
                        isArabic ? 'لا توجد تعليقات بعد' : 'No comments yet',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.comments.length,
                    itemBuilder: (context, index) {
                      return _buildCommentItem(state.comments[index], isArabic);
                    },
                  );
                },
              ),
            ),
            _buildCommentInput(isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, bool isArabic) {
    final isCurrentUserComment = comment.user?['id'] == widget.currentUserId;
    final name =
        comment.user?['name']?.toString() ?? (isArabic ? 'مستخدم' : 'User');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.purple,
            child: Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: isCurrentUserComment
                            ? AppColors.yellow
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCurrentUserComment)
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 18,
                        ),
                        onPressed: () {
                          _showDeleteDialog(comment.id, isArabic);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.fullDate(comment.createdAt, isArabic: isArabic),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.card,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: isArabic ? 'اكتب تعليقاً...' : 'Write a comment...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[900],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<CommentsBloc, CommentsState>(
            builder: (context, state) {
              return CircleAvatar(
                backgroundColor: AppColors.purple,
                child: IconButton(
                  icon: state.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  onPressed: state.isSubmitting ? null : _submit,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int commentId, bool isArabic) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          isArabic ? 'حذف التعليق' : 'Delete Comment',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من حذف هذا التعليق؟'
              : 'Are you sure you want to delete this comment?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              isArabic ? 'إلغاء' : 'Cancel',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CommentsBloc>().add(
                CommentDeleteRequested(commentId, isArabic: context.isArabic),
              );
            },
            child: Text(
              isArabic ? 'حذف' : 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
