import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/community_comment.dart';
import 'auth_service.dart';
import 'community_events.dart';
import 'community_repository.dart';

class CommunityCommentRepository {
  static const _key = 'community_comments';

  static Future<List<CommunityComment>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CommunityComment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<CommunityComment>> getByPostId(String postId) async {
    final comments = (await getAll()).where((c) => c.postId == postId).toList();
    comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return comments;
  }

  static Future<void> save(CommunityComment comment) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAll();
    final updated = [
      ...existing.where((c) => c.id != comment.id),
      comment,
    ];
    await prefs.setString(_key, jsonEncode(updated.map((c) => c.toJson()).toList()));
    await _syncCommentCount(comment.postId);
    CommunityEvents.notify();
  }

  static Future<void> delete(String id) async {
    final all = await getAll();
    CommunityComment? target;
    for (final c in all) {
      if (c.id == id) {
        target = c;
        break;
      }
    }
    if (target == null) return;

    final prefs = await SharedPreferences.getInstance();
    // 대댓글이 달린 댓글을 삭제하면 그 대댓글들도 함께 삭제
    final remaining = all.where((c) => c.id != id && c.parentCommentId != id).toList();
    await prefs.setString(_key, jsonEncode(remaining.map((c) => c.toJson()).toList()));
    await _syncCommentCount(target.postId);
    CommunityEvents.notify();
  }

  static Future<void> toggleLike(String id) async {
    final user = await AuthService.getCurrentUser();
    final email = user?['email'] ?? 'guest';

    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    final updated = all.map((c) {
      if (c.id != id) return c;
      final liked = List<String>.from(c.likedBy);
      if (liked.contains(email)) {
        liked.remove(email);
      } else {
        liked.add(email);
      }
      return c.copyWith(likedBy: liked);
    }).toList();

    await prefs.setString(_key, jsonEncode(updated.map((c) => c.toJson()).toList()));
    CommunityEvents.notify();
  }

  static Future<void> _syncCommentCount(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final list = raw == null ? <dynamic>[] : jsonDecode(raw) as List<dynamic>;
    final count = list
        .map((e) => CommunityComment.fromJson(e as Map<String, dynamic>))
        .where((c) => c.postId == postId)
        .length;
    await CommunityRepository.setCommentCount(postId, count);
  }
}
