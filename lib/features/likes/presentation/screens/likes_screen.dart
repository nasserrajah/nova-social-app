import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/top_notification.dart';
import '../../data/models/like.dart';
import '../../data/repositories/likes_repository.dart';
import '../bloc/likes_bloc.dart';
import '../bloc/likes_event.dart';
import '../bloc/likes_state.dart';

class LikesScreen extends StatelessWidget {
  const LikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LikesBloc(repository: context.read<LikesRepository>())
            ..add(LikesLoadRequested(isArabic: context.isArabic)),
      child: const _LikesView(),
    );
  }
}

class _LikesView extends StatefulWidget {
  const _LikesView();

  @override
  State<_LikesView> createState() => _LikesViewState();
}

class _LikesViewState extends State<_LikesView> {
  final _notificationController = TopNotificationController();

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return BlocListener<LikesBloc, LikesState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        _notificationController.show(
          context,
          message: state.isSuccess
              ? context.tr(
                  'تم حذف المنشور من المفضلة',
                  'Post removed from favorites',
                )
              : state.message!,
          isSuccess: state.isSuccess,
        );
        context.read<LikesBloc>().add(const LikesMessageCleared());
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                AppColors.purple.withValues(alpha: 0.15),
                AppColors.yellow.withValues(alpha: 0.05),
                Colors.black,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.1, 0.3, 0.8],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(isArabic),
              Expanded(
                child: BlocBuilder<LikesBloc, LikesState>(
                  builder: (context, state) {
                    if (state.isLoading && state.likes.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.yellow,
                        ),
                      );
                    }

                    if (state.likes.isEmpty) {
                      return _buildEmptyState(isArabic);
                    }

                    return RefreshIndicator(
                      backgroundColor: Colors.black,
                      color: AppColors.yellow,
                      onRefresh: () async {
                        context.read<LikesBloc>().add(
                          LikesLoadRequested(isArabic: context.isArabic),
                        );
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        itemCount: state.likes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildLikeCard(state.likes[index], isArabic);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isArabic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.purple, AppColors.yellow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              Text(
                isArabic ? 'المفضلة' : 'Favorites',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'صفحة تعرض جميع المنشورات التي أعجبتك'
                : 'This page shows all posts you liked',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            color: AppColors.purple.withValues(alpha: 0.5),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'لا توجد منشورات في المفضلة' : 'No favorite posts yet',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'سيظهر هنا المنشورات التي تعجبك'
                : 'Posts you like will appear here',
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeCard(Like like, bool isArabic) {
    final post = like.post;
    final image = post?['image']?.toString();
    final content = post?['content']?.toString();

    return Card(
      color: AppColors.cardDark.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.purple.withValues(alpha: 0.3)),
      ),
      elevation: 8,
      shadowColor: AppColors.purple.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null && image.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    '${ApiConstants.storageUrl}/$image',
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 220,
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
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (content != null && content.isNotEmpty)
                  Text(
                    content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.purple.withValues(alpha: 0.3),
                            AppColors.yellow.withValues(alpha: 0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        like.reaction == 'like' ? '👍' : like.reaction,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    Text(
                      DateFormatter.fullDate(
                        like.createdAt,
                        isArabic: isArabic,
                      ),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.redAccent.withValues(alpha: 0.8),
                      ),
                      onPressed: () => _confirmRemoval(like.id, isArabic),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemoval(int likeId, bool isArabic) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.divider,
        title: Text(
          isArabic ? 'تأكيد الحذف' : 'Confirm Removal',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من حذف هذا المنشور من المفضلة؟'
              : 'Are you sure you want to remove this post from favorites?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              isArabic ? 'إلغاء' : 'Cancel',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              isArabic ? 'حذف' : 'Remove',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<LikesBloc>().add(
        LikeRemovalRequested(likeId, isArabic: context.isArabic),
      );
    }
  }
}
