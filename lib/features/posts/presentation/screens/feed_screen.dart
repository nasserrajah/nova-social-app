import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/curved_bottom_nav_bar.dart';
import '../../../../core/widgets/top_notification.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../comments/presentation/screens/comments_screen.dart';
import '../../../likes/presentation/screens/likes_screen.dart';
import '../../../messages/presentation/screens/messages_screen.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_event.dart';
import '../../../notifications/presentation/bloc/notifications_state.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../data/models/post.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';
import 'new_post_screen.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _notificationController = TopNotificationController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PostsBloc>().add(
        PostsLoadRequested(isArabic: context.isArabic),
      );
      context.read<NotificationsBloc>().add(const NotificationsLoadRequested());
    });
  }

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
        }
      },
      child: BlocListener<PostsBloc, PostsState>(
        listenWhen: (previous, current) =>
            current.actionMessage != null &&
            current.actionMessage != previous.actionMessage,
        listener: (context, state) {
          _notificationController.show(
            context,
            message: state.actionMessage!,
            isSuccess: state.actionSuccess,
          );
          context.read<PostsBloc>().add(const PostsMessageCleared());
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: _currentIndex == 0 ? _buildAppBar() : null,
          body: _buildCurrentScreen(),
          bottomNavigationBar:
              BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, state) {
                  return CurvedBottomNavBar(
                    currentIndex: _currentIndex,
                    notificationCount: state.unreadCount,
                    onTap: (index) {
                      setState(() => _currentIndex = index);
                      if (index == 2) {
                        context.read<NotificationsBloc>().add(
                          const NotificationsLoadRequested(),
                        );
                      }
                    },
                  );
                },
              ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      centerTitle: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAppTitle(context),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  color: AppColors.purple,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LikesScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.yellow),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (_) => const NewPostPage(),
                        ),
                      )
                      .then((_) {
                        if (mounted) {
                          context.read<PostsBloc>().add(
                            PostsRefreshRequested(isArabic: context.isArabic),
                          );
                        }
                      });
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.purple,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MessagesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppTitle(BuildContext context) {
    final isArabic = context.isArabic;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: isArabic ? 'نو' : 'No',
            style: const TextStyle(
              color: AppColors.yellow,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFamily: 'Arial',
            ),
          ),
          TextSpan(
            text: isArabic ? 'فا' : 'va',
            style: const TextStyle(
              color: AppColors.purple,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFamily: 'Arial',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildFeed();
      case 1:
        return const SearchScreen();
      case 2:
        return const NotificationsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFeed() {
    final isArabic = context.isArabic;

    return BlocBuilder<PostsBloc, PostsState>(
      builder: (context, state) {
        if (state.isLoading && state.posts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.yellow),
          );
        }

        if (state.posts.isEmpty) {
          return Center(
            child: Text(
              isArabic ? 'لا توجد منشورات بعد' : 'No posts yet',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          backgroundColor: Colors.black,
          color: AppColors.yellow,
          onRefresh: () async {
            context.read<PostsBloc>().add(
              PostsRefreshRequested(isArabic: context.isArabic),
            );
          },
          child: ListView.builder(
            itemCount: state.posts.length,
            itemBuilder: (context, index) {
              final post = state.posts[index];

              return PostCard(
                post: post,
                token: state.token,
                isLiked: state.likedStatus[post.id] ?? false,
                reaction: state.reactions[post.id],
                likesCount: state.likesCount[post.id] ?? post.likesCount,
                commentsCount: post.commentsCount,
                onReactionSelected: (emoji) {
                  context.read<PostsBloc>().add(
                    PostReactionSelected(
                      postId: post.id,
                      emoji: emoji,
                      isArabic: context.isArabic,
                    ),
                  );
                },
                onComment: () => _openComments(post, state.currentUserId),
                onShare: () => _sharePost(post),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openComments(Post post, int? currentUserId) async {
    if (currentUserId == null) {
      _notificationController.show(
        context,
        message: context.tr(
          'خطأ: لم يتم تحميل بيانات المستخدم',
          'Error: User data not loaded',
        ),
        isSuccess: false,
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            CommentsScreen(postId: post.id, currentUserId: currentUserId),
      ),
    );

    if (mounted) {
      context.read<PostsBloc>().add(
        PostsRefreshRequested(isArabic: context.isArabic),
      );
    }
  }

  Future<void> _sharePost(Post post) async {
    final isArabic = context.isArabic;
    final content =
        post.content ??
        (isArabic ? 'منشور جديد من تطبيق نوفا' : 'New post from Nova app');
    final imageUrl = post.image == null
        ? null
        : '${ApiConstants.storageUrl}/${post.image}';

    try {
      if (imageUrl != null) {
        final uri = Uri.parse(imageUrl);
        final response = await NetworkAssetBundle(uri).load(uri.toString());
        final bytes = response.buffer.asUint8List();

        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/shared_image.jpg');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([XFile(file.path)], text: content);
      } else {
        await Share.share(content);
      }

      if (!mounted) return;
      _notificationController.show(
        context,
        message: isArabic ? 'تمت المشاركة بنجاح' : 'Shared successfully',
        isSuccess: true,
      );
    } catch (_) {
      if (!mounted) return;
      _notificationController.show(
        context,
        message: isArabic ? 'فشل في مشاركة المنشور' : 'Failed to share post',
        isSuccess: false,
      );
    }
  }
}
