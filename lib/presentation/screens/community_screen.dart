import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/community_events.dart';
import '../../data/services/community_repository.dart';
import '../../domain/models/community_post.dart';
import '../theme/app_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<CommunityPost> _posts = [];
  bool _loading = true;
  String? _myEmail;

  PostCategory? _category;
  PostSort _sort = PostSort.latest;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    CommunityEvents.changed.addListener(_load);
  }

  @override
  void dispose() {
    CommunityEvents.changed.removeListener(_load);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = await AuthService.getCurrentUser();
    final posts = await CommunityRepository.getFiltered(
      category: _category,
      query: _searchController.text,
      sort: _sort,
    );
    if (!mounted) return;
    setState(() {
      _myEmail = user?['email'];
      _posts = posts;
      _loading = false;
    });
  }

  Future<void> _toggleLike(String id) async {
    await CommunityRepository.toggleLike(id);
  }

  void _openWriteSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('어떤 글을 작성할까요?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              ),
            ),
            const SizedBox(height: 8),
            _WriteOption(
              icon: Icons.flight_takeoff_rounded,
              label: '경로공유',
              description: '다녀온 경로와 사진을 공유해요',
              onTap: () => _selectWriteCategory(PostCategory.routeShare),
            ),
            _WriteOption(
              icon: Icons.help_outline_rounded,
              label: '질문',
              description: '여행 관련 질문을 올려보세요',
              onTap: () => _selectWriteCategory(PostCategory.question),
            ),
            _WriteOption(
              icon: Icons.chat_bubble_outline_rounded,
              label: '자유게시판',
              description: '자유롭게 이야기를 나눠요',
              onTap: () => _selectWriteCategory(PostCategory.free),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _selectWriteCategory(PostCategory category) async {
    Navigator.of(context).pop();
    final result = await context.push('/community/write', extra: {'category': category});
    if (result == true) _load();
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('커뮤니티', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        onPressed: _openWriteSheet,
        child: const Icon(Icons.edit_outlined),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '게시물 검색',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _load(),
              onChanged: (_) => _load(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CategoryChip(label: '전체', selected: _category == null, onTap: () => setState(() { _category = null; _load(); })),
                        const SizedBox(width: 8),
                        for (final c in PostCategory.values) ...[
                          _CategoryChip(label: c.label, selected: _category == c, onTap: () => setState(() { _category = c; _load(); })),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<PostSort>(
                  initialValue: _sort,
                  onSelected: (s) => setState(() { _sort = s; _load(); }),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: PostSort.latest, child: Text('최신순')),
                    PopupMenuItem(value: PostSort.popular, child: Text('인기순')),
                    PopupMenuItem(value: PostSort.mostCommented, child: Text('댓글많은순')),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        Text(_sortLabel(_sort), style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                        const Icon(Icons.expand_more, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _posts.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            children: const [_EmptyState()],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            itemCount: _posts.length,
                            itemBuilder: (context, i) => GestureDetector(
                              onTap: () => context.push('/community/post', extra: {'postId': _posts[i].id}),
                              child: _PostCard(
                                post: _posts[i],
                                myEmail: _myEmail,
                                formatDate: _formatDate,
                                onLike: () => _toggleLike(_posts[i].id),
                              ),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(PostSort sort) {
    switch (sort) {
      case PostSort.latest:
        return '최신순';
      case PostSort.popular:
        return '인기순';
      case PostSort.mostCommented:
        return '댓글많은순';
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primary : const Color(0xFFE8E8E8)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

class _WriteOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _WriteOption({required this.icon, required this.label, required this.description, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppTheme.primary, size: 22),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
      subtitle: Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      onTap: onTap,
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final String? myEmail;
  final String Function(DateTime) formatDate;
  final VoidCallback onLike;

  const _PostCard({required this.post, required this.myEmail, required this.formatDate, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final liked = myEmail != null && post.likedByEmail(myEmail!);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.photos.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(post.photos.first.split(',').last),
                width: 72, height: 72, fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(post.category.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(post.displayAuthor, style: TextStyle(fontSize: 12, color: Colors.grey[500]), overflow: TextOverflow.ellipsis),
                    ),
                    Text(formatDate(post.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 8),
                if (post.category == PostCategory.routeShare && post.tripDestination != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.flight_takeoff_rounded, size: 14, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text('${post.tripDestination} · ${post.tripDays}박 ${(post.tripDays ?? 0) + 1}일',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                      ],
                    ),
                  ),
                Text(post.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(post.content, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onLike,
                      child: Row(
                        children: [
                          Icon(liked ? Icons.favorite : Icons.favorite_border, size: 16, color: liked ? Colors.redAccent : Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text('${post.likeCount}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.chat_bubble_outline_rounded, size: 15, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text('${post.commentCount}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(Icons.groups_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('아직 게시물이 없습니다', style: TextStyle(fontSize: 14, color: Colors.grey[400], fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('첫 번째 게시물을 작성해보세요', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
