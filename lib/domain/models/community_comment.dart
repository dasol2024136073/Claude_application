class CommunityComment {
  final String id;
  final String postId;
  final String? parentCommentId; // null이면 댓글, 값 있으면 대댓글
  final bool isAnonymous;
  final String authorName;
  final String authorEmail;
  final String content;
  final List<String> likedBy;
  final DateTime createdAt;

  CommunityComment({
    required this.id,
    required this.postId,
    this.parentCommentId,
    this.isAnonymous = false,
    required this.authorName,
    required this.authorEmail,
    required this.content,
    this.likedBy = const [],
    required this.createdAt,
  });

  String get displayAuthor => isAnonymous ? '익명' : authorName;
  int get likeCount => likedBy.length;
  bool likedByEmail(String email) => likedBy.contains(email);
  bool get isReply => parentCommentId != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
        'isAnonymous': isAnonymous,
        'authorName': authorName,
        'authorEmail': authorEmail,
        'content': content,
        'likedBy': likedBy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CommunityComment.fromJson(Map<String, dynamic> json) => CommunityComment(
        id: json['id'] as String,
        postId: json['postId'] as String,
        parentCommentId: json['parentCommentId'] as String?,
        isAnonymous: json['isAnonymous'] as bool? ?? false,
        authorName: json['authorName'] as String,
        authorEmail: json['authorEmail'] as String,
        content: json['content'] as String,
        likedBy: (json['likedBy'] as List<dynamic>? ?? []).cast<String>(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  CommunityComment copyWith({
    String? content,
    List<String>? likedBy,
  }) =>
      CommunityComment(
        id: id,
        postId: postId,
        parentCommentId: parentCommentId,
        isAnonymous: isAnonymous,
        authorName: authorName,
        authorEmail: authorEmail,
        content: content ?? this.content,
        likedBy: likedBy ?? this.likedBy,
        createdAt: createdAt,
      );
}
