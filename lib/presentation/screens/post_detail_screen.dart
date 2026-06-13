import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/community_comment_repository.dart';
import '../../data/services/community_events.dart';
import '../../data/services/community_repository.dart';
import '../../domain/models/community_comment.dart';
import '../../domain/models/community_post.dart';
import '../theme/app_theme.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  CommunityPost? _post;
  List<CommunityComment> _comments = [];
  String? _myEmail;
  bool _loading = true;
  CommunityComment? _replyTo;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    CommunityEvents.changed.addListener(_load);
  }

  @override
  void dispose() {
    CommunityEvents.changed.removeListener(_load);
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = await AuthService.getCurrentUser();
    final post = await CommunityRepository.getById(widget.postId);
    final comments = await CommunityCommentRepository.getByPostId(widget.postId);
    if (!mounted) return;

    if (post == null) {
      context.pop();
      return;
    }

    setState(() {
      _myEmail = user?['email'];
      _post = post;
      _comments = comments;
      _loading = false;
    });
  }

  bool get _isMine => _myEmail != null && _post!.authorEmail == _myEmail;

  Future<void> _toggleLike() async {
    await CommunityRepository.toggleLike(_post!.id);
  }

  Future<void> _toggleCommentLike(String id) async {
    await CommunityCommentRepository.toggleLike(id);
  }

  Future<void> _editPost() async {
    final result = await context.push('/community/write', extra: {'category': _post!.category, 'post': _post});
    if (result == true) _load();
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시물 삭제'),
        content: const Text('이 게시물을 삭제하시겠습니까?\n댓글도 모두 함께 삭제됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    for (final c in _comments) {
      await CommunityCommentRepository.delete(c.id);
    }
    await CommunityRepository.delete(_post!.id);
    if (!mounted) return;
    context.pop();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = await AuthService.getCurrentUser();
    final comment = CommunityComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: _post!.id,
      parentCommentId: _replyTo?.id,
      authorName: user?['name'] ?? '여행자',
      authorEmail: user?['email'] ?? 'guest',
      content: text,
      createdAt: DateTime.now(),
    );
    await CommunityCommentRepository.save(comment);
    _commentController.clear();
    setState(() => _replyTo = null);
  }

  Future<void> _editComment(CommunityComment comment) async {
    final controller = TextEditingController(text: comment.content);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 수정'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    await CommunityCommentRepository.save(comment.copyWith(content: result));
  }

  Future<void> _deleteComment(CommunityComment comment) async {
    final hasReplies = _comments.any((c) => c.parentCommentId == comment.id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: Text(hasReplies ? '이 댓글을 삭제하면 답글도 함께 삭제됩니다.\n삭제하시겠습니까?' : '이 댓글을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    await CommunityCommentRepository.delete(comment.id);
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _post == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final post = _post!;
    final liked = _myEmail != null && post.likedByEmail(_myEmail!);
    final topLevel = _comments.where((c) => c.parentCommentId == null).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(post.category.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_isMine)
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') _editPost();
                if (v == 'delete') _deletePost();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('수정')),
                PopupMenuItem(value: 'delete', child: Text('삭제')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        post.displayAuthor.isNotEmpty ? post.displayAuthor[0] : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.displayAuthor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                          Text(_formatDate(post.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (post.category == PostCategory.routeShare && post.tripDestination != null) ...[
                  Row(
                    children: [
                      Icon(Icons.flight_takeoff_rounded, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text('${post.tripDestination} · ${post.tripDays}박 ${(post.tripDays ?? 0) + 1}일',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    ],
                  ),
                  if (post.rating != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (i) => Icon(
                            i < post.rating! ? Icons.star_rounded : Icons.star_border_rounded,
                            color: const Color(0xFFFFC107), size: 18,
                          )),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],

                Text(post.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 10),
                Text(post.content, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6)),

                if (post.photos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: PageView(
                      children: post.photos.map((p) => ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.memory(
                              base64Decode(p.split(',').last),
                              fit: BoxFit.cover, width: double.infinity,
                            ),
                          )).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      Icon(liked ? Icons.favorite : Icons.favorite_border, size: 22, color: liked ? Colors.redAccent : Colors.grey[400]),
                      const SizedBox(width: 6),
                      Text('좋아요 ${post.likeCount}', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),
                Text('댓글 ${_comments.length}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 12),

                if (topLevel.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('아직 댓글이 없습니다', style: TextStyle(fontSize: 13, color: Colors.grey[400]))),
                  )
                else
                  ...topLevel.expand((c) => [
                        _CommentTile(
                          comment: c,
                          myEmail: _myEmail,
                          formatDate: _formatDate,
                          onLike: () => _toggleCommentLike(c.id),
                          onReply: () => setState(() => _replyTo = c),
                          onEdit: () => _editComment(c),
                          onDelete: () => _deleteComment(c),
                        ),
                        ..._comments.where((r) => r.parentCommentId == c.id).map((r) => _CommentTile(
                              comment: r,
                              myEmail: _myEmail,
                              isReply: true,
                              formatDate: _formatDate,
                              onLike: () => _toggleCommentLike(r.id),
                              onEdit: () => _editComment(r),
                              onDelete: () => _deleteComment(r),
                            )),
                      ]),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))],
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_replyTo != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text('${_replyTo!.displayAuthor}님에게 답글 작성 중', style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => setState(() => _replyTo = null),
                            child: Icon(Icons.close, size: 14, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: _replyTo != null ? '답글을 입력해주세요' : '댓글을 입력해주세요',
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          onSubmitted: (_) => _submitComment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primary,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 18),
                          onPressed: _submitComment,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommunityComment comment;
  final String? myEmail;
  final bool isReply;
  final String Function(DateTime) formatDate;
  final VoidCallback onLike;
  final VoidCallback? onReply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.myEmail,
    this.isReply = false,
    required this.formatDate,
    required this.onLike,
    this.onReply,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final liked = myEmail != null && comment.likedByEmail(myEmail!);
    final isMine = myEmail != null && comment.authorEmail == myEmail;

    return Padding(
      padding: EdgeInsets.only(left: isReply ? 36 : 0, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.8),
            child: Text(
              comment.displayAuthor.isNotEmpty ? comment.displayAuthor[0] : '?',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.displayAuthor, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(width: 6),
                    Text(formatDate(comment.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onLike,
                      child: Row(
                        children: [
                          Icon(liked ? Icons.favorite : Icons.favorite_border, size: 14, color: liked ? Colors.redAccent : Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text('${comment.likeCount}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                    if (onReply != null) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: onReply,
                        child: Text('답글', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                      ),
                    ],
                    if (isMine) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: onEdit,
                        child: Text('수정', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: onDelete,
                        child: Text('삭제', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
