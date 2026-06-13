import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/community_comment.dart';
import '../../domain/models/community_post.dart';

String formatListDate(DateTime dt) =>
    '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';

class PostListView extends StatelessWidget {
  final List<CommunityPost> posts;
  final String emptyText;
  const PostListView({super.key, required this.posts, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(child: Text(emptyText, style: TextStyle(color: Colors.grey[500])));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostListCard(
          onTap: () => context.push('/community/post', extra: {'postId': post.id}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(post.category.label, style: const TextStyle(fontSize: 11, color: Color(0xFF4F9D6E), fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  Text(formatListDate(post.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                ],
              ),
              const SizedBox(height: 8),
              Text(post.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(post.content, style: TextStyle(fontSize: 13, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.favorite_outline, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('${post.likeCount}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const SizedBox(width: 12),
                  Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class CommentListView extends StatelessWidget {
  final List<CommunityComment> comments;
  final Map<String, CommunityPost> postsById;
  final String emptyText;
  final String linkLabelSuffix;
  const CommentListView({
    super.key,
    required this.comments,
    required this.postsById,
    required this.emptyText,
    this.linkLabelSuffix = '에 작성한 댓글',
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return Center(child: Text(emptyText, style: TextStyle(color: Colors.grey[500])));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: comments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final comment = comments[index];
        final post = postsById[comment.postId];
        return PostListCard(
          onTap: post == null ? null : () => context.push('/community/post', extra: {'postId': post.id}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post != null)
                Text(
                  '"${post.title}"$linkLabelSuffix',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              const SizedBox(height: 6),
              Text(comment.content, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Text(formatListDate(comment.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            ],
          ),
        );
      },
    );
  }
}

class PostListCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const PostListCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: child,
      ),
    );
  }
}
