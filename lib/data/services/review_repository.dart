import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/review.dart';
import 'community_comment_repository.dart';
import 'community_repository.dart';
import 'trip_events.dart';

class ReviewRepository {
  static const _key = 'trip_reviews';

  static Future<List<Review>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    final reviews = list
        .map((e) => Review.fromJson(e as Map<String, dynamic>))
        .toList();
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }

  static Future<Review?> getByTripId(String tripId) async {
    final reviews = await getAll();
    for (final r in reviews) {
      if (r.tripId == tripId) return r;
    }
    return null;
  }

  static Future<List<Review>> getPublic() async {
    final reviews = await getAll();
    return reviews.where((r) => r.visibility == ReviewVisibility.public).toList();
  }

  static Future<void> save(Review review) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAll();
    final updated = [
      ...existing.where((r) => r.tripId != review.tripId),
      review,
    ];
    await prefs.setString(_key, jsonEncode(updated.map((r) => r.toJson()).toList()));
    TripEvents.notify();
  }

  static Future<void> delete(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    final remaining = (await getAll()).where((r) => r.tripId != tripId).toList();
    await prefs.setString(_key, jsonEncode(remaining.map((r) => r.toJson()).toList()));
    TripEvents.notify();
  }

  /// 후기와 함께 커뮤니티에 공유된 게시물/댓글까지 모두 삭제
  static Future<void> deleteWithCommunityPost(String tripId) async {
    await delete(tripId);

    final communityPostId = 'review_$tripId';
    for (final c in await CommunityCommentRepository.getByPostId(communityPostId)) {
      await CommunityCommentRepository.delete(c.id);
    }
    await CommunityRepository.delete(communityPostId);
  }
}
