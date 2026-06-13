import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/community_post.dart';
import 'auth_service.dart';
import 'community_events.dart';

enum PostSort { latest, popular, mostCommented }

class CommunityRepository {
  static const _key = 'community_posts';

  static Future<List<CommunityPost>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CommunityPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<CommunityPost?> getById(String id) async {
    final posts = await getAll();
    for (final p in posts) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// 목록 조회: 카테고리/검색어 필터링 + 정렬
  static Future<List<CommunityPost>> getFiltered({
    PostCategory? category,
    String query = '',
    PostSort sort = PostSort.latest,
  }) async {
    var posts = await getAll();

    if (category != null) {
      posts = posts.where((p) => p.category == category).toList();
    }

    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      posts = posts
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              p.content.toLowerCase().contains(q))
          .toList();
    }

    switch (sort) {
      case PostSort.latest:
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case PostSort.popular:
        posts.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        break;
      case PostSort.mostCommented:
        posts.sort((a, b) => b.commentCount.compareTo(a.commentCount));
        break;
    }

    return posts;
  }

  /// 새 게시물 작성 또는 기존 게시물 수정 (id가 같으면 교체)
  static Future<void> save(CommunityPost post) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAll();
    final updated = [
      ...existing.where((p) => p.id != post.id),
      post,
    ];
    await prefs.setString(_key, jsonEncode(updated.map((p) => p.toJson()).toList()));
    CommunityEvents.notify();
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final remaining = (await getAll()).where((p) => p.id != id).toList();
    await prefs.setString(_key, jsonEncode(remaining.map((p) => p.toJson()).toList()));
    CommunityEvents.notify();
  }

  static Future<void> toggleLike(String id) async {
    final user = await AuthService.getCurrentUser();
    final email = user?['email'] ?? 'guest';

    final prefs = await SharedPreferences.getInstance();
    final posts = await getAll();
    final updated = posts.map((p) {
      if (p.id != id) return p;
      final liked = List<String>.from(p.likedBy);
      if (liked.contains(email)) {
        liked.remove(email);
      } else {
        liked.add(email);
      }
      return p.copyWith(likedBy: liked);
    }).toList();

    await prefs.setString(_key, jsonEncode(updated.map((p) => p.toJson()).toList()));
    CommunityEvents.notify();
  }

  static Future<void> setCommentCount(String id, int count) async {
    final prefs = await SharedPreferences.getInstance();
    final posts = await getAll();
    final updated = posts.map((p) => p.id == id ? p.copyWith(commentCount: count) : p).toList();
    await prefs.setString(_key, jsonEncode(updated.map((p) => p.toJson()).toList()));
    CommunityEvents.notify();
  }
}
