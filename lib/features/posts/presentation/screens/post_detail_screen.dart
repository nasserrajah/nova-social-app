import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/top_notification.dart';
import '../../data/repositories/posts_repository.dart';
import '../bloc/post_detail_bloc.dart';
import '../bloc/post_detail_event.dart';
import '../bloc/post_detail_state.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key, required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PostDetailBloc(repository: context.read<PostsRepository>())
            ..add(PostDetailRequested(postId)),
      child: const _PostDetailView(),
    );
  }
}

class _PostDetailView extends StatefulWidget {
  const _PostDetailView();

  @override
  State<_PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<_PostDetailView> {
  final _notificationController = TopNotificationController();

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return BlocListener<PostDetailBloc, PostDetailState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        _notificationController.show(
          context,
          message: state.message!,
          isSuccess: state.isSuccess,
        );
        context.read<PostDetailBloc>().add(const PostDetailMessageCleared());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'تفاصيل المنشور' : 'Post Details'),
          backgroundColor: Colors.black,
          foregroundColor: AppColors.yellow,
        ),
        backgroundColor: Colors.black,
        body: BlocBuilder<PostDetailBloc, PostDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.yellow),
              );
            }

            final post = state.post;
            if (post == null) {
              return Center(
                child: Text(
                  isArabic ? 'لا يمكن جلب المنشور' : 'Cannot load post',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            return _buildBody(post, isArabic);
          },
        ),
      ),
    );
  }

  Widget _buildBody(Map<String, dynamic> post, bool isArabic) {
    final user = post['user'] is Map
        ? Map<String, dynamic>.from(post['user'] as Map)
        : <String, dynamic>{};
    final userName = user['name']?.toString() ?? (isArabic ? 'مستخدم' : 'User');
    final createdAt = DateTime.tryParse(post['created_at']?.toString() ?? '');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.purple,
                child: Text(
                  userName.isEmpty ? '?' : userName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.relative(
                        createdAt ?? DateTime.now(),
                        isArabic: isArabic,
                      ),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (post['content'] != null && post['content'].toString().isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                post['content'].toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),
          const SizedBox(height: 16),
          if (post['image'] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                '${ApiConstants.storageUrl}/${post['image']}',
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.purple.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.favorite,
                  '${post['likes_count'] ?? 0}',
                  isArabic ? 'إعجاب' : 'Likes',
                  Colors.red,
                ),
                _buildStatItem(
                  Icons.comment,
                  '${post['comments_count'] ?? 0}',
                  isArabic ? 'تعليق' : 'Comments',
                  Colors.blue,
                ),
                _buildStatItem(
                  Icons.visibility,
                  '${post['views_count'] ?? 0}',
                  isArabic ? 'مشاهدة' : 'Views',
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String count,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }
}
