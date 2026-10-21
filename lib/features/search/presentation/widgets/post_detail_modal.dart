import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../posts/data/models/post.dart';

/// A compact read-only preview used by the search screen.
class PostDetailModal extends StatelessWidget {
  const PostDetailModal({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final userName =
        post.user?['name']?.toString() ?? (isArabic ? 'مستخدم' : 'User');
    final profileImage = post.user?['profile_image']?.toString();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF8A2BE2),
                      backgroundImage: profileImage != null
                          ? NetworkImage(
                              '${ApiConstants.storageUrl}/$profileImage',
                            )
                          : null,
                      child: profileImage == null
                          ? Text(
                              userName.isEmpty
                                  ? '?'
                                  : userName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (post.content != null && post.content!.isNotEmpty)
                  Text(
                    post.content!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  ),
                const SizedBox(height: 16),
                if (post.image != null && post.image!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      '${ApiConstants.storageUrl}/${post.image}',
                      width: double.infinity,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat(
                      icon: Icons.favorite,
                      color: Colors.red,
                      count: post.likesCount,
                      label: isArabic ? 'إعجاب' : 'Likes',
                    ),
                    _Stat(
                      icon: Icons.comment,
                      color: Colors.blue,
                      count: post.commentsCount,
                      label: isArabic ? 'تعليق' : 'Comments',
                    ),
                    _Stat(
                      icon: Icons.visibility,
                      color: Colors.green,
                      count: post.viewsCount,
                      label: isArabic ? 'مشاهدة' : 'Views',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.color,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }
}
