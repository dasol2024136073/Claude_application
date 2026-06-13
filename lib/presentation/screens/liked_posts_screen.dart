import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/community_comment_repository.dart';
import '../../data/services/community_repository.dart';
import '../../domain/models/community_comment.dart';
import '../../domain/models/community_post.dart';
import '../widgets/post_list_items.dart';

class LikedPostsScreen extends StatefulWidget {
  final String myEmail;
  const LikedPostsScreen({super.key, required this.myEmail});

  @override
  State<LikedPostsScreen> createState() => _LikedPostsScreenState();
}

class _LikedPostsScreenState extends State<LikedPostsScreen> {
  bool _loading = true;
  List<CommunityPost> _posts = [];
  List<CommunityComment> _comments = [];
  Map<String, CommunityPost> _postsById = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final allPosts = await CommunityRepository.getAll();
    final allComments = await CommunityCommentRepository.getAll();

    final likedPosts = allPosts.where((p) => p.likedBy.contains(widget.myEmail)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final likedComments = allComments.where((c) => c.likedBy.contains(widget.myEmail)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (!mounted) return;
    setState(() {
      _posts = likedPosts;
      _comments = likedComments;
      _postsById = {for (final p in allPosts) p.id: p};
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('좋아요 누른 글', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF4F9D6E),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF4F9D6E),
            tabs: [Tab(text: '게시물'), Tab(text: '댓글')],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  PostListView(posts: _posts, emptyText: '좋아요 누른 게시물이 없습니다'),
                  CommentListView(
                    comments: _comments,
                    postsById: _postsById,
                    emptyText: '좋아요 누른 댓글이 없습니다',
                    linkLabelSuffix: '의 댓글',
                  ),
                ],
              ),
      ),
    );
  }
}
