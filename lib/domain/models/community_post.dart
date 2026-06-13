enum PostCategory { routeShare, question, free }

extension PostCategoryX on PostCategory {
  String get label {
    switch (this) {
      case PostCategory.routeShare:
        return '경로공유';
      case PostCategory.question:
        return '질문';
      case PostCategory.free:
        return '자유게시판';
    }
  }
}

class CommunityPost {
  final String id;
  final PostCategory category;
  final bool isAnonymous;
  final String authorName;
  final String authorEmail;
  final String title;
  final String content;
  final List<String> photos; // base64 data URLs
  final String? tripDestination;
  final int? tripDays;
  final int? rating;
  final List<String> likedBy; // author emails who liked this post
  final int commentCount;
  final DateTime createdAt;

  CommunityPost({
    required this.id,
    required this.category,
    this.isAnonymous = false,
    required this.authorName,
    required this.authorEmail,
    required this.title,
    required this.content,
    this.photos = const [],
    this.tripDestination,
    this.tripDays,
    this.rating,
    this.likedBy = const [],
    this.commentCount = 0,
    required this.createdAt,
  });

  String get displayAuthor => isAnonymous ? '익명' : authorName;
  int get likeCount => likedBy.length;
  bool likedByEmail(String email) => likedBy.contains(email);

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'isAnonymous': isAnonymous,
        'authorName': authorName,
        'authorEmail': authorEmail,
        'title': title,
        'content': content,
        'photos': photos,
        if (tripDestination != null) 'tripDestination': tripDestination,
        if (tripDays != null) 'tripDays': tripDays,
        if (rating != null) 'rating': rating,
        'likedBy': likedBy,
        'commentCount': commentCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CommunityPost.fromJson(Map<String, dynamic> json) => CommunityPost(
        id: json['id'] as String,
        category: PostCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => PostCategory.free,
        ),
        isAnonymous: json['isAnonymous'] as bool? ?? false,
        authorName: json['authorName'] as String,
        authorEmail: json['authorEmail'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        photos: (json['photos'] as List<dynamic>? ?? []).cast<String>(),
        tripDestination: json['tripDestination'] as String?,
        tripDays: json['tripDays'] as int?,
        rating: json['rating'] as int?,
        likedBy: (json['likedBy'] as List<dynamic>? ?? []).cast<String>(),
        commentCount: json['commentCount'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  CommunityPost copyWith({
    PostCategory? category,
    bool? isAnonymous,
    String? title,
    String? content,
    List<String>? photos,
    String? tripDestination,
    int? tripDays,
    int? rating,
    List<String>? likedBy,
    int? commentCount,
  }) =>
      CommunityPost(
        id: id,
        category: category ?? this.category,
        isAnonymous: isAnonymous ?? this.isAnonymous,
        authorName: authorName,
        authorEmail: authorEmail,
        title: title ?? this.title,
        content: content ?? this.content,
        photos: photos ?? this.photos,
        tripDestination: tripDestination ?? this.tripDestination,
        tripDays: tripDays ?? this.tripDays,
        rating: rating ?? this.rating,
        likedBy: likedBy ?? this.likedBy,
        commentCount: commentCount ?? this.commentCount,
        createdAt: createdAt,
      );
}
