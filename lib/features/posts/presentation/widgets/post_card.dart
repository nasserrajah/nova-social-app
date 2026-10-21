import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../data/models/post.dart';

/// Renders a single post with reactions, comments and share actions.
class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.isLiked,
    required this.reaction,
    required this.likesCount,
    required this.commentsCount,
    required this.onReactionSelected,
    required this.onComment,
    required this.onShare,
    this.token,
  });

  final Post post;
  final bool isLiked;
  final String? reaction;
  final int likesCount;
  final int commentsCount;
  final ValueChanged<String> onReactionSelected;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final String? token;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _showReactions = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isArabic = context.isArabic;

    return Card(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, post, isArabic),
            if (post.content != null && post.content!.isNotEmpty)
              _buildContent(post),
            if (post.image != null) _buildImage(post),
            const SizedBox(height: 10),
            if (widget.likesCount > 0 || widget.commentsCount > 0)
              _buildStats(),
            const SizedBox(height: 8),
            _buildActions(isArabic),
            if (_showReactions) _buildReactionsPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Post post, bool isArabic) {
    final userName = post.user?['name']?.toString() ?? 'User';
    final initial = userName.isEmpty ? '?' : userName[0].toUpperCase();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.purple,
              child: Text(initial, style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  DateFormat('hh:mm a').format(DateTime.now()),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        Text(
          DateFormat('yyyy/MM/dd').format(DateTime.now()),
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildContent(Post post) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          post.content!,
          style: const TextStyle(
            fontSize: 15,
            height: 1.4,
            color: Colors.white,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildImage(Post post) {
    final imageUrl = '${ApiConstants.storageUrl}/${post.image}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          headers: widget.token == null
              ? null
              : {
                  'Accept': 'application/json',
                  'Authorization': 'Bearer ${widget.token}',
                },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;

            return Container(
              color: Colors.grey[800],
              child: Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes == null
                      ? null
                      : progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!,
                  color: AppColors.yellow,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.error_outline, color: Colors.grey, size: 40),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          if (widget.likesCount > 0) ...[
            const Icon(Icons.favorite, color: Colors.red, size: 16),
            const SizedBox(width: 4),
            Text(
              '${widget.likesCount}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(width: 16),
          ],
          if (widget.commentsCount > 0) ...[
            const Icon(Icons.comment, color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            Text(
              '${widget.commentsCount}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () {
            setState(() => _showReactions = !_showReactions);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLiked || widget.reaction != null)
                Text(
                  widget.reaction ?? '❤️',
                  style: const TextStyle(fontSize: 20),
                )
              else
                const Icon(Icons.favorite_border, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                widget.isLiked
                    ? _reactionText(widget.reaction, isArabic)
                    : (isArabic ? 'إعجاب' : 'Like'),
                style: TextStyle(
                  color: widget.isLiked ? Colors.red : Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: widget.onComment,
          icon: const Icon(Icons.comment_outlined, color: Colors.grey),
          label: Text(
            isArabic ? 'تعليق' : 'Comment',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        TextButton.icon(
          onPressed: widget.onShare,
          icon: const Icon(Icons.share_outlined, color: Colors.grey),
          label: Text(
            isArabic ? 'مشاركة' : 'Share',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildReactionsPanel() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 6, left: 40),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: ['❤️', '👍', '😊', '😮', '😢']
              .map(
                (emoji) => GestureDetector(
                  onTap: () {
                    widget.onReactionSelected(emoji);
                    setState(() => _showReactions = false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _reactionText(String? reaction, bool isArabic) {
    switch (reaction) {
      case '😊':
        return isArabic ? 'سعيد' : 'Happy';
      case '😮':
        return isArabic ? 'منبهر' : 'Amazed';
      case '😢':
        return isArabic ? 'حزين' : 'Sad';
      case '❤️':
      case '👍':
      default:
        return isArabic ? 'إعجاب' : 'Like';
    }
  }
}
