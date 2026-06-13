enum ReviewVisibility { public, private }

class Review {
  final String id;
  final String tripId;
  final String destination;
  final int days;
  final int rating;
  final String? title;
  final String? text;
  final List<String> photos; // base64 data URLs
  final List<String> videos; // base64 data URLs
  final ReviewVisibility visibility;
  final DateTime createdAt;
  final String authorName;

  Review({
    required this.id,
    required this.tripId,
    required this.destination,
    required this.days,
    required this.rating,
    this.title,
    this.text,
    this.photos = const [],
    this.videos = const [],
    this.visibility = ReviewVisibility.private,
    required this.createdAt,
    required this.authorName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'destination': destination,
        'days': days,
        'rating': rating,
        if (title != null) 'title': title,
        if (text != null) 'text': text,
        'photos': photos,
        'videos': videos,
        'visibility': visibility.name,
        'createdAt': createdAt.toIso8601String(),
        'authorName': authorName,
      };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        tripId: json['tripId'] as String,
        destination: json['destination'] as String,
        days: json['days'] as int,
        rating: json['rating'] as int,
        title: json['title'] as String?,
        text: json['text'] as String?,
        photos: (json['photos'] as List<dynamic>? ?? []).cast<String>(),
        videos: (json['videos'] as List<dynamic>? ?? []).cast<String>(),
        visibility: ReviewVisibility.values.firstWhere(
          (v) => v.name == json['visibility'],
          orElse: () => ReviewVisibility.private,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        authorName: json['authorName'] as String,
      );

  Review copyWith({
    int? rating,
    String? title,
    String? text,
    List<String>? photos,
    List<String>? videos,
    ReviewVisibility? visibility,
  }) =>
      Review(
        id: id,
        tripId: tripId,
        destination: destination,
        days: days,
        rating: rating ?? this.rating,
        title: title ?? this.title,
        text: text ?? this.text,
        photos: photos ?? this.photos,
        videos: videos ?? this.videos,
        visibility: visibility ?? this.visibility,
        createdAt: createdAt,
        authorName: authorName,
      );
}
