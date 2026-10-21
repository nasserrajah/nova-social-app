import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/user.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/top_notification.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../messages/presentation/screens/chat_screen.dart';
import '../../data/repositories/profile_repository.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.userId, this.onFriendsCountChanged});

  final int? userId;
  final VoidCallback? onFriendsCountChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        repository: context.read<ProfileRepository>(),
        userId: userId,
      ),
      child: _ProfileView(onFriendsCountChanged: onFriendsCountChanged),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView({this.onFriendsCountChanged});

  final VoidCallback? onFriendsCountChanged;

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _picker = ImagePicker();
  final _notificationController = TopNotificationController();
  bool _requestedInitialLoad = false;

  bool get _isOwnProfile => context.read<ProfileBloc>().isOwnProfile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_requestedInitialLoad) return;
    _requestedInitialLoad = true;

    context.read<ProfileBloc>().add(
      ProfileLoadRequested(isArabic: context.isArabic),
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

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        _notificationController.show(
          context,
          message: state.message!,
          isSuccess: state.isSuccess,
        );

        if (state.isSuccess && state.friendshipStatus == 'friends') {
          widget.onFriendsCountChanged?.call();
        }

        context.read<ProfileBloc>().add(const ProfileMessageCleared());
      },
      child: Directionality(
        textDirection: context.appTextDirection,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              if (_isOwnProfile)
                IconButton(
                  tooltip: isArabic ? 'تسجيل الخروج' : 'Logout',
                  icon: const Icon(Icons.logout, color: AppColors.yellow),
                  onPressed: () => _confirmLogout(isArabic),
                ),
            ],
          ),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state.isLoading && state.user == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.yellow),
                );
              }

              if (state.user == null) {
                return Center(
                  child: Text(
                    isArabic
                        ? 'لا يمكن تحميل الملف الشخصي'
                        : 'Cannot load profile',
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfileBloc>().add(
                    ProfileRefreshRequested(isArabic: isArabic),
                  );
                },
                backgroundColor: Colors.black,
                color: AppColors.yellow,
                child: ListView(
                  children: [
                    _buildProfileHeader(state, isArabic),
                    const SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildFriendshipButtons(state, isArabic),
                    ),
                    _buildStats(state, isArabic),
                    if (state.posts.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          isArabic ? 'المنشورات' : 'Posts',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...state.posts.map(
                        (post) => _buildPostItem(post, isArabic),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileState state, bool isArabic) {
    final user = state.user!;
    final coverImage = user['cover_image']?.toString();
    final profileImage = user['profile_image']?.toString();
    final name = user['name']?.toString() ?? 'Nova';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            image: coverImage != null
                ? DecorationImage(
                    image: NetworkImage(
                      '${ApiConstants.storageUrl}/$coverImage',
                    ),
                    fit: BoxFit.cover,
                  )
                : null,
            gradient: coverImage == null
                ? LinearGradient(
                    colors: [Colors.purple.shade800, Colors.purple.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              if (coverImage != null)
                Container(
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
              if (_isOwnProfile)
                Positioned(
                  top: 16,
                  right: isArabic ? 16 : null,
                  left: isArabic ? null : 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      onPressed: () => _showCoverOptions(isArabic),
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          bottom: -50,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: AppColors.purple,
                      backgroundImage: profileImage != null
                          ? NetworkImage(
                              '${ApiConstants.storageUrl}/$profileImage',
                            )
                          : null,
                      child: profileImage == null
                          ? Text(
                              name.isEmpty ? '?' : name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  if (_isOwnProfile)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _showProfileImageOptions(isArabic),
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (user['bio']?.toString().isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Text(
                    user['bio'].toString(),
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFriendshipButtons(ProfileState state, bool isArabic) {
    if (_isOwnProfile) return const SizedBox.shrink();

    switch (state.friendshipStatus) {
      case 'not_friends':
        return Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProfileBloc>().add(
                  ProfileFriendRequestSent(isArabic: isArabic),
                );
              },
              icon: const Icon(Icons.person_add),
              label: Text(isArabic ? 'إرسال طلب صداقة' : 'Send Friend Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'أرسل طلب صداقة لبدء المحادثة'
                  : 'Send friend request to start chatting',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        );

      case 'request_sent':
        return Column(
          children: [
            OutlinedButton(
              onPressed: () {},
              child: Text(
                isArabic ? 'تم إرسال طلب الصداقة' : 'Friend Request Sent',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic ? 'بانتظار قبول الطلب' : 'Waiting for acceptance',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        );

      case 'request_received':
        return Column(
          children: [
            Text(
              isArabic
                  ? 'قام هذا المستخدم بإرسال طلب صداقة لك'
                  : 'This user sent you a friend request',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<ProfileBloc>().add(
                      ProfileFriendRequestAccepted(isArabic: isArabic),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isArabic ? 'قبول الطلب' : 'Accept'),
                ),
              ],
            ),
          ],
        );

      case 'friends':
        return Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => _openChat(state.user!),
              icon: const Icon(Icons.message),
              label: Text(isArabic ? 'مراسلة' : 'Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'يمكنك الآن مراسلة هذا الصديق'
                  : 'You can now message this friend',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStats(ProfileState state, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '${state.posts.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isArabic ? 'منشورات' : 'Posts',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                '${state.user?['friends_count'] ?? 0}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isArabic ? 'أصدقاء' : 'Friends',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post, bool isArabic) {
    final image = post['image']?.toString();
    final content = post['content']?.toString();

    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (content != null && content.isNotEmpty)
              Text(
                content,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            if (image != null && image.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${ApiConstants.storageUrl}/$image',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.grey[400], size: 16),
                const SizedBox(width: 4),
                Text(
                  '${post['likes_count'] ?? 0}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.comment, color: Colors.grey[400], size: 16),
                const SizedBox(width: 4),
                Text(
                  '${post['comments_count'] ?? 0}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const Spacer(),
                if (_isOwnProfile)
                  IconButton(
                    onPressed: () {
                      _confirmDeletePost(_asInt(post['id']), isArabic);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    tooltip: isArabic ? 'حذف المنشور' : 'Delete Post',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(String type, bool isArabic) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;

    context.read<ProfileBloc>().add(
      ProfileImageUploadRequested(
        type: type,
        file: File(picked.path),
        isArabic: isArabic,
      ),
    );
  }

  void _showCoverOptions(bool isArabic) {
    final user = context.read<ProfileBloc>().state.user;
    final hasCover = user?['cover_image'] != null;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic ? 'خيارات صورة الغلاف' : 'Cover Photo Options',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (hasCover)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  isArabic ? 'حذف صورة الغلاف' : 'Delete Cover Photo',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.read<ProfileBloc>().add(
                    ProfileImageDeleteRequested(
                      type: 'cover',
                      isArabic: isArabic,
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: Text(
                isArabic ? 'تغيير صورة الغلاف' : 'Change Cover Photo',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickAndUpload('cover', isArabic);
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileImageOptions(bool isArabic) {
    final user = context.read<ProfileBloc>().state.user;
    final hasImage = user?['profile_image'] != null;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic ? 'خيارات الصورة الشخصية' : 'Profile Photo Options',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (hasImage)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  isArabic ? 'حذف الصورة الشخصية' : 'Delete Profile Photo',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.read<ProfileBloc>().add(
                    ProfileImageDeleteRequested(
                      type: 'profile',
                      isArabic: isArabic,
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: Text(
                isArabic ? 'تغيير الصورة الشخصية' : 'Change Profile Photo',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickAndUpload('profile', isArabic);
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePost(int postId, bool isArabic) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          isArabic ? 'حذف المنشور' : 'Delete Post',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من حذف هذا المنشور؟'
              : 'Are you sure you want to delete this post?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              isArabic ? 'إلغاء' : 'Cancel',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ProfileBloc>().add(
                ProfilePostDeleteRequested(postId: postId, isArabic: isArabic),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isArabic ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }

  void _openChat(Map<String, dynamic> user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(friend: User.fromJson(user)),
      ),
    );
  }

  void _confirmLogout(bool isArabic) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          isArabic ? 'تسجيل الخروج' : 'Logout',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من تسجيل الخروج؟'
              : 'Are you sure you want to logout?',
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
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: Text(
              isArabic ? 'خروج' : 'Logout',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
