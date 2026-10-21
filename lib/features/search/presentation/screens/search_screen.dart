import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/user.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/top_notification.dart';
import '../../../posts/data/models/post.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../data/repositories/search_repository.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/post_detail_modal.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SearchBloc(repository: context.read<SearchRepository>()),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _searchController = TextEditingController();
  final _notificationController = TopNotificationController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshSuffixIcon);
  }

  void _refreshSuffixIcon() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _notificationController.dispose();
    _searchController
      ..removeListener(_refreshSuffixIcon)
      ..dispose();
    super.dispose();
  }

  void _search() {
    final query = _searchController.text.trim();
    final state = context.read<SearchBloc>().state;

    context.read<SearchBloc>().add(
      SearchSubmitted(
        query: query,
        searchUsers: state.selectedTab == 1,
        isArabic: context.isArabic,
      ),
    );
  }

  void _changeTab(int index) {
    context.read<SearchBloc>().add(
      SearchTabChanged(
        index: index,
        query: _searchController.text.trim(),
        isArabic: context.isArabic,
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchBloc>().add(const SearchCleared());
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return BlocListener<SearchBloc, SearchState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        _notificationController.show(
          context,
          message: state.message!,
          isSuccess: state.isSuccess,
        );
        context.read<SearchBloc>().add(const SearchMessageCleared());
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            decoration: InputDecoration(
              hintText: isArabic
                  ? 'ابحث عن منشورات أو مستخدمين...'
                  : 'Search posts or users...',
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.card,
              prefixIcon: const Icon(Icons.search, color: AppColors.yellow),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: _clearSearch,
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
            ),
            onSubmitted: (_) => _search(),
          ),
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildTabs(state, isArabic),
                Expanded(child: _buildResults(state, isArabic)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabs(SearchState state, bool isArabic) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab(0, isArabic ? 'المنشورات' : 'Posts', state.selectedTab),
          _buildTab(1, isArabic ? 'المستخدمين' : 'Users', state.selectedTab),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, int selectedTab) {
    final selected = selectedTab == index;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: selected ? AppColors.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextButton(
          onPressed: () => _changeTab(index),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(SearchState state, bool isArabic) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.yellow),
      );
    }

    if (state.selectedTab == 0) {
      if (state.posts.isEmpty) {
        return _buildEmptyState(
          icon: Icons.search,
          title: isArabic ? 'لا توجد منشورات' : 'No posts found',
          subtitle: isArabic
              ? 'ابحث عن منشورات باستخدام الكلمات المفتاحية'
              : 'Search posts using keywords',
        );
      }

      return ListView.builder(
        itemCount: state.posts.length,
        itemBuilder: (context, index) {
          return _buildPostItem(state.posts[index], isArabic);
        },
      );
    }

    if (state.users.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people,
        title: isArabic ? 'لا يوجد مستخدمين' : 'No users found',
        subtitle: isArabic
            ? 'ابحث عن مستخدمين بالأسماء أو الإيميلات'
            : 'Search users by name or email',
      );
    }

    return ListView.builder(
      itemCount: state.users.length,
      itemBuilder: (context, index) {
        final user = state.users[index];
        return _buildUserItem(
          user,
          state.friendshipStatuses[user.id] ?? 'not_friends',
          isArabic,
        );
      },
    );
  }

  Widget _buildPostItem(Post post, bool isArabic) {
    final userName =
        post.user?['name']?.toString() ?? (isArabic ? 'مستخدم' : 'User');
    final image = post.image;

    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.purple,
          child: Text(
            userName.isEmpty ? '?' : userName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          userName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          post.content ?? '',
          style: const TextStyle(color: Colors.grey),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: image != null && image.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  '${ApiConstants.storageUrl}/$image',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[800],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              )
            : null,
        onTap: () => _openPostDetail(post),
      ),
    );
  }

  Widget _buildUserItem(User user, String friendshipStatus, bool isArabic) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.purple,
          backgroundImage: user.profileImage != null
              ? NetworkImage('${ApiConstants.storageUrl}/${user.profileImage}')
              : null,
          child: user.profileImage == null
              ? Text(
                  user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(user.email, style: const TextStyle(color: Colors.grey)),
        trailing: _buildFriendButton(user, friendshipStatus, isArabic),
        onTap: () => _openUserProfile(user),
      ),
    );
  }

  Widget _buildFriendButton(User user, String status, bool isArabic) {
    switch (status) {
      case 'request_sent':
        return OutlinedButton(
          onPressed: null,
          child: Text(
            isArabic ? 'تم الإرسال' : 'Sent',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      case 'friends':
        return OutlinedButton(
          onPressed: () => _openUserProfile(user),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.green),
          ),
          child: Text(
            isArabic ? 'أصدقاء' : 'Friends',
            style: const TextStyle(fontSize: 12, color: Colors.green),
          ),
        );
      default:
        return ElevatedButton(
          onPressed: () {
            context.read<SearchBloc>().add(
              SearchFriendRequestSent(userId: user.id, isArabic: isArabic),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.purple,
            foregroundColor: Colors.white,
          ),
          child: Text(
            isArabic ? 'طلب صداقة' : 'Add Friend',
            style: const TextStyle(fontSize: 12),
          ),
        );
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey, size: 64),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _openPostDetail(Post post) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) => PostDetailModal(post: post),
    );
  }

  void _openUserProfile(User user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ProfileScreen(userId: user.id)),
    );
  }
}
